/// Stage of a payout's lifecycle relevant to the UI.
enum PayoutStage {
  initiated,
  pendingWebhook,
  success,
  failed,
  unknown,
}

PayoutStage payoutStageFromString(String? raw) {
  switch ((raw ?? '').toUpperCase()) {
    case 'INITIATED':
      return PayoutStage.initiated;
    case 'PENDING_WEBHOOK':
    case 'PENDING':
      return PayoutStage.pendingWebhook;
    case 'SUCCESS':
    case 'COMPLETED':
      return PayoutStage.success;
    case 'FAILED':
    case 'FAILURE':
      return PayoutStage.failed;
    default:
      return PayoutStage.unknown;
  }
}

/// Response of `POST /payouts/initiate`.
class PayoutInitiation {
  final String payoutId;
  final String reviewId;
  final String reference;
  final String? providerTransactionId;
  final PayoutStage stage;

  const PayoutInitiation({
    required this.payoutId,
    required this.reviewId,
    required this.reference,
    required this.providerTransactionId,
    required this.stage,
  });

  factory PayoutInitiation.fromJson(Map<String, dynamic> json) {
    String s(String key) => (json[key] ?? '').toString();
    return PayoutInitiation(
      payoutId: s('payoutId'),
      reviewId: s('reviewId'),
      reference: s('reference'),
      providerTransactionId:
          json['providerTransactionId']?.toString(),
      stage: payoutStageFromString(s('status')),
    );
  }
}

/// Response of `PATCH /payouts/:id/finalize`.
class PayoutFinalization {
  /// `success` flag from the API. `false` doesn't always mean failure — it can
  /// also mean "awaiting webhook confirmation".
  final bool success;
  final String message;
  final String payoutId;
  final String reference;
  final String? providerTransactionId;
  final PayoutStage stage;

  const PayoutFinalization({
    required this.success,
    required this.message,
    required this.payoutId,
    required this.reference,
    required this.providerTransactionId,
    required this.stage,
  });

  factory PayoutFinalization.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;
    String s(String key) => (data[key] ?? '').toString();

    return PayoutFinalization(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      payoutId: s('payoutId'),
      reference: s('reference'),
      providerTransactionId: data['providerTransactionId']?.toString(),
      stage: payoutStageFromString(s('status')),
    );
  }
}
