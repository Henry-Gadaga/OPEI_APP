import 'package:tt1/core/money/money.dart';

/// Preview response for a card withdraw operation.
class CardWithdrawPreview {
  final bool canWithdraw;
  final Money withdrawAmount;
  final Money feeAmount;
  final Money netAmountToUser;
  final Money currentCardBalance;
  final Money cardBalanceAfter;
  final int? feeVersion;
  final String? reason; // optional backend-provided reason code when canWithdraw=false

  CardWithdrawPreview({
    required this.canWithdraw,
    required this.withdrawAmount,
    required this.feeAmount,
    required this.netAmountToUser,
    required this.currentCardBalance,
    required this.cardBalanceAfter,
    this.feeVersion,
    this.reason,
  });

  factory CardWithdrawPreview.fromJson(
    Map<String, dynamic> json, {
    String currency = 'USD',
    Money? fallbackAmount,
  }) {
    Money parseMoney(dynamic value, {Money? fallback}) {
      return Money.fromJson(
        value,
        currency: fallback?.currency ?? currency,
        fallbackCents: fallback?.cents,
      );
    }

    final resolvedAmount = parseMoney(
      json['withdrawAmount'] ?? json['amountCents'] ?? json['amount'],
      fallback: fallbackAmount,
    );

    return CardWithdrawPreview(
      canWithdraw: json['canWithdraw'] == true,
      withdrawAmount: resolvedAmount,
      feeAmount: parseMoney(json['feeAmount'] ?? json['feeCents'] ?? json['fee']),
      netAmountToUser: parseMoney(json['netAmountToUser'] ?? json['netAmountCents'] ?? json['net']),
      currentCardBalance: parseMoney(json['currentCardBalance'] ?? json['cardBalance'] ?? json['balance']),
      cardBalanceAfter: parseMoney(json['cardBalanceAfter'] ?? json['balanceAfter']),
      feeVersion: _parseInt(json['feeVersion']),
      reason: _parseString(json['reason']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    final parsed = value.toString().trim();
    return parsed.isEmpty ? null : parsed;
  }

  String? get reasonCode => reason?.trim().toUpperCase();

  Money get withdrawAmountMoney => withdrawAmount;
  Money get feeMoney => feeAmount;
  Money get netMoney => netAmountToUser;
  Money get cardBalanceMoney => currentCardBalance;
  Money get cardBalanceAfterMoney => cardBalanceAfter;
}
