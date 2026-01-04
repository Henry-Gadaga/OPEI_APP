import 'package:opei/core/money/money.dart';

/// Preview response for a card top-up operation.
class CardTopUpPreview {
  final bool canTopUp;
  final Money topUpAmount;
  final Money feeAmount;
  final Money totalDebit;
  final Money walletBalance;
  final Money walletBalanceAfter;
  final int? feeVersion;
  final String? reason;

  CardTopUpPreview({
    required this.canTopUp,
    required this.topUpAmount,
    required this.feeAmount,
    required this.totalDebit,
    required this.walletBalance,
    required this.walletBalanceAfter,
    this.feeVersion,
    this.reason,
  });

  factory CardTopUpPreview.fromJson(
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
      json['topupAmount'] ?? json['topUpAmount'] ?? json['amount'],
      fallback: fallbackAmount,
    );

    final resolvedFee = parseMoney(
      json['feeAmount'] ?? json['fee'],
      fallback: Money.fromCents(0, currency: currency),
    );

    return CardTopUpPreview(
      canTopUp: json['canTopup'] == true || json['canTopUp'] == true,
      topUpAmount: resolvedAmount,
      feeAmount: resolvedFee,
      totalDebit: parseMoney(
        json['totalDebit'] ?? json['totalDebitCents'] ?? json['total'],
        fallback: resolvedAmount + resolvedFee,
      ),
      walletBalance: parseMoney(json['walletBalance'] ?? json['balance']),
      walletBalanceAfter: parseMoney(json['walletBalanceAfter'] ?? json['balanceAfter']),
      feeVersion: _parseInt(json['feeVersion']),
      reason: _parseString(json['reason']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value.trim());
    }

    return null;
  }

  static String? _parseString(dynamic value) {
    if (value == null) {
      return null;
    }
    final parsed = value.toString().trim();
    return parsed.isEmpty ? null : parsed;
  }

  String? get reasonCode => reason?.trim().toUpperCase();

  Money get topUpAmountMoney => topUpAmount;
  Money get feeMoney => feeAmount;
  Money get totalDebitMoney => totalDebit;
  Money get walletBalanceMoney => walletBalance;
  Money get walletBalanceAfterMoney => walletBalanceAfter;
}