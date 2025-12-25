import 'package:tt1/core/money/money.dart';

class CardDetails {
  final String cardNumber;
  final String cvv;
  final Money? balance;

  const CardDetails({
    required this.cardNumber,
    required this.cvv,
    this.balance,
  });

  factory CardDetails.fromJson(
    Map<String, dynamic> json, {
    required String currency,
    Money? fallbackBalance,
  }) {
    final cardNumber = _readString(json, const [
      'cardNumber',
      'card_number',
      'number',
      'pan',
      'primaryAccountNumber',
      'primary_account_number',
    ]);

    final cvv = _readString(json, const [
      'cvv',
      'cvv2',
      'cardCvv',
      'card_cvv',
      'securityCode',
      'security_code',
    ]);

    final balance = _resolveBalance(json['balance'], currency, fallbackBalance);

    return CardDetails(
      cardNumber: cardNumber,
      cvv: cvv,
      balance: balance,
    );
  }

  static String _readString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      if (!json.containsKey(key)) continue;
      final value = json[key];
      if (value == null) continue;

      if (value is String) {
        final trimmed = value.trim();
        if (trimmed.isNotEmpty) {
          return trimmed;
        }
      } else if (value is num || value is bool) {
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
    }
    return '';
  }

  static Money? _resolveBalance(
    dynamic raw,
    String currency,
    Money? fallback,
  ) {
    if (raw == null) {
      return fallback;
    }

    if (raw is Money) {
      return Money.fromCents(raw.cents, currency: raw.currency);
    }

    if (raw is Map<String, dynamic>) {
      final nestedMoney = _extractMoneyFromMap(raw, currency, fallback);
      if (nestedMoney != null) {
        return nestedMoney;
      }
    }

    return Money.fromJson(
      raw,
      currency: currency,
      fallbackCents: fallback?.cents,
    );
  }

  static Money? _extractMoneyFromMap(
    Map<String, dynamic> source,
    String currency,
    Money? fallback,
  ) {
    final centsCandidate = _firstNonNull(source, const [
      'centAmount',
      'amountInCents',
      'amount_cents',
      'amountCent',
      'minor',
      'value',
      'balanceInCents',
      'availableBalanceInCents',
      'available_cents',
      'cents',
    ]);

    if (centsCandidate != null) {
      final coerced = _coerceMoneyFromCents(centsCandidate, currency);
      if (coerced != null) {
        return coerced;
      }
    }

    final majorCandidate = _firstNonNull(source, const [
      'amount',
      'balance',
      'major',
      'available',
      'availableBalance',
    ]);

    if (majorCandidate != null) {
      final coerced = _coerceMoneyFromMajor(majorCandidate, currency);
      if (coerced != null) {
        return coerced;
      }
    }

    final nestedBalance = _firstNonNull(source, const [
      'data',
      'attributes',
      'result',
    ]);

    if (nestedBalance is Map<String, dynamic>) {
      return _extractMoneyFromMap(nestedBalance, currency, fallback);
    }

    return fallback;
  }

  static dynamic _firstNonNull(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    for (final key in keys) {
      if (source.containsKey(key) && source[key] != null) {
        return source[key];
      }
    }
    return null;
  }

  static Money? _coerceMoneyFromCents(
    dynamic value,
    String currency,
  ) {
    final cents = _coerceToInt(value);
    if (cents == null) {
      return null;
    }
    return Money.fromCents(cents, currency: currency);
  }

  static Money? _coerceMoneyFromMajor(
    dynamic value,
    String currency,
  ) {
    final amount = _coerceToNum(value);
    if (amount == null) {
      return null;
    }
    return Money.fromMajor(amount, currency: currency);
  }

  static int? _coerceToInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    if (value is String) {
      final sanitized = value.replaceAll(',', '').trim();
      if (sanitized.isEmpty) {
        return null;
      }
      final parsedInt = int.tryParse(sanitized);
      if (parsedInt != null) {
        return parsedInt;
      }
      final parsedDouble = double.tryParse(sanitized);
      if (parsedDouble != null) {
        return parsedDouble.round();
      }
    }
    return null;
  }

  static num? _coerceToNum(dynamic value) {
    if (value is num) {
      return value;
    }
    if (value is String) {
      final sanitized = value.replaceAll(',', '').trim();
      if (sanitized.isEmpty) {
        return null;
      }
      return num.tryParse(sanitized);
    }
    return null;
  }
}