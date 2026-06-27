class SupportedBank {
  final String uuid;
  final String name;

  const SupportedBank({required this.uuid, required this.name});

  factory SupportedBank.fromJson(Map<String, dynamic> json) {
    return SupportedBank(
      uuid: (json['uuid'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }
}

class BankWithdrawalPreview {
  final int amountUsdCents;
  final int feeUsdCents;
  final int totalDebitUsdCents;
  final String amountMwk;
  final String? fxRateId;
  final String? walletAvailableBalance;
  final bool canWithdraw;
  final Map<String, dynamic> raw;

  const BankWithdrawalPreview({
    required this.amountUsdCents,
    required this.feeUsdCents,
    required this.totalDebitUsdCents,
    required this.amountMwk,
    required this.canWithdraw,
    required this.raw,
    this.fxRateId,
    this.walletAvailableBalance,
  });

  factory BankWithdrawalPreview.fromJson(
    Map<String, dynamic> json, {
    required int fallbackAmountUsdCents,
  }) {
    return BankWithdrawalPreview(
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

class BankWithdrawalInitiation {
  final String payoutId;
  final String chargeId;
  final String status;
  final String amountUsdCents;
  final String amountMwk;
  final Map<String, dynamic> raw;

  const BankWithdrawalInitiation({
    required this.payoutId,
    required this.chargeId,
    required this.status,
    required this.amountUsdCents,
    required this.amountMwk,
    required this.raw,
  });

  factory BankWithdrawalInitiation.fromJson(Map<String, dynamic> json) {
    return BankWithdrawalInitiation(
      payoutId: (json['payoutId'] ?? '').toString(),
      chargeId: (json['chargeId'] ?? '').toString(),
      status: (json['status'] ?? '').toString().toUpperCase(),
      amountUsdCents: (json['amountUsdCents'] ?? '0').toString(),
      amountMwk: (json['amountMwk'] ?? '0').toString(),
      raw: json,
    );
  }
}

class BankWithdrawalStatus {
  final String payoutId;
  final String chargeId;
  final String status;
  final String amountUsdCents;
  final String amountMwk;
  final String? failureReason;
  final String? reviewReason;
  final Map<String, dynamic> raw;

  const BankWithdrawalStatus({
    required this.payoutId,
    required this.chargeId,
    required this.status,
    required this.amountUsdCents,
    required this.amountMwk,
    required this.raw,
    this.failureReason,
    this.reviewReason,
  });

  factory BankWithdrawalStatus.fromJson(Map<String, dynamic> json) {
    return BankWithdrawalStatus(
      payoutId: (json['payoutId'] ?? '').toString(),
      chargeId: (json['chargeId'] ?? '').toString(),
      status: (json['status'] ?? '').toString().toUpperCase(),
      amountUsdCents: (json['amountUsdCents'] ?? '0').toString(),
      amountMwk: (json['amountMwk'] ?? '0').toString(),
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
