class SavedMobileNumber {
  final String id;
  final String userId;
  final String name;
  final String channel;
  final String mobileRaw;
  final String mobileNormalized;
  final bool isPrimary;
  final bool isActive;
  final DateTime? lastUsedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SavedMobileNumber({
    required this.id,
    required this.userId,
    required this.name,
    required this.channel,
    required this.mobileRaw,
    required this.mobileNormalized,
    required this.isPrimary,
    required this.isActive,
    this.lastUsedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory SavedMobileNumber.fromJson(Map<String, dynamic> json) {
    return SavedMobileNumber(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      channel: (json['channel'] ?? '').toString().toUpperCase(),
      mobileRaw: (json['mobileRaw'] ?? '').toString(),
      mobileNormalized: (json['mobileNormalized'] ?? '').toString(),
      isPrimary: json['isPrimary'] == true,
      isActive: json['isActive'] != false,
      lastUsedAt: DateTime.tryParse((json['lastUsedAt'] ?? '').toString()),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()),
    );
  }
}

class MobileMoneyDepositPreview {
  final int amountUsdCents;
  final String channel;
  final String? amountMwk;
  final Map<String, dynamic> raw;

  const MobileMoneyDepositPreview({
    required this.amountUsdCents,
    required this.channel,
    required this.raw,
    this.amountMwk,
  });

  factory MobileMoneyDepositPreview.fromJson(
    Map<String, dynamic> json, {
    required int fallbackAmountUsdCents,
    required String fallbackChannel,
  }) {
    final amountRaw = json['amountUsdCents'] ?? json['amountUSDCents'];
    final amountUsdCents = _toInt(amountRaw) ?? fallbackAmountUsdCents;
    return MobileMoneyDepositPreview(
      amountUsdCents: amountUsdCents,
      channel: (json['channel'] ?? fallbackChannel).toString().toUpperCase(),
      amountMwk: json['amountMwk']?.toString(),
      raw: json,
    );
  }
}

class MobileMoneyDepositInitiation {
  final String transactionId;
  final String chargeId;
  final String status;
  final int amountUsdCents;
  final String? amountMwk;
  final String channel;
  final Map<String, dynamic> raw;

  const MobileMoneyDepositInitiation({
    required this.transactionId,
    required this.chargeId,
    required this.status,
    required this.amountUsdCents,
    required this.channel,
    required this.raw,
    this.amountMwk,
  });

  factory MobileMoneyDepositInitiation.fromJson(Map<String, dynamic> json) {
    return MobileMoneyDepositInitiation(
      transactionId: (json['transactionId'] ?? '').toString(),
      chargeId: (json['chargeId'] ?? '').toString(),
      status: (json['status'] ?? '').toString().toUpperCase(),
      amountUsdCents: _toInt(json['amountUsdCents']) ?? 0,
      amountMwk: json['amountMwk']?.toString(),
      channel: (json['channel'] ?? '').toString().toUpperCase(),
      raw: json,
    );
  }
}

class MobileMoneyDepositStatus {
  final String transactionId;
  final String chargeId;
  final String status;
  final String amountUsdCents;
  final String amountMwk;
  final String channel;
  final String? failureReason;
  final Map<String, dynamic> raw;

  const MobileMoneyDepositStatus({
    required this.transactionId,
    required this.chargeId,
    required this.status,
    required this.amountUsdCents,
    required this.amountMwk,
    required this.channel,
    required this.raw,
    this.failureReason,
  });

  factory MobileMoneyDepositStatus.fromJson(Map<String, dynamic> json) {
    return MobileMoneyDepositStatus(
      transactionId: (json['transactionId'] ?? '').toString(),
      chargeId: (json['chargeId'] ?? '').toString(),
      status: (json['status'] ?? '').toString().toUpperCase(),
      amountUsdCents: (json['amountUsdCents'] ?? '0').toString(),
      amountMwk: (json['amountMwk'] ?? '0').toString(),
      channel: (json['channel'] ?? '').toString().toUpperCase(),
      failureReason: _toNullableString(json['failureReason']),
      raw: json,
    );
  }

  bool get isTerminal =>
      status == 'SUCCESS_CREDITED' ||
      status == 'FAILED' ||
      status == 'REVIEW_REQUIRED';
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
