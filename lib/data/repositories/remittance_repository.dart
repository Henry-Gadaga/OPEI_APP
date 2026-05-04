import 'package:flutter/foundation.dart';
import 'package:opei/core/network/api_client.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/models/payout_result.dart';
import 'package:opei/data/models/payout_review.dart';

/// Talks to the gateway's remittance endpoints (`/reviews`, `/payouts/...`).
///
/// All requests carry the user JWT via [ApiClient]'s interceptor; the gateway
/// injects `x-internal-api-key` to the underlying remittance service.
class RemittanceRepository {
  final ApiClient _apiClient;

  RemittanceRepository(this._apiClient);

  /// Creates a payout quote for [beneficiaryId] of [targetAmountMinor]
  /// (smallest unit of the receiver's currency, e.g. KES cents).
  Future<PayoutReview> createReview({
    required String userId,
    required String beneficiaryId,
    required int targetAmountMinor,
    bool forceRefresh = false,
  }) async {
    try {
      debugPrint(
          '🧾 Creating review for $beneficiaryId @ $targetAmountMinor minor');
      final payload = await _apiClient.post<Map<String, dynamic>>(
        '/reviews',
        data: {
          'userId': userId,
          'beneficiaryId': beneficiaryId,
          'targetAmountMinor': targetAmountMinor,
          'forceRefresh': forceRefresh,
        },
      );

      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        return PayoutReview.fromJson(data);
      }
      return PayoutReview.fromJson(payload);
    } on ApiError catch (error) {
      debugPrint('❌ Review failed: ${ErrorHelper.getErrorMessage(error)}');
      rethrow;
    }
  }

  /// Initiates a payout for [reviewId]. Provide a stable [idempotencyKey] so
  /// retries don't double-charge the wallet.
  Future<PayoutInitiation> initiatePayout({
    required String userId,
    required String reviewId,
    required String description,
    required String idempotencyKey,
  }) async {
    try {
      debugPrint('🚀 Initiating payout for review $reviewId');
      final payload = await _apiClient.post<Map<String, dynamic>>(
        '/payouts/initiate',
        data: {
          'userId': userId,
          'reviewId': reviewId,
          'description': description,
        },
        headers: {
          'Idempotency-Key': idempotencyKey,
        },
      );

      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        return PayoutInitiation.fromJson(data);
      }
      return PayoutInitiation.fromJson(payload);
    } on ApiError catch (error) {
      debugPrint('❌ Payout init failed: ${ErrorHelper.getErrorMessage(error)}');
      rethrow;
    }
  }

  /// Finalizes a previously initiated payout.
  ///
  /// Note: a `success: false` response with `status: PENDING_WEBHOOK` is **not**
  /// a terminal failure — the provider just hasn't acknowledged yet and the
  /// webhook will decide the final outcome.
  Future<PayoutFinalization> finalizePayout(String payoutId) async {
    try {
      debugPrint('✅ Finalizing payout $payoutId');
      final payload = await _apiClient.patch<Map<String, dynamic>>(
        '/payouts/$payoutId/finalize',
      );
      return PayoutFinalization.fromJson(payload);
    } on ApiError catch (error) {
      debugPrint(
          '❌ Payout finalize failed: ${ErrorHelper.getErrorMessage(error)}');
      rethrow;
    }
  }
}
