import 'package:opei/core/money/money.dart';

enum P2PAdType { buy, sell;

  String get apiValue => name.toUpperCase();

  String get displayLabel => name == 'buy' ? 'Buy' : 'Sell';

  P2PAdType get counterpart => this == P2PAdType.buy ? P2PAdType.sell : P2PAdType.buy;

  static P2PAdType fromBackend(String value) {
    final normalized = value.trim().toUpperCase();
    return normalized == 'SELL' ? P2PAdType.sell : P2PAdType.buy;
  }
}

class P2PAdPaymentMethod {
  final String id;
  final String providerName;
  final String methodType;
  final String currency;

  const P2PAdPaymentMethod({
    required this.id,
    required this.providerName,
    required this.methodType,
    required this.currency,
  });

  factory P2PAdPaymentMethod.fromJson(Map<String, dynamic>? json, String fallbackCurrency) {
    if (json == null) {
      return P2PAdPaymentMethod(
        id: '',
        providerName: 'Unknown Method',
        methodType: 'OTHER',
        currency: fallbackCurrency,
      );
    }

    final providerRaw = json['providerName'];
    final provider = providerRaw is String
        ? providerRaw.trim()
        : providerRaw != null
            ? providerRaw.toString().trim()
            : '';

    final methodTypeRaw = json['methodType'];
    final methodType = methodTypeRaw is String
        ? methodTypeRaw.trim().toUpperCase()
        : methodTypeRaw != null
            ? methodTypeRaw.toString().trim().toUpperCase()
            : '';

    final currencyRaw = json['currency'];

    return P2PAdPaymentMethod(
      id: (json['id'] ?? '').toString(),
      providerName: provider.isEmpty ? 'Unknown Method' : provider,
      methodType: methodType.isEmpty ? 'OTHER' : methodType,
      currency: currencyRaw == null
          ? fallbackCurrency
          : currencyRaw.toString().trim().isEmpty
              ? fallbackCurrency
              : currencyRaw.toString().toUpperCase(),
    );
  }

  String get displayLabel {
    final typeLabel = _humanizeMethodType(methodType);

    if (providerName.isEmpty && typeLabel.isEmpty) {
      return 'Payment method';
    }

    if (providerName.isEmpty) {
      return typeLabel;
    }

    if (typeLabel.isEmpty || typeLabel.toLowerCase() == providerName.toLowerCase()) {
      return providerName;
    }

    return '$providerName · $typeLabel';
  }

  String _humanizeMethodType(String raw) {
    if (raw.isEmpty) {
      return '';
    }

    final parts = raw
        .split(RegExp(r'[ _]+'))
        .where((segment) => segment.trim().isNotEmpty)
        .map((segment) {
          final lower = segment.toLowerCase();
          return lower[0].toUpperCase() + lower.substring(1);
        })
        .toList(growable: false);

    return parts.join(' ');
  }
}

class P2PAdSeller {
  final String id;
  final String displayName;
  final String nickname;
  final double rating;
  final int totalTrades;

  const P2PAdSeller({
    required this.id,
    required this.displayName,
    required this.nickname,
    required this.rating,
    required this.totalTrades,
  });

  factory P2PAdSeller.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const P2PAdSeller(
        id: '',
        displayName: 'Unknown trader',
        nickname: '',
        rating: 0,
        totalTrades: 0,
      );
    }

    final idRaw = json['id'];
    final displayNameRaw = json['displayName'];
    final nicknameRaw = json['nickname'];
    final ratingRaw = json['rating'];
    final tradesRaw = json['totalTrades'];

    double resolveRating(dynamic value) {
      if (value is int) {
        return value.toDouble();
      }
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        return double.tryParse(value) ?? 0;
      }
      return 0;
    }

    int resolveTrades(dynamic value) {
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    final ratingValue = resolveRating(ratingRaw);
    final tradesValue = resolveTrades(tradesRaw);

    return P2PAdSeller(
      id: (idRaw ?? '').toString(),
      displayName: (displayNameRaw ?? '').toString().trim().isEmpty
          ? 'Unknown trader'
          : (displayNameRaw ?? '').toString().trim(),
      nickname: (nicknameRaw ?? '').toString().trim(),
      rating: ratingValue < 0
          ? 0
          : ratingValue > 5
              ? 5
              : ratingValue,
      totalTrades: tradesValue < 0
          ? 0
          : tradesValue > 999999
              ? 999999
              : tradesValue,
    );
  }

  String get preferredName => nickname.isNotEmpty ? nickname : displayName;

  bool get hasRating => rating > 0;
}

class P2PAd {
  final String id;
  final String userId;
  final P2PAdType type;
  final String currency;
  final Money totalAmount;
  final Money remainingAmount;
  final Money minOrder;
  final Money maxOrder;
  final Money rate;
  final String instructions;
  final String status;
  final List<P2PAdPaymentMethod> paymentMethods;
  final P2PAdSeller seller;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const P2PAd({
    required this.id,
    required this.userId,
    required this.type,
    required this.currency,
    required this.totalAmount,
    required this.remainingAmount,
    required this.minOrder,
    required this.maxOrder,
    required this.rate,
    required this.instructions,
    required this.status,
    required this.paymentMethods,
    required this.seller,
    this.createdAt,
    this.updatedAt,
  });

  factory P2PAd.fromJson(Map<String, dynamic> json) {
    // Backend contract: min/max/available are in USD cents; rate is in local currency.
    final localCurrency = (json['currency'] ?? 'USD').toString().toUpperCase();
    final paymentMethodsRaw = json['paymentMethods'];

    List<P2PAdPaymentMethod> parsedMethods = [];
    if (paymentMethodsRaw is List && paymentMethodsRaw.isNotEmpty) {
      parsedMethods = paymentMethodsRaw
          .map((item) => P2PAdPaymentMethod.fromJson(item as Map<String, dynamic>?, localCurrency))
          .toList();
    }

    return P2PAd(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      type: P2PAdType.fromBackend((json['type'] ?? 'BUY').toString()),
      // Keep ad.currency as local currency for display of rate and payment methods
      currency: localCurrency,
      // These amounts are USD-based regardless of ad.currency
      totalAmount: Money.fromJson(json['totalAmountCents'], currency: 'USD'),
      remainingAmount: Money.fromJson(json['remainingAmountCents'], currency: 'USD'),
      minOrder: Money.fromJson(json['minOrderCents'], currency: 'USD'),
      maxOrder: Money.fromJson(json['maxOrderCents'], currency: 'USD'),
      // Rate is quoted in local currency per 1 USD
      rate: Money.fromJson(json['rateCents'], currency: localCurrency),
      instructions: (json['instructions'] ?? '').toString().trim(),
      status: (json['status'] ?? '').toString().trim(),
      paymentMethods: parsedMethods,
      seller: P2PAdSeller.fromJson(json['seller'] as Map<String, dynamic>?),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  String get statusLabel {
    final trimmed = status.trim();
    if (trimmed.isEmpty) {
      return '—';
    }
    return trimmed
        .split(RegExp(r'[_\s-]+'))
        .where((segment) => segment.isNotEmpty)
        .map((segment) => segment[0].toUpperCase() + segment.substring(1).toLowerCase())
        .join(' ');
  }

  String get paymentMethodsDisplay {
    if (paymentMethods.isEmpty) {
      return 'No payment method';
    }
    if (paymentMethods.length == 1) {
      return paymentMethods.first.providerName;
    }
    return '${paymentMethods.length} methods';
  }
}