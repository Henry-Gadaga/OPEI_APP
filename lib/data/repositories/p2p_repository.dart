import 'package:flutter/foundation.dart';
import 'package:opei/core/network/api_client.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/core/storage/secure_storage_service.dart';
import 'package:opei/data/models/p2p_ad.dart';
import 'package:opei/data/models/p2p_payment_method_type.dart';
import 'package:opei/data/models/p2p_trade.dart';
import 'package:opei/data/models/p2p_user_payment_method.dart';
import 'package:opei/data/models/p2p_user_profile.dart';

class P2PTradeProofUploadRequest {
  final String fileName;
  final String contentType;

  const P2PTradeProofUploadRequest({required this.fileName, required this.contentType});

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'contentType': contentType,
    };
  }
}

class P2PTradeProofUploadPlan {
  final String uploadUrl;
  final String fileUrl;
  final Map<String, String> headers;

  const P2PTradeProofUploadPlan({
    required this.uploadUrl,
    required this.fileUrl,
    required this.headers,
  });

  factory P2PTradeProofUploadPlan.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const P2PTradeProofUploadPlan(uploadUrl: '', fileUrl: '', headers: {});
    }

    final headersRaw = json['headers'] ?? json['requiredHeaders'] ?? json['uploadHeaders'];
    final headerMap = <String, String>{};
    if (headersRaw is Map) {
      headersRaw.forEach((key, value) {
        if (key == null || value == null) return;
        headerMap[key.toString()] = value.toString();
      });
    }

    return P2PTradeProofUploadPlan(
      uploadUrl: (json['uploadUrl'] ?? json['url'] ?? '').toString(),
      // Support either `fileUrl` or `publicUrl` keys from backend
      fileUrl: (json['fileUrl'] ?? json['publicUrl'] ?? '').toString(),
      headers: headerMap,
    );
  }
}

