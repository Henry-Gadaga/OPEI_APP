import 'package:opei/data/models/beneficiary.dart';
import 'package:opei/data/models/payout_result.dart';
import 'package:opei/data/models/payout_review.dart';

class SendMobileMoneyState {
  final Beneficiary beneficiary;

  /// Amount the user wants the receiver to get, expressed in the smallest
  /// unit of the receiver's local currency (e.g. UGX 1000 → 1000, since
  /// UGX has no subunit; KES 10.00 → 1000 since KES has 2 decimals).
  final int targetAmountMinor;

  // ── Review (preview) ──
  final bool isReviewing;
  final String? reviewError;
  final PayoutReview? review;

  // ── Initiate ──
  final bool isInitiating;
  final String? initiateError;
  final PayoutInitiation? initiation;

  // ── Finalize ──
  final bool isFinalizing;
  final String? finalizeError;
  final PayoutFinalization? finalization;

  const SendMobileMoneyState({
    required this.beneficiary,
    this.targetAmountMinor = 0,
    this.isReviewing = false,
    this.reviewError,
    this.review,
    this.isInitiating = false,
    this.initiateError,
    this.initiation,
    this.isFinalizing = false,
    this.finalizeError,
    this.finalization,
  });

  bool get isBusy => isReviewing || isInitiating || isFinalizing;

  SendMobileMoneyState copyWith({
    int? targetAmountMinor,
    bool? isReviewing,
    String? reviewError,
    bool clearReviewError = false,
    PayoutReview? review,
    bool clearReview = false,
    bool? isInitiating,
    String? initiateError,
    bool clearInitiateError = false,
    PayoutInitiation? initiation,
    bool clearInitiation = false,
    bool? isFinalizing,
    String? finalizeError,
    bool clearFinalizeError = false,
    PayoutFinalization? finalization,
    bool clearFinalization = false,
  }) {
    return SendMobileMoneyState(
      beneficiary: beneficiary,
      targetAmountMinor: targetAmountMinor ?? this.targetAmountMinor,
      isReviewing: isReviewing ?? this.isReviewing,
      reviewError: clearReviewError ? null : (reviewError ?? this.reviewError),
      review: clearReview ? null : (review ?? this.review),
      isInitiating: isInitiating ?? this.isInitiating,
      initiateError:
          clearInitiateError ? null : (initiateError ?? this.initiateError),
      initiation: clearInitiation ? null : (initiation ?? this.initiation),
      isFinalizing: isFinalizing ?? this.isFinalizing,
      finalizeError:
          clearFinalizeError ? null : (finalizeError ?? this.finalizeError),
      finalization:
          clearFinalization ? null : (finalization ?? this.finalization),
    );
  }
}
