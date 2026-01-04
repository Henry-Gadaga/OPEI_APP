import 'package:opei/core/money/money.dart';

/// Represents a completed wallet transfer.
class TransferResponse {
  final String fromWalletId;
  final String? toWalletId;
  final String reference;
  final Money amount;
  final Money fromBalance;
  final String currency;

  TransferResponse({
    required this.fromWalletId,
    required this.reference,
    required this.amount,
    required this.fromBalance,
    required this.currency,
    this.toWalletId,
  });

  Money get amountMoney => amount;
  Money get fromBalanceMoney => fromBalance;

  factory TransferResponse.fromJson(
    Map<String, dynamic> json, {
    Money? fallbackAmount,
    Money? fallbackFromBalance,
    String? fallbackCurrency,
  }) {
    dynamic readValue(List<String> keys) {
      for (final key in keys) {
        if (json.containsKey(key) && json[key] != null) {
          return json[key];
        }
      }
      return null;
    }

    int parseIntField(dynamic value, {int? fallback}) {
      if (value == null) {
        return fallback ?? 0;
      }

      if (value is int) return value;
      if (value is num) return value.toInt();

      if (value is String) {
        final sanitized = value.trim();

        if (sanitized.isEmpty) {
          return fallback ?? 0;
        }

        final normalized = sanitized.replaceAll(',', '');

        final parsedInt = int.tryParse(normalized);
        if (parsedInt != null) return parsedInt;

        final parsedDouble = double.tryParse(normalized);
        if (parsedDouble != null) return parsedDouble.round();

        return fallback ?? 0;
      }

      return fallback ?? 0;
    }

    String parseString(dynamic value, {String fallback = ''}) {
      if (value == null) return fallback;
      return value.toString();
    }

    final amountValue = readValue([
      'amount',
      'transferAmount',
      'transfer_amount',
      'amountInCents',
      'amount_cents',
    ]);

    final fromBalanceValue = readValue([
      'fromBalance',
      'senderBalanceAfter',
      'fromBalanceAfter',
      'balanceAfter',
      'currentBalance',
      'sender_balance_after',
    ]);

    final fromWalletValue = readValue(['fromWalletId', 'from_wallet_id']);
    final toWalletValue = readValue(['toWalletId', 'to_wallet_id']);
    final referenceValue = readValue(['reference', 'referenceId', 'reference_id']);

    final parsedToWallet = parseString(toWalletValue, fallback: '');
    final currencyValue = readValue([
      'currency',
      'currencyCode',
      'currency_code',
    ]);

    final resolvedCurrency = parseString(
      currencyValue,
      fallback: fallbackAmount?.currency ??
          fallbackFromBalance?.currency ??
          fallbackCurrency ??
          'USD',
    ).toUpperCase();

    final amountCents = parseIntField(
      amountValue,
      fallback: fallbackAmount?.cents,
    );

    final fromBalanceCents = parseIntField(
      fromBalanceValue,
      fallback: fallbackFromBalance?.cents,
    );

    return TransferResponse(
      fromWalletId: parseString(fromWalletValue),
      toWalletId: parsedToWallet.isEmpty ? null : parsedToWallet,
      reference: parseString(referenceValue),
      amount: Money.fromCents(amountCents, currency: resolvedCurrency),
      fromBalance: Money.fromCents(fromBalanceCents, currency: resolvedCurrency),
      currency: resolvedCurrency,
    );
  }

  Map<String, dynamic> toJson() => {
        'fromWalletId': fromWalletId,
        'toWalletId': toWalletId,
        'reference': reference,
        'amount': amount.cents,
        'fromBalance': fromBalance.cents,
        'currency': currency,
      };
}