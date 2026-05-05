import 'package:opei/core/money/money.dart';

/// Backend-computed activity summary (e.g. last 30 days totals).
///
/// API shape:
/// ```json
/// {
///   "totalIn": "250000",
///   "totalOut": "180000",
///   "net": "70000",
///   "currency": "USD",
///   "from": "2026-04-05T08:00:00.000Z",
///   "to":   "2026-05-05T08:00:00.000Z"
/// }
/// ```
///
/// Amounts are minor units (cents). The model keeps them as [Money]
/// values for clean formatting at the UI layer.
class TransactionSummary {
  final Money totalIn;
  final Money totalOut;
  final Money net;
  final String currency;
  final DateTime? from;
  final DateTime? to;

  const TransactionSummary({
    required this.totalIn,
    required this.totalOut,
    required this.net,
    required this.currency,
    this.from,
    this.to,
  });

  bool get isEmpty => totalIn.cents == 0 && totalOut.cents == 0;

  static TransactionSummary? tryParse(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;

    final currency = _readString(raw, const ['currency', 'currencyCode']) ?? 'USD';

    final inCents = _readCents(raw, const ['totalIn', 'total_in', 'in']);
    final outCents = _readCents(raw, const ['totalOut', 'total_out', 'out']);
    var netCents = _readCents(raw, const ['net', 'netAmount', 'net_amount']);

    if (inCents == null && outCents == null && netCents == null) {
      return null;
    }

    final inMoney = Money.fromCents(inCents ?? 0, currency: currency);
    final outMoney = Money.fromCents(outCents ?? 0, currency: currency);
    netCents ??= (inCents ?? 0) - (outCents ?? 0);
    final netMoney = Money.fromCents(netCents, currency: currency);

    DateTime? parseDate(String key) {
      final value = raw[key];
      if (value is String && value.trim().isNotEmpty) {
        return DateTime.tryParse(value)?.toLocal();
      }
      return null;
    }

    return TransactionSummary(
      totalIn: inMoney,
      totalOut: outMoney,
      net: netMoney,
      currency: currency,
      from: parseDate('from'),
      to: parseDate('to'),
    );
  }

  static String? _readString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  static int? _readCents(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      final parsed = _toNum(value);
      if (parsed != null) {
        if (parsed is double && (parsed % 1) != 0) {
          return (parsed * 100).round();
        }
        return parsed.round();
      }
    }
    return null;
  }

  static num? _toNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) {
      final sanitized = value.replaceAll(',', '').trim();
      if (sanitized.isEmpty) return null;
      return num.tryParse(sanitized);
    }
    return null;
  }
}