class P2PRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  P2PRepository(this._apiClient, this._storage);

  Future<List<P2PAd>> fetchAds({
    required P2PAdType type,
    required String currency,
    int? minAmountCents,
    int? maxAmountCents,
  }) async {
    final query = <String, dynamic>{
      'type': type.apiValue,
      'currency': currency.toUpperCase(),
    };

    if (minAmountCents != null && minAmountCents > 0) {
      query['minAmountCents'] = minAmountCents.toString();
    }

    if (maxAmountCents != null && maxAmountCents > 0) {
      query['maxAmountCents'] = maxAmountCents.toString();
    }

    // Base URL already includes /api/v1, so we only append the resource path here.
    final payload = await _apiClient.get<Map<String, dynamic>>(
      '/p2p/ads',
      queryParameters: query,
    );

    final data = payload['data'];
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(P2PAd.fromJson)
          .toList(growable: false);
    }

    return const <P2PAd>[];
  }

  Future<List<P2PAd>> fetchMyAds({String? status}) async {
    final query = <String, dynamic>{};
    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }

    final payload = await _apiClient.get<Map<String, dynamic>>(
      '/p2p/ads/mine',
      queryParameters: query.isEmpty ? null : query,
    );

    final data = payload['data'];
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(P2PAd.fromJson)
          .toList(growable: false);
    }

    return const <P2PAd>[];
  }

  // --- Profile status ---
  Future<bool> fetchProfileStatus() async {
    final payload = await _apiClient.get<Map<String, dynamic>>('/p2p/user-profile/status');
    // Supports { data: { hasProfile: true } } and { hasProfile: false }
    if (payload.containsKey('data')) {
      final data = payload['data'];
      if (data is Map<String, dynamic> && data['hasProfile'] is bool) {
        return data['hasProfile'] as bool;
      }
    }
    if (payload['hasProfile'] is bool) {
      return payload['hasProfile'] as bool;
    }
    return false;
  }

  Future<P2PUserProfile?> fetchUserProfile() async {
    try {
      final payload = await _apiClient.get<Map<String, dynamic>>('/p2p/user-profile/me');
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        return P2PUserProfile.fromJson(data);
      }
      return null;
    } on ApiError catch (error) {
      if (error.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  // Upsert profile (create or update)
  Future<Map<String, dynamic>> upsertUserProfile({
    required String displayName,
    required String nickname,
    required String bio,
    required String preferredLanguage,
    required String preferredCurrency,
  }) async {
    final payload = await _apiClient.post<Map<String, dynamic>>(
      '/p2p/user-profile',
      data: {
        'displayName': displayName,
        'nickname': nickname,
        'bio': bio,
        'preferredLanguage': preferredLanguage,
        'preferredCurrency': preferredCurrency.toUpperCase(),
      },
    );
    return (payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{});
  }

  // --- User payment methods (list/user-owned) ---
  Future<List<P2PUserPaymentMethod>> fetchUserPaymentMethods({String? currency}) async {
    final payload = await _apiClient.get<Map<String, dynamic>>(
      '/p2p/user-payment-methods',
      queryParameters: currency == null || currency.isEmpty
          ? null
          : {
              'currency': currency.toUpperCase(),
            },
    );
    final data = payload['data'];
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(P2PUserPaymentMethod.fromJson)
          .toList(growable: false);
    }
    return const <P2PUserPaymentMethod>[];
  }

  // --- Payment method types (public; admin-configured) ---
  Future<List<P2PPaymentMethodType>> fetchPaymentMethodTypes(String currency) async {
    final payload = await _apiClient.get<Map<String, dynamic>>(
      '/p2p/payment-method-types',
      queryParameters: {
        'currency': currency.toUpperCase(),
      },
    );
    final data = payload['data'];
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(P2PPaymentMethodType.fromJson)
          .toList(growable: false);
    }
    return const <P2PPaymentMethodType>[];
  }

  // --- Create user payment method ---
  Future<P2PUserPaymentMethod> createUserPaymentMethod({
    required String paymentMethodTypeId,
    required String accountName,
    required String accountNumber,
    String? extraDetails,
  }) async {
    final payload = await _apiClient.post<Map<String, dynamic>>(
      '/p2p/user-payment-methods',
      data: {
        'paymentMethodTypeId': paymentMethodTypeId,
        'accountName': accountName,
        'accountNumber': accountNumber,
        if (extraDetails != null && extraDetails.trim().isNotEmpty) 'extraDetails': extraDetails.trim(),
      },
    );
    final data = payload['data'] as Map<String, dynamic>?;
    return P2PUserPaymentMethod.fromJson(data ?? <String, dynamic>{});
  }

  Future<P2PUserPaymentMethod> updateUserPaymentMethod({
    required String paymentMethodId,
    String? accountName,
    String? accountNumber,
    String? extraDetails,
  }) async {
    final data = <String, dynamic>{};
    if (accountName != null) {
      data['accountName'] = accountName;
    }
    if (accountNumber != null) {
      data['accountNumber'] = accountNumber;
    }
    if (extraDetails != null) {
      data['extraDetails'] = extraDetails;
    }

    final payload = await _apiClient.patch<Map<String, dynamic>>(
      '/p2p/user-payment-methods/$paymentMethodId',
      data: data,
    );
    final body = payload['data'] as Map<String, dynamic>?;
    return P2PUserPaymentMethod.fromJson(body ?? <String, dynamic>{});
  }

  // --- Create ad (BUY/SELL) ---
  Future<P2PAd> createAd({
    required P2PAdType type,
    required String currency,
    required int totalAmountCents,
    required int minOrderCents,
    required int maxOrderCents,
    required int rateCents,
    String? instructions,
    List<String>? userPaymentMethodIds,
  }) async {
    final data = <String, dynamic>{
      'type': type.apiValue,
      'currency': currency.toUpperCase(),
      'totalAmountCents': totalAmountCents.toString(),
      'minOrderCents': minOrderCents.toString(),
      'maxOrderCents': maxOrderCents.toString(),
      'rateCents': rateCents.toString(),
      if (instructions != null) 'instructions': instructions,
      if (userPaymentMethodIds != null && userPaymentMethodIds.isNotEmpty)
        'userPaymentMethodIds': userPaymentMethodIds,
    };

    final payload = await _apiClient.post<Map<String, dynamic>>('/p2p/ads', data: data);
    final body = payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return P2PAd.fromJson(body);
  }

  Future<P2PAd> deactivateAd({required String adId}) async {
    final payload = await _apiClient.patch<Map<String, dynamic>>('/p2p/ads/$adId/deactivate');
    final body = payload['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return P2PAd.fromJson(body);
  }

  Future<P2PTrade> cancelTrade({required String tradeId}) async {
    final payload = await _apiClient.post<Map<String, dynamic>>('/p2p/trades/$tradeId/cancel');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return P2PTrade.fromJson(data);
    }
    throw ApiError(message: 'Invalid response when cancelling trade.');
  }

  // --- Create trade (place order against an ad) ---
  // Expects:
  //   POST /p2p/trades { adId, amountCents, adPaymentMethodId? }
  // Returns the created trade payload. We return Map to avoid over-modeling for now.
  Future<Map<String, dynamic>> createTrade({
    required String adId,
    required int amountCents,
    String? adPaymentMethodId,
  }) async {
    final payload = await _apiClient.post<Map<String, dynamic>>(
      '/p2p/trades',
      data: <String, dynamic>{
        'adId': adId,
        'amountCents': amountCents.toString(),
        if (adPaymentMethodId != null && adPaymentMethodId.isNotEmpty)
          'adPaymentMethodId': adPaymentMethodId,
      },
    );
    final data = payload['data'];
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  Future<List<P2PTradeProofUploadPlan>> prepareTradeProofUploads({
    required String tradeId,
    required List<P2PTradeProofUploadRequest> files,
  }) async {
    if (files.isEmpty) {
      return const <P2PTradeProofUploadPlan>[];
    }

    // We must presign one file at a time with body: { purpose, mimeType }
    // and include x-user-id header. No tradeId in payload.
    final userId = (await _storage.getUser())?.id;
    if (userId == null || userId.isEmpty) {
      throw ApiError(message: 'missing x-user-id');
    }

    debugPrint(
        '🖼️ Presigning ${files.length} proof upload(s) for trade $tradeId via /p2p/uploads/presign (per-file)');

    final plans = <P2PTradeProofUploadPlan>[];
    for (final file in files) {
      final payload = await _apiClient.post<Map<String, dynamic>>(
        '/p2p/uploads/presign',
        data: {
          'purpose': 'TRADE_PROOF',
          'mimeType': file.contentType,
        },
        headers: {
          'x-user-id': userId,
        },
      );

      // Expect either { data: {...} } or direct payload
      Map<String, dynamic>? body;
      final raw = payload['data'];
      if (raw is Map<String, dynamic>) {
        body = raw;
      }

      body ??= payload;

      final plan = P2PTradeProofUploadPlan.fromJson(body);
      if (plan.uploadUrl.isEmpty || plan.fileUrl.isEmpty) {
        throw ApiError(message: 'Invalid presign response');
      }
      plans.add(plan);
    }

    return plans;
  }

  Future<P2PTrade> markTradeAsPaid({
    required String tradeId,
    String? message,
    required List<String> proofUrls,
  }) async {
    final payload = await _apiClient.post<Map<String, dynamic>>(
      '/p2p/trades/$tradeId/mark-paid',
      data: {
        if (message != null && message.trim().isNotEmpty) 'message': message.trim(),
        'proofUrls': proofUrls,
      },
    );

    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return P2PTrade.fromJson(data);
    }

    throw ApiError(message: 'Invalid response when marking trade as paid.');
  }

  Future<P2PTrade> releaseTrade({required String tradeId}) async {
    final payload = await _apiClient.post<Map<String, dynamic>>('/p2p/trades/$tradeId/release');
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return P2PTrade.fromJson(data);
    }
    throw ApiError(message: 'Invalid response when releasing trade.');
  }

  Future<P2PTradeRating> rateTrade({
    required String tradeId,
    required int score,
    String? comment,
    List<String>? tags,
  }) async {
    final trimmedComment = comment?.trim();
    final filteredTags = (tags ?? const <String>[]) 
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList(growable: false);

    final payload = await _apiClient.post<Map<String, dynamic>>(
      '/p2p/trades/$tradeId/rate',
      data: <String, dynamic>{
        'score': score,
        if (trimmedComment != null && trimmedComment.isNotEmpty) 'comment': trimmedComment,
        if (filteredTags.isNotEmpty) 'tags': filteredTags,
      },
    );

    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return P2PTradeRating.fromJson(data);
    }

    throw ApiError(message: 'Invalid response when reviewing trade rating.');
  }

  Future<P2PTrade> raiseTradeDispute({
    required String tradeId,
    required String reason,
  }) async {
    final trimmed = reason.trim();
    final payload = await _apiClient.post<Map<String, dynamic>>(
      '/p2p/trades/$tradeId/dispute',
      data: {
        'reason': trimmed,
      },
    );

    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return P2PTrade.fromJson(data);
    }

    throw ApiError(message: 'Invalid response when opening trade dispute.');
  }

  Future<List<P2PTrade>> fetchMyTrades({String? status}) async {
    final query = <String, dynamic>{};
    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }

    final payload = await _apiClient.get<Map<String, dynamic>>(
      '/p2p/trades/mine',
      queryParameters: query.isEmpty ? null : query,
    );

    final data = payload['data'];
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(P2PTrade.fromJson)
          .toList(growable: false);
    }

    return const <P2PTrade>[];
  }
}