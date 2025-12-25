import 'package:intl/intl.dart';

/// Value object that keeps monetary values in the smallest currency unit (cents).
class Money {
  final int cents;
  final String currency;

  const Money._(this.cents, this.currency);

  /// Safely coerces any backend numeric field into cents and wraps it as [Money].
  factory Money.fromJson(
    dynamic value, {
    String currency = 'USD',
    int? fallbackCents,
  }) {
    final resolvedCents = _coerceToCents(value, fallback: fallbackCents);
    return Money.fromCents(resolvedCents, currency: currency);
  }

  /// Creates a [Money] instance from an amount already expressed in cents.
  factory Money.fromCents(int cents, {String currency = 'USD'}) =>
      Money._(cents, currency.toUpperCase());

  /// Creates a [Money] instance from a major-unit amount (e.g. dollars).
  factory Money.fromMajor(num amount, {String currency = 'USD'}) => Money._(
        (amount * 100).round(),
        currency.toUpperCase(),
      );

  /// Parses a numeric string into [Money]. Accepts values in major units.
  factory Money.parse(String value, {String currency = 'USD'}) {
    final sanitized = value.replaceAll(',', '').trim();
    if (sanitized.isEmpty) {
      return Money.fromCents(0, currency: currency);
    }

    final asNum = num.tryParse(sanitized) ?? 0;
    return Money.fromMajor(asNum, currency: currency);
  }

  double get inMajorUnits => cents / 100;

  bool get isNegative => cents < 0;

  Money operator +(Money other) {
    _ensureSameCurrency(other);
    return Money.fromCents(cents + other.cents, currency: currency);
  }

  Money operator -(Money other) {
    _ensureSameCurrency(other);
    return Money.fromCents(cents - other.cents, currency: currency);
  }

  Money multiply(num factor) =>
      Money.fromCents((cents * factor).round(), currency: currency);

  Money negated() => Money.fromCents(-cents, currency: currency);

  Money abs() => isNegative ? negated() : this;

  /// Formats the amount using the provided locale and symbol preferences.
  String format({
    String? locale,
    bool includeCurrencySymbol = true,
    int? decimalDigits,
    bool showPlusForPositive = false,
  }) {
    final effectiveDigits = decimalDigits ?? _defaultDecimalDigits(currency);
    final format = NumberFormat.currency(
      locale: locale,
      symbol: includeCurrencySymbol ? _resolveSymbol(currency) : '',
      name: currency,
      decimalDigits: effectiveDigits,
    );

    final formatted = format.format(inMajorUnits);
    if (showPlusForPositive && cents > 0) {
      return '+$formatted';
    }
    return formatted;
  }

  @override
  String toString() =>
      'Money(currency: $currency, cents: $cents, major: ${inMajorUnits.toStringAsFixed(2)})';

  @override
  bool operator ==(Object other) =>
      other is Money && cents == other.cents && currency == other.currency;

  @override
  int get hashCode => Object.hash(cents, currency);

  void _ensureSameCurrency(Money other) {
    if (currency != other.currency) {
      throw ArgumentError('Currency mismatch: $currency vs ${other.currency}');
    }
  }

  static int _defaultDecimalDigits(String currency) {
    switch (currency) {
      case 'JPY':
      case 'KRW':
      case 'CLP':
      case 'VND':
        return 0;
      default:
        return 2;
    }
  }

  static String _resolveSymbol(String currency) {
    switch (currency) {
      case 'USD':
        return r'$';
      case 'NGN':
        return '₦';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'GHS':
        return '₵';
      case 'KES':
        return 'KSh';
      case 'UGX':
        return 'USh';
      default:
        final upper = currency.toUpperCase();
        return upper.length > 1 ? '$upper ' : upper;
    }
  }

  static int _coerceToCents(dynamic value, {int? fallback}) {
    if (value == null) {
      return fallback ?? 0;
    }

    if (value is Money) {
      return value.cents;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.round();
    }

    if (value is String) {
      final sanitized = value.trim();
      if (sanitized.isEmpty) {
        return fallback ?? 0;
      }

      final normalized = sanitized.replaceAll(',', '');

      final parsedInt = int.tryParse(normalized);
      if (parsedInt != null) {
        return parsedInt;
      }

      final parsedDouble = double.tryParse(normalized);
      if (parsedDouble != null) {
        return parsedDouble.round();
      }
    }

    return fallback ?? 0;
  }
}

extension MoneyFormatting on Money {
  /// Formats the monetary value and always prefixes a sign for non-zero values.
  String formatWithSign({
    String? locale,
    bool includeCurrencySymbol = true,
    int? decimalDigits,
  }) {
    final formatted = abs().format(
      locale: locale,
      includeCurrencySymbol: includeCurrencySymbol,
      decimalDigits: decimalDigits,
    );
    if (cents == 0) {
      return formatted;
    }
    return isNegative ? '-$formatted' : '+$formatted';
  }
}