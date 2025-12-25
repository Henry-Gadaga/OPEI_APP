import 'package:tt1/core/money/money.dart';
import 'package:tt1/core/network/api_client.dart';
import 'package:tt1/core/network/api_response.dart';
import 'package:tt1/data/models/wallet_lookup_request.dart';
import 'package:tt1/data/models/wallet_lookup_response.dart';
import 'package:tt1/data/models/transfer_fee_request.dart';
import 'package:tt1/data/models/transfer_fee_response.dart';
import 'package:tt1/data/models/transfer_request.dart';
import 'package:tt1/data/models/transfer_response.dart';

class TransferRepository {
  final ApiClient _apiClient;

  TransferRepository(this._apiClient);

  Future<WalletLookupResponse> lookupWallet(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    final request = WalletLookupRequest(email: cleanEmail);

    final response = await _apiClient.post<Map<String, dynamic>>(
      '/user/lookup',
      data: request.toJson(),
    );

    final apiResponse = ApiResponse<WalletLookupResponse>.fromJson(
      response,
      (json) => WalletLookupResponse.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }

    return apiResponse.data!;
  }

  Future<TransferPreviewResponse> previewTransfer(String toUserId, Money amount) async {
    final request = TransferPreviewRequest(
      toUserId: toUserId,
      amount: amount.cents,
    );
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/wallets/transfer/preview',
      data: request.toJson(),
    );

    // Handle both plain payloads and wrapped ApiResponse shapes
    if (response.containsKey('success')) {
      final isSuccess = response['success'] == true;
      if (!isSuccess) {
        final message = response['message']?.toString().trim();
        throw Exception(message?.isNotEmpty == true ? message : 'Failed to preview transfer');
      }

      final data = response['data'];
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid transfer preview payload');
      }

      return TransferPreviewResponse.fromJson(
        data,
        currency: amount.currency,
        fallbackTransferAmountCents: amount.cents,
        fallbackEstimatedFeeCents: 0,
        fallbackTotalDebitCents: amount.cents,
        fallbackReceiverCreditAmountCents: amount.cents,
      );
    }

    return TransferPreviewResponse.fromJson(
      response,
      currency: amount.currency,
      fallbackTransferAmountCents: amount.cents,
      fallbackEstimatedFeeCents: 0,
      fallbackTotalDebitCents: amount.cents,
      fallbackReceiverCreditAmountCents: amount.cents,
    );
  }

  Future<TransferResponse> executeTransfer(
    String toUserId,
    Money amount,
    String idempotencyKey, {
    String? description,
    Money? expectedSenderBalanceAfter,
  }) async {
    final request = TransferRequest(
      toUserId: toUserId,
      amount: amount.cents,
      description: description,
    );
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/wallets/transfer',
      data: request.toJson(),
      headers: {'Idempotency-Key': idempotencyKey},
    );

    // Backend returns transfer data directly (not wrapped in ApiResponse)
    return TransferResponse.fromJson(
      response,
      fallbackAmount: amount,
      fallbackFromBalance: expectedSenderBalanceAfter,
      fallbackCurrency: amount.currency,
    );
  }
}
