import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/models/beneficiary.dart';
import 'package:opei/data/repositories/remittance_repository.dart';

import 'send_mobile_money_state.dart';

/// Controller for the "send mobile money" flow keyed by [Beneficiary.id].
///
/// One controller per receiver — when the user picks a different receiver, a
/// fresh controller is built with empty state, so no values bleed over.
final sendMobileMoneyControllerProvider = NotifierProvider.family<
    SendMobileMoneyController, SendMobileMoneyState, Beneficiary>(
  (beneficiary) {
    final controller = SendMobileMoneyController();
    controller._beneficiary = beneficiary;
    return controller;
  },
);

class SendMobileMoneyController extends Notifier<SendMobileMoneyState> {
  late Beneficiary _beneficiary;
  late RemittanceRepository _repo;

  @override
  SendMobileMoneyState build() {
    _repo = ref.read(remittanceRepositoryProvider);
    return SendMobileMoneyState(beneficiary: _beneficiary);
  }

  // ── Amount typing ─────────────────────────────────────────────────────────

  /// Sets the target amount in the smallest unit of the receiver's local
  /// currency (e.g. UGX → integer shillings, KES → cents).
  void setTargetAmountMinor(int minor) {
    state = state.copyWith(
      targetAmountMinor: minor,
      clearReviewError: true,
      clearReview: true,
    );
  }

  // ── Step 1: Review ────────────────────────────────────────────────────────

  /// Calls `POST /reviews` for the selected receiver and current amount.
  /// Returns `true` on success — the UI can then push the preview screen.
  ///
  /// `targetAmountMinor` is the amount in the smallest unit of the
  /// **receiver's local currency** (e.g. UGX 1000 → 1000, KES 10.00 → 1000).
  /// The remittance service computes the USD debit on the wallet from there.
  Future<bool> createReview() async {
    final userId = ref.read(authSessionProvider).userId;
    if (userId == null) {
      state = state.copyWith(reviewError: 'Please sign in to continue.');
      return false;
    }
    if (state.targetAmountMinor <= 0) {
      state = state.copyWith(reviewError: 'Enter an amount above 0.');
      return false;
    }

    state = state.copyWith(isReviewing: true, clearReviewError: true);
    try {
      final review = await _repo.createReview(
        userId: userId,
        beneficiaryId: _beneficiary.id,
        targetAmountMinor: state.targetAmountMinor,
      );
      state = state.copyWith(isReviewing: false, review: review);
      return true;
    } catch (error, stack) {
      debugPrint('Review error: $error\n$stack');
      state = state.copyWith(
        isReviewing: false,
        reviewError: ErrorHelper.getErrorMessage(error, context: 'payout'),
      );
      return false;
    }
  }

  // ── Step 2 + 3: Initiate then Finalize (kicked off as one user action) ───

  /// Confirms the payout: initiates → finalizes. Returns `true` if both API
  /// calls completed (regardless of `PENDING_WEBHOOK`, which the UI treats as
  /// a non-terminal "processing" state).
  Future<bool> confirmAndSend({String description = 'Mobile money payout'}) async {
    final userId = ref.read(authSessionProvider).userId;
    final review = state.review;
    if (userId == null || review == null) {
      state = state.copyWith(
          initiateError: 'Missing review or session. Please try again.');
      return false;
    }

    // Idempotency key combines user + review so the same Confirm tap can never
    // initiate twice — backend will replay the same response if user retries.
    final idempotencyKey = 'payout_init_${userId}_${review.reviewId}';

    state = state.copyWith(
      isInitiating: true,
      clearInitiateError: true,
      clearFinalizeError: true,
    );
    try {
      final init = await _repo.initiatePayout(
        userId: userId,
        reviewId: review.reviewId,
        description: description,
        idempotencyKey: idempotencyKey,
      );
      state = state.copyWith(isInitiating: false, initiation: init);
    } catch (error, stack) {
      debugPrint('Initiate error: $error\n$stack');
      state = state.copyWith(
        isInitiating: false,
        initiateError: ErrorHelper.getErrorMessage(error, context: 'payout'),
      );
      return false;
    }

    // Step 3: finalize
    final payoutId = state.initiation!.payoutId;
    state = state.copyWith(isFinalizing: true, clearFinalizeError: true);
    try {
      final finalRes = await _repo.finalizePayout(payoutId);
      state =
          state.copyWith(isFinalizing: false, finalization: finalRes);
      return true;
    } catch (error, stack) {
      debugPrint('Finalize error: $error\n$stack');
      state = state.copyWith(
        isFinalizing: false,
        finalizeError: ErrorHelper.getErrorMessage(error, context: 'payout'),
      );
      return false;
    }
  }

  void clearInitiateError() =>
      state = state.copyWith(clearInitiateError: true);
  void clearFinalizeError() =>
      state = state.copyWith(clearFinalizeError: true);
  void clearReviewError() => state = state.copyWith(clearReviewError: true);
}
