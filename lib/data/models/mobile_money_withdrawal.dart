class MobileMoneyWithdrawalPreview {
  final String channel;
  final String displayName;
  final int amountUsdCents;
  final int feeUsdCents;
  final int totalDebitUsdCents;
  final String amountMwk;
  final String? fxRateId;
  final String? walletAvailableBalance;
  final bool canWithdraw;
  final Map<String, dynamic> raw;

  const MobileMoneyWithdrawalPreview({
    required this.channel,
    required this.displayName,
    required this.amountUsdCents,
    required this.feeUsdCents,
    required this.totalDebitUsdCents,
    required this.amountMwk,
    required this.canWithdraw,
    required this.raw,
    this.fxRateId,
    this.walletAvailableBalance,
  });

  factory MobileMoneyWithdrawalPreview.fromJson(
    Map<String, dynamic> json, {
    required int fallbackAmountUsdCents,
    required String fallbackChannel,
  }) {
    return MobileMoneyWithdrawalPreview(
      channel: (json['channel'] ?? fallbackChannel).toString().toUpperCase(),
      displayName: (json['displayName'] ?? '').toString(),
      amountUsdCents: _toInt(json['amountUsdCents']) ?? fallbackAmountUsdCents,
      feeUsdCents: _toInt(json['feeUsdCents']) ?? 0,
      totalDebitUsdCents:
          _toInt(json['totalDebitUsdCents']) ?? fallbackAmountUsdCents,
      amountMwk: (json['amountMwk'] ?? '0').toString(),
      fxRateId: _toNullableString(json['fxRateId']),
      walletAvailableBalance: _toNullableString(json['walletAvailableBalance']),
      canWithdraw: json['canWithdraw'] == true,
      raw: json,
    );
  }
}

class MobileMoneyWithdrawalInitiation {
  final String payoutId;
  final String chargeId;
  final String status;
  final String amountUsdCents;
  final String amountMwk;
  final String channel;
  final Map<String, dynamic> raw;

  const MobileMoneyWithdrawalInitiation({
    required this.payoutId,
    required this.chargeId,
    required this.status,
    required this.amountUsdCents,
    required this.amountMwk,
    required this.channel,
    required this.raw,
  });

  factory MobileMoneyWithdrawalInitiation.fromJson(Map<String, dynamic> json) {
    return MobileMoneyWithdrawalInitiation(
      payoutId: (json['payoutId'] ?? '').toString(),
      chargeId: (json['chargeId'] ?? '').toString(),
      status: (json['status'] ?? '').toString().toUpperCase(),
      amountUsdCents: (json['amountUsdCents'] ?? '0').toString(),
      amountMwk: (json['amountMwk'] ?? '0').toString(),
      channel: (json['channel'] ?? '').toString().toUpperCase(),
      raw: json,
    );
  }
}

class MobileMoneyWithdrawalStatus {
  final String payoutId;
  final String chargeId;
  final String status;
  final String amountUsdCents;
  final String amountMwk;
  final String channel;
  final String? failureReason;
  final String? reviewReason;
  final Map<String, dynamic> raw;

  const MobileMoneyWithdrawalStatus({
    required this.payoutId,
    required this.chargeId,
    required this.status,
    required this.amountUsdCents,
    required this.amountMwk,
    required this.channel,
    required this.raw,
    this.failureReason,
    this.reviewReason,
  });

  factory MobileMoneyWithdrawalStatus.fromJson(Map<String, dynamic> json) {
    return MobileMoneyWithdrawalStatus(
      payoutId: (json['payoutId'] ?? '').toString(),
      chargeId: (json['chargeId'] ?? '').toString(),
      status: (json['status'] ?? '').toString().toUpperCase(),
      amountUsdCents: (json['amountUsdCents'] ?? '0').toString(),
      amountMwk: (json['amountMwk'] ?? '0').toString(),
      channel: (json['channel'] ?? '').toString().toUpperCase(),
      failureReason: _toNullableString(json['failureReason']),
      reviewReason: _toNullableString(json['reviewReason']),
      raw: json,
    );
  }

  bool get isTerminal =>
      status == 'SUCCESS' || status == 'FAILED' || status == 'REVIEW_REQUIRED';
}

int? _toInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

String? _toNullableString(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;
  return text;
}
