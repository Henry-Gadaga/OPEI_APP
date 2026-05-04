/// Wallet check returned alongside a payout review. All cents are USD.
class WalletCheckSummary {
  final bool canProceed;
  final int availableBalanceCents;
  final int requiredAmountCents;
  final int feeAmountCents;
  final int totalDebitAmountCents;
  final int remainingAvailableBalanceCents;
  final int shortfallCents;

  const WalletCheckSummary({
    required this.canProceed,
    required this.availableBalanceCents,
    required this.requiredAmountCents,
    required this.feeAmountCents,
    required this.totalDebitAmountCents,
    required this.remainingAvailableBalanceCents,
    required this.shortfallCents,
  });

  factory WalletCheckSummary.fromJson(Map<String, dynamic> json) {
    int readInt(String key) {
      final v = json[key];
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return WalletCheckSummary(
      canProceed: json['canProceed'] == true,
      availableBalanceCents: readInt('availableBalanceCents'),
      requiredAmountCents: readInt('requiredAmountCents'),
      feeAmountCents: readInt('feeAmountCents'),
      totalDebitAmountCents: readInt('totalDebitAmountCents'),
      remainingAvailableBalanceCents:
          readInt('remainingAvailableBalanceCents'),
      shortfallCents: readInt('shortfallCents'),
    );
  }
}

/// Quote for a payout, returned by `POST /reviews`.
class PayoutReview {
  final String reviewId;
  final String beneficiaryId;
  final String payoutCurrency;
  final int payoutAmountMinor;
  final String requiredAmountUsd;
  final String feeAmountUsd;
  final String totalDebitAmountUsd;
  final DateTime? expiresAt;
  final WalletCheckSummary? walletCheck;

  const PayoutReview({
    required this.reviewId,
    required this.beneficiaryId,
    required this.payoutCurrency,
    required this.payoutAmountMinor,
    required this.requiredAmountUsd,
    required this.feeAmountUsd,
    required this.totalDebitAmountUsd,
    this.expiresAt,
    this.walletCheck,
  });

  factory PayoutReview.fromJson(Map<String, dynamic> json) {
    int readInt(String key) {
      final v = json[key];
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    String readString(String key, {String fallback = ''}) {
      final v = json[key];
      if (v == null) return fallback;
      return v.toString();
    }

    DateTime? readDate(String key) {
      final v = json[key];
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
      return null;
    }

    final wcRaw = json['walletCheck'];
    return PayoutReview(
      reviewId: readString('reviewId'),
      beneficiaryId: readString('beneficiaryId'),
      payoutCurrency: readString('payoutCurrency').toUpperCase(),
      payoutAmountMinor: readInt('payoutAmountMinor'),
      requiredAmountUsd: readString('requiredAmountUsd'),
      feeAmountUsd: readString('feeAmountUsd'),
      totalDebitAmountUsd: readString('totalDebitAmountUsd'),
      expiresAt: readDate('expiresAt'),
      walletCheck: wcRaw is Map<String, dynamic>
          ? WalletCheckSummary.fromJson(wcRaw)
          : null,
    );
  }
}
