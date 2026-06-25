class PromoCardPrepare {
  final bool success;
  final bool canCreate;
  final String? reason;
  final String? cardUserId;
  final bool alreadyRegistered;
  final int walletBalanceCents;
  final int walletBalanceAfterCents;
  final bool isFirstCard;
  final bool promoReferralEligible;
  final int creationFeeCents;
  final int initialLoadCents;
  final int sweepCents;
  final int cardWillReceiveCents;
  final int totalToChargeCents;
  final int referralRewardCents;
  final int feeVersion;
  final List<String> errors;

  const PromoCardPrepare({
    required this.success,
    required this.canCreate,
    required this.walletBalanceCents,
    required this.walletBalanceAfterCents,
    required this.creationFeeCents,
    required this.initialLoadCents,
    required this.sweepCents,
    required this.cardWillReceiveCents,
    required this.totalToChargeCents,
    required this.referralRewardCents,
    required this.feeVersion,
    required this.isFirstCard,
    required this.promoReferralEligible,
    required this.alreadyRegistered,
    this.reason,
    this.cardUserId,
    this.errors = const [],
  });

  /// Shortfall in cents when canCreate is false.
  int get shortfallCents =>
      (totalToChargeCents - walletBalanceCents).clamp(0, double.maxFinite.toInt());

  factory PromoCardPrepare.fromJson(Map<String, dynamic> json) {
    return PromoCardPrepare(
      success: json['success'] == true,
      canCreate: json['canCreate'] == true,
      reason: json['reason']?.toString(),
      cardUserId: json['cardUserId']?.toString(),
      alreadyRegistered: json['alreadyRegistered'] == true,
      walletBalanceCents: (json['walletBalanceCents'] as num?)?.toInt() ?? 0,
      walletBalanceAfterCents:
          (json['walletBalanceAfterCents'] as num?)?.toInt() ?? 0,
      isFirstCard: json['isFirstCard'] == true,
      promoReferralEligible: json['promoReferralEligible'] == true,
      creationFeeCents: (json['creationFeeCents'] as num?)?.toInt() ?? 0,
      initialLoadCents: (json['initialLoadCents'] as num?)?.toInt() ?? 0,
      sweepCents: (json['sweepCents'] as num?)?.toInt() ?? 0,
      cardWillReceiveCents:
          (json['cardWillReceiveCents'] as num?)?.toInt() ?? 0,
      totalToChargeCents: (json['totalToChargeCents'] as num?)?.toInt() ?? 0,
      referralRewardCents: (json['referralRewardCents'] as num?)?.toInt() ?? 0,
      feeVersion: (json['feeVersion'] as num?)?.toInt() ?? 0,
      errors: (json['errors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}
