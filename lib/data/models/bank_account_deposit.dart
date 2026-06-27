class BankAccountDetails {
  final String id;
  final String userId;
  final String bankName;
  final String accountNumber;
  final String accountName;
  final bool isPermanent;
  final bool isActive;

  const BankAccountDetails({
    required this.id,
    required this.userId,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.isPermanent,
    required this.isActive,
  });

  factory BankAccountDetails.fromJson(Map<String, dynamic> json) {
    return BankAccountDetails(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      bankName: (json['bankName'] ?? '').toString(),
      accountNumber: (json['accountNumber'] ?? '').toString(),
      accountName: (json['accountName'] ?? '').toString(),
      isPermanent: json['isPermanent'] != false,
      isActive: json['isActive'] != false,
    );
  }
}

class BankAccountPreview {
  final bool alreadyHasAccount;
  final int feeUsdCents;
  final int walletAvailableBalance;
  final bool canAfford;
  final BankAccountDetails? account;
  final Map<String, dynamic> raw;

  const BankAccountPreview({
    required this.alreadyHasAccount,
    required this.feeUsdCents,
    required this.walletAvailableBalance,
    required this.canAfford,
    required this.account,
    required this.raw,
  });

  factory BankAccountPreview.fromJson(Map<String, dynamic> json) {
    final accountJson = json['account'];
    return BankAccountPreview(
      alreadyHasAccount: json['alreadyHasAccount'] == true,
      feeUsdCents: _toInt(json['feeUsdCents']) ?? 0,
      walletAvailableBalance: _toInt(json['walletAvailableBalance']) ?? 0,
      canAfford: json['canAfford'] == true,
      account: accountJson is Map<String, dynamic>
          ? BankAccountDetails.fromJson(accountJson)
          : null,
      raw: json,
    );
  }
}

class BankAccountCreateResult {
  final bool created;
  final int feeChargedUsdCents;
  final BankAccountDetails account;
  final Map<String, dynamic> raw;

  const BankAccountCreateResult({
    required this.created,
    required this.feeChargedUsdCents,
    required this.account,
    required this.raw,
  });

  factory BankAccountCreateResult.fromJson(Map<String, dynamic> json) {
    return BankAccountCreateResult(
      created: json['created'] == true,
      feeChargedUsdCents: _toInt(json['feeChargedUsdCents']) ?? 0,
      account: BankAccountDetails.fromJson(_toMap(json['account'])),
      raw: json,
    );
  }
}

int? _toInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

Map<String, dynamic> _toMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return const <String, dynamic>{};
}
