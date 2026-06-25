import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:opei/core/network/api_client.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/core/storage/secure_storage_service.dart';
import 'package:opei/data/models/express_agent_status.dart';
import 'package:opei/data/models/express_order.dart';
import 'package:opei/data/models/express_order_preview.dart';
import 'package:opei/data/models/p2p_payment_method_type.dart';
import 'package:opei/data/repositories/p2p_repository.dart'
    show P2PTradeProofUploadPlan;

/// Talks to the gateway's Express P2P endpoints (`/p2p/express-orders/...`).
///
/// All authenticated requests carry the user JWT via [ApiClient]'s interceptor;
/// the gateway injects `x-user-id` for the underlying p2p-service. This module
/// is completely independent from Classic P2P (`/p2p/ads`, `/p2p/trades`).
class ExpressOrderRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  ExpressOrderRepository(this._apiClient, this._storage);

  // ── A. Agent gate ─────────────────────────────────────────────────────────
  // GET /p2p/express-orders/agent/status
  Future<ExpressAgentStatus> getAgentStatus() async {
    final payload = await _apiClient.get<Map<String, dynamic>>(
      '/p2p/express-orders/agent/status',
    );
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return ExpressAgentStatus.fromJson(data);
    }
    return ExpressAgentStatus.none;
  }

  // ── B. Payment rails (public at service, called authenticated in app) ──────
  // GET /p2p/payment-method-types?currency=X&isActive=true
  Future<List<P2PPaymentMethodType>> fetchPaymentMethodTypes({
    required String currency,
  }) async {
    final payload = await _apiClient.get<Map<String, dynamic>>(
      '/p2p/payment-method-types',
      queryParameters: {'currency': currency.toUpperCase(), 'isActive': 'true'},
    );
    final data = payload['data'];
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(P2PPaymentMethodType.fromJson)
          .where((m) => m.isActive)
          .toList(growable: false);
    }
    return const <P2PPaymentMethodType>[];
  }

  // ── C. Preview quote (public at service, called authenticated in app) ──────
  // POST /p2p/express-orders/preview
  Future<ExpressOrderPreview> previewOrder({
    required String paymentMethodTypeId,
    required String quoteCurrency,
    required int amountUsdCents,
  }) async {
    final payload = await _apiClient.post<Map<String, dynamic>>(
      '/p2p/express-orders/preview',
      data: {
        'paymentMethodTypeId': paymentMethodTypeId,
        'quoteCurrency': quoteCurrency.toUpperCase(),
        'amountUsdCents': amountUsdCents.toString(),
      },
    );
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return ExpressOrderPreview.fromJson(data);
    }
    throw ApiError(message: 'Could not load a quote. Please try again.');
  }

  // ── D. Create order ────────────────────────────────────────────────────────
  // POST /p2p/express-orders
  Future<ExpressOrder> createOrder({
    required String paymentMethodTypeId,
    required String quoteCurrency,
    required int amountUsdCents,
  }) async {
    final payload = await _apiClient.post<Map<String, dynamic>>(
      '/p2p/express-orders',
      data: {
        'paymentMethodTypeId': paymentMethodTypeId,
        'quoteCurrency': quoteCurrency.toUpperCase(),
        'amountUsdCents': amountUsdCents.toString(),
      },
    );
    return _parseOrder(payload, action: 'creating your order');
  }

  // ── E. Customer inbox ───────────────────────────────────────────────────────
  // GET /p2p/express-orders/mine
  Future<List<ExpressOrder>> fetchMyOrders({String? status}) async {
    final payload = await _apiClient.get<Map<String, dynamic>>(
      '/p2p/express-orders/mine',
      queryParameters: (status != null && status.isNotEmpty)
          ? {'status': status}
          : null,
    );
    return _parseOrderList(payload);
  }

  // ── F. Single order (detail + polling) ──────────────────────────────────────
  // GET /p2p/express-orders/:id
  Future<ExpressOrder> fetchOrder(String orderId) async {
    final payload = await _apiClient.get<Map<String, dynamic>>(
      '/p2p/express-orders/$orderId',
    );
    return _parseOrder(payload, action: 'loading your order');
  }

  // ── G. Customer marks paid (with proof) ─────────────────────────────────────
  // POST /p2p/express-orders/:id/mark-paid
  Future<ExpressOrder> markPaid({
    required String orderId,
    required List<String> proofUrls,
    String? message,
  }) async {
    final payload = await _apiClient.post<Map<String, dynamic>>(
      '/p2p/express-orders/$orderId/mark-paid',
      data: {
        'proofUrls': proofUrls,
        if (message != null && message.trim().isNotEmpty)
          'message': message.trim(),
      },
    );
    return _parseOrder(payload, action: 'submitting your payment');
  }

  // ── G2. Buyer cancel order ───────────────────────────────────────────────────
  // POST /p2p/express-orders/:id/cancel
  Future<ExpressOrder> cancelOrder(String orderId) async {
    final payload = await _apiClient.post<Map<String, dynamic>>(
      '/p2p/express-orders/$orderId/cancel',
    );
    return _parseOrder(payload, action: 'cancelling your order');
  }

  // ── G3. Open dispute (buyer or assigned agent) ───────────────────────────────
  // POST /p2p/express-orders/:id/dispute
  Future<ExpressOrder> openDispute({
    required String orderId,
    required String message,
    List<String> imageUrls = const <String>[],
  }) async {
    final payload = await _apiClient.post<Map<String, dynamic>>(
      '/p2p/express-orders/$orderId/dispute',
      data: {
        'message': message.trim(),
        if (imageUrls.isNotEmpty) 'imageUrls': imageUrls,
      },
    );
    return _parseOrder(payload, action: 'opening your dispute');
  }

  // ── H. Proof uploads (presign + PUT) ────────────────────────────────────────
  // POST /p2p/uploads/presign  (shared proof bucket with Classic trades)
  Future<List<String>> uploadProofs(List<ExpressProofUpload> files) async {
    if (files.isEmpty) return const <String>[];

    final userId = (await _storage.getUser())?.id;
    if (userId == null || userId.isEmpty) {
      throw ApiError(message: 'Your session expired. Please sign in again.');
    }

    final dio = Dio();
    final publicUrls = <String>[];

    for (final file in files) {
      final payload = await _apiClient.post<Map<String, dynamic>>(
        '/p2p/uploads/presign',
        data: {'purpose': 'TRADE_PROOF', 'mimeType': file.contentType},
        headers: {'x-user-id': userId},
      );

      final body = payload['data'] is Map<String, dynamic>
          ? payload['data'] as Map<String, dynamic>
          : payload;
      final plan = P2PTradeProofUploadPlan.fromJson(body);
      if (plan.uploadUrl.isEmpty || plan.fileUrl.isEmpty) {
        throw ApiError(message: 'Could not prepare the upload. Please retry.');
      }

      final headers = Map<String, String>.from(plan.headers);
      // Ensure the content type is present even if the presign omitted it.
      headers.putIfAbsent('Content-Type', () => file.contentType);

      try {
        final response = await dio.put<dynamic>(
          plan.uploadUrl,
          data: file.bytes,
          options: Options(headers: headers, validateStatus: (status) => true),
        );
        if (response.statusCode != 200 && response.statusCode != 204) {
          throw ApiError(
            message: 'Upload failed. Please try again.',
            statusCode: response.statusCode,
          );
        }
      } on DioException catch (error) {
        debugPrint('❌ Express proof upload failed: ${error.message}');
        throw ApiError(
          message: 'Failed to upload your proof. Please try again.',
          statusCode: error.response?.statusCode,
        );
      }

      publicUrls.add(plan.fileUrl);
    }

    return publicUrls;
  }

  // ── I. Agent — available orders ─────────────────────────────────────────────
  // GET /p2p/express-orders/agent/available
  Future<List<ExpressOrder>> fetchAvailableOrders() async {
    final payload = await _apiClient.get<Map<String, dynamic>>(
      '/p2p/express-orders/agent/available',
    );
    return _parseOrderList(payload);
  }

  // ── J. Agent — assigned orders (work queue / history) ───────────────────────
  // GET /p2p/express-orders/agent/mine
  Future<List<ExpressOrder>> fetchAgentOrders({String? status}) async {
    final payload = await _apiClient.get<Map<String, dynamic>>(
      '/p2p/express-orders/agent/mine',
      queryParameters: (status != null && status.isNotEmpty)
          ? {'status': status}
          : null,
    );
    return _parseOrderList(payload);
  }

  // ── K. Agent — accept order ─────────────────────────────────────────────────
  // POST /p2p/express-orders/:id/accept
  Future<ExpressOrder> acceptOrder(String orderId) async {
    final payload = await _apiClient.post<Map<String, dynamic>>(
      '/p2p/express-orders/$orderId/accept',
    );
    return _parseOrder(payload, action: 'accepting the order');
  }

  // ── L. Agent — confirm order ────────────────────────────────────────────────
  // POST /p2p/express-orders/:id/confirm
  Future<ExpressOrder> confirmOrder(String orderId) async {
    final payload = await _apiClient.post<Map<String, dynamic>>(
      '/p2p/express-orders/$orderId/confirm',
    );
    return _parseOrder(payload, action: 'confirming the order');
  }

  // ── helpers ─────────────────────────────────────────────────────────────────
  ExpressOrder _parseOrder(
    Map<String, dynamic> payload, {
    required String action,
  }) {
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return ExpressOrder.fromJson(data);
    }
    throw ApiError(message: 'Something went wrong while $action.');
  }

  List<ExpressOrder> _parseOrderList(Map<String, dynamic> payload) {
    final data = payload['data'];
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(ExpressOrder.fromJson)
          .toList(growable: false);
    }
    return const <ExpressOrder>[];
  }
}

/// A picked proof image ready to be uploaded.
class ExpressProofUpload {
  final String contentType;
  final Uint8List bytes;

  const ExpressProofUpload({required this.contentType, required this.bytes});
}
