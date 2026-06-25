class PromoCardCreateResult {
  final String cardId;
  final String? providerCardId;
  final String reference;
  final String status;
  final int initialLoadCents;
  final int creationFeeCents;
  final int totalChargedCents;
  final int sweepCents;
  final int referralRewardCents;

  const PromoCardCreateResult({
    required this.cardId,
    required this.reference,
    required this.status,
    required this.initialLoadCents,
    required this.creationFeeCents,
    required this.totalChargedCents,
    required this.sweepCents,
    required this.referralRewardCents,
    this.providerCardId,
  });

  factory PromoCardCreateResult.fromJson(Map<String, dynamic> json) {
    return PromoCardCreateResult(
      cardId: json['cardId']?.toString() ?? '',
      providerCardId: json['providerCardId']?.toString(),
      reference: json['reference']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      initialLoadCents: (json['initialLoadCents'] as num?)?.toInt() ?? 0,
      creationFeeCents: (json['creationFeeCents'] as num?)?.toInt() ?? 0,
      totalChargedCents: (json['totalChargedCents'] as num?)?.toInt() ?? 0,
      sweepCents: (json['sweepCents'] as num?)?.toInt() ?? 0,
      referralRewardCents: (json['referralRewardCents'] as num?)?.toInt() ?? 0,
    );
  }
}
