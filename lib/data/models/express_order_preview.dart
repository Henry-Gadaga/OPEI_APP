import 'package:opei/data/models/express_order.dart';

/// Result of `POST /p2p/express-orders/preview` — a non-binding quote.
///
/// `fiatAmountCents = (amountUsdCents * lockedRateCents) / 100`. The rate is
/// only locked when an order is actually created.
class ExpressOrderPreview {
  final ExpressMethodType paymentMethodType;
  final int amountUsdCents;
  final int lockedRateCents;
  final int fiatAmountCents;
  final String quoteCurrency;
  final String baseCurrency;

  const ExpressOrderPreview({
    required this.paymentMethodType,
    required this.amountUsdCents,
    required this.lockedRateCents,
    required this.fiatAmountCents,
    required this.quoteCurrency,
    required this.baseCurrency,
  });

  factory ExpressOrderPreview.fromJson(Map<String, dynamic> json) {
    return ExpressOrderPreview(
      paymentMethodType: ExpressMethodType.fromJson(
        json['paymentMethodType'] as Map<String, dynamic>?,
      ),
      amountUsdCents: _toCents(json['amountUsdCents']),
      lockedRateCents: _toCents(json['lockedRateCents']),
      fiatAmountCents: _toCents(json['fiatAmountCents']),
      quoteCurrency: (json['quoteCurrency'] ?? '').toString().toUpperCase(),
      baseCurrency:
          (json['baseCurrency'] ?? 'USD').toString().toUpperCase(),
    );
  }

  static int _toCents(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.round();
    final parsed = int.tryParse(value.toString().trim());
    if (parsed != null) return parsed;
    final asDouble = double.tryParse(value.toString().trim());
    return asDouble?.round() ?? 0;
  }
}
