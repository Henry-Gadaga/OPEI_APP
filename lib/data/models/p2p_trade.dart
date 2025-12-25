import 'package:tt1/core/money/money.dart';
import 'package:tt1/data/models/p2p_ad.dart';

DateTime? _parseDate(dynamic value) {
  if (value is DateTime) {
    return value;
  }
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

int _parseCents(dynamic value) {
  if (value == null) {
    return 0;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.round();
  }
  if (value is String) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return 0;
    }
    final parsed = int.tryParse(normalized);
    if (parsed != null) {
      return parsed;
    }
    final asDouble = double.tryParse(normalized);
    if (asDouble != null) {
      return asDouble.round();
    }
  }
  return 0;
}

enum P2PTradeStatus {
  initiated('INITIATED'),
  paidByBuyer('PAID_BY_BUYER'),
  releasedBySeller('RELEASED_BY_SELLER'),
  completed('COMPLETED'),
  cancelled('CANCELLED'),
  disputed('DISPUTED'),
  expired('EXPIRED');

  const P2PTradeStatus(this.apiValue);

  final String apiValue;

  String get displayLabel {
    // Custom human labels. Keep INITIATED as “Active”. Others default to title case.
     if (this == P2PTradeStatus.initiated) return 'Pending payment';
    return apiValue
        .split('_')
        .map((segment) => segment.isEmpty
            ? ''
            : segment[0].toUpperCase() + segment.substring(1).toLowerCase())
        .join(' ');
  }

  bool get isTerminal {
    switch (this) {
      case P2PTradeStatus.initiated:
      case P2PTradeStatus.paidByBuyer:
      case P2PTradeStatus.releasedBySeller:
        return false;
      case P2PTradeStatus.completed:
      case P2PTradeStatus.cancelled:
      case P2PTradeStatus.disputed:
      case P2PTradeStatus.expired:
        return true;
    }
  }

  static P2PTradeStatus fromBackend(String? value) {
    final normalized = (value ?? '').trim().toUpperCase();
    for (final status in P2PTradeStatus.values) {
      if (status.apiValue == normalized) {
        return status;
      }
    }
    return P2PTradeStatus.initiated;
  }
}

class P2PTradePaymentMethod {
  final String id;
  final String providerName;
  final String methodType;
  final String currency;
  final String accountName;
  final String accountNumber;
  final String? accountNumberMasked;
  final String? extraDetails;
  final String? userPaymentMethodId;

  const P2PTradePaymentMethod({
    required this.id,
    required this.providerName,
    required this.methodType,
    required this.currency,
    required this.accountName,
    required this.accountNumber,
    this.accountNumberMasked,
    this.extraDetails,
    this.userPaymentMethodId,
  });

  factory P2PTradePaymentMethod.fromJson(
    Map<String, dynamic>? json, {
    required String fallbackCurrency,
  }) {
    if (json == null) {
      return P2PTradePaymentMethod(
        id: '',
        providerName: 'Unknown method',
        methodType: 'OTHER',
        currency: fallbackCurrency,
        accountName: 'Account',
        accountNumber: '',
        accountNumberMasked: null,
        extraDetails: null,
        userPaymentMethodId: null,
      );
    }

    String _resolveString(dynamic value) {
      if (value == null) return '';
      return value.toString().trim();
    }

    final methodType = _resolveString(json['methodType']).toUpperCase();
    final currencyRaw = _resolveString(json['currency']);
    final accountNumber = _resolveString(json['accountNumber']);
    final accountNumberMasked = json.containsKey('accountNumberMasked') && _resolveString(json['accountNumberMasked']).isNotEmpty
        ? _resolveString(json['accountNumberMasked'])
        : null;

    return P2PTradePaymentMethod(
      id: _resolveString(json['id']),
      providerName: _resolveString(json['providerName']).isEmpty
          ? 'Unknown method'
          : _resolveString(json['providerName']),
      methodType: methodType.isEmpty ? 'OTHER' : methodType,
      currency: currencyRaw.isEmpty ? fallbackCurrency : currencyRaw.toUpperCase(),
      accountName: _resolveString(json['accountName']).isEmpty
          ? 'Account'
          : _resolveString(json['accountName']),
      accountNumber: accountNumber,
      accountNumberMasked: accountNumberMasked,
      extraDetails: json['extraDetails'] is String && json['extraDetails'].toString().trim().isNotEmpty
          ? json['extraDetails'].toString().trim()
          : null,
      userPaymentMethodId: _resolveString(json['userPaymentMethodId']).isEmpty
          ? null
          : _resolveString(json['userPaymentMethodId']),
    );
  }
}

class P2PTradeAdSummary {
  final String id;
  final P2PAdType type;
  final String currency;
  final Money rate;
  final List<P2PAdPaymentMethod> paymentMethods;

  const P2PTradeAdSummary({
    required this.id,
    required this.type,
    required this.currency,
    required this.rate,
    required this.paymentMethods,
  });

  factory P2PTradeAdSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return P2PTradeAdSummary(
        id: '',
        type: P2PAdType.sell,
        currency: 'USD',
        rate: Money.fromCents(0),
        paymentMethods: const <P2PAdPaymentMethod>[],
      );
    }

    final currency = (json['currency'] ?? 'USD').toString().toUpperCase();
    final methodsRaw = json['paymentMethods'];
    List<P2PAdPaymentMethod> paymentMethods = const [];

    if (methodsRaw is List) {
      paymentMethods = methodsRaw
          .whereType<Map<String, dynamic>>()
          .map((item) => P2PAdPaymentMethod.fromJson(item, currency))
          .toList(growable: false);
    }

    return P2PTradeAdSummary(
      id: (json['id'] ?? '').toString(),
      type: P2PAdType.fromBackend((json['type'] ?? 'SELL').toString()),
      currency: currency,
      rate: Money.fromJson(json['rateCents'], currency: currency),
      paymentMethods: paymentMethods,
    );
  }

  String get typeLabel => type == P2PAdType.sell ? 'Sell' : 'Buy';
}

class P2PTradeProof {
  final String id;
  final String url;
  final String? note;
  final String uploadedById;
  final DateTime? createdAt;

  const P2PTradeProof({
    required this.id,
    required this.url,
    required this.uploadedById,
    this.note,
    this.createdAt,
  });

  factory P2PTradeProof.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const P2PTradeProof(
        id: '',
        url: '',
        uploadedById: '',
        note: null,
        createdAt: null,
      );
    }

    String _s(dynamic v) => (v ?? '').toString().trim();

    return P2PTradeProof(
      id: _s(json['id']),
      // Some backends return `publicUrl` or `fileUrl` instead of `url`.
      url: _s(json['url'] ?? json['publicUrl'] ?? json['fileUrl']),
      note: json['note'] is String && json['note'].toString().trim().isNotEmpty
          ? json['note'].toString().trim()
          : null,
      uploadedById: _s(json['uploadedById']),
      createdAt: _parseDate(json['createdAt']),
    );
  }
}

class P2PTradeRating {
  final String id;
  final String tradeId;
  final String ratedUserId;
  final String ratedById;
  final int score;
  final String? role;
  final String? comment;
  final List<String> tags;
  final DateTime? createdAt;

  const P2PTradeRating({
    required this.id,
    required this.tradeId,
    required this.ratedUserId,
    required this.ratedById,
    required this.score,
    this.role,
    this.comment,
    this.tags = const <String>[],
    this.createdAt,
  });

  const P2PTradeRating.empty()
      : id = '',
        tradeId = '',
        ratedUserId = '',
        ratedById = '',
        score = 0,
        role = null,
        comment = null,
        tags = const <String>[],
        createdAt = null;

  factory P2PTradeRating.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const P2PTradeRating.empty();
    }

    String _s(dynamic value) => (value ?? '').toString().trim();

    int _score(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.round();
      if (value is String) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null) {
          return parsed;
        }
      }
      return 0;
    }

    final tagsRaw = json['tags'];
    final tags = tagsRaw is List
        ? tagsRaw
            .whereType<String>()
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList(growable: false)
        : const <String>[];

    return P2PTradeRating(
      id: _s(json['id']),
      tradeId: _s(json['tradeId']),
      ratedUserId: _s(json['ratedUserId']),
      ratedById: _s(json['ratedById']),
      score: _score(json['score']),
      role: json['role'] is String ? json['role'].toString().trim().toUpperCase() : null,
      comment: json['comment'] is String && json['comment'].toString().trim().isNotEmpty
          ? json['comment'].toString().trim()
          : null,
      tags: tags,
      createdAt: _parseDate(json['createdAt']),
    );
  }

  bool get isValid => score > 0;
}

class P2PTrade {
  final String id;
  final String adId;
  final String buyerId;
  final String sellerId;
  final Money amount;
  final Money? sendAmount;
  final Money rate;
  final String currency;
  final P2PTradeStatus status;
  final DateTime? expiresAt;
  final DateTime? paidAt;
  final DateTime? releasedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancelReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final P2PTradeAdSummary ad;
  final P2PTradePaymentMethod? selectedPaymentMethod;
  final List<P2PTradeProof> proofs;
  final P2PTradeRating? yourRating;
  final bool canRate;
  final bool ratingPending;
  final bool isRatedByMe;

  const P2PTrade({
    required this.id,
    required this.adId,
    required this.buyerId,
    required this.sellerId,
    required this.amount,
    required this.rate,
    required this.currency,
    this.sendAmount,
    required this.status,
    required this.expiresAt,
    required this.paidAt,
    required this.releasedAt,
    required this.completedAt,
    required this.cancelledAt,
    required this.cancelReason,
    required this.createdAt,
    required this.updatedAt,
    required this.ad,
    required this.selectedPaymentMethod,
    this.proofs = const <P2PTradeProof>[],
    this.yourRating,
    this.canRate = false,
    this.ratingPending = false,
    this.isRatedByMe = false,
  });

  factory P2PTrade.fromJson(Map<String, dynamic> json) {
    final currency = (json['currency'] ?? 'USD').toString().toUpperCase();
    final amountCents = _parseCents(json['amountCents']);
    final sendAmountCents = _parseCents(json['sendAmountCents']);
    final rateCents = _parseCents(json['rateCents']);

    final selectedMethod = json['selectedPaymentMethod'] is Map<String, dynamic>
        ? P2PTradePaymentMethod.fromJson(
            json['selectedPaymentMethod'] as Map<String, dynamic>,
            fallbackCurrency: currency,
          )
        : null;

    Money? _parseSendAmount() {
      if (sendAmountCents <= 0) {
        return null;
      }
      final sendCurrencyRaw = (json['sendCurrency'] ?? json['sendAmountCurrency'] ?? json['payoutCurrency'] ?? json['currency'])
          .toString()
          .trim()
          .toUpperCase();
      final sendCurrency = sendCurrencyRaw.isEmpty ? currency : sendCurrencyRaw;
      return Money.fromCents(sendAmountCents, currency: sendCurrency);
    }

    P2PTradeRating? _parseUserRating() {
      final ratingRaw = json['yourRating'] ?? json['myRating'] ?? json['rating'];
      final parsed = P2PTradeRating.fromJson(ratingRaw is Map<String, dynamic> ? ratingRaw : null);
      return parsed.isValid ? parsed : null;
    }

    bool _parseCanRate(P2PTradeStatus status, P2PTradeRating? rating) {
      if (rating?.isValid ?? false) {
        return false;
      }
      if (json['canRate'] is bool) {
        return json['canRate'] as bool;
      }
      if (json['allowRating'] is bool) {
        return json['allowRating'] as bool;
      }
      if (json['pendingRating'] is bool) {
        return json['pendingRating'] as bool;
      }
      if (json['ratingPending'] is bool) {
        return json['ratingPending'] as bool;
      }
      // Fallback: allow rating once seller released/completed.
      return status == P2PTradeStatus.releasedBySeller || status == P2PTradeStatus.completed;
    }

    bool _parsePending() {
      if (json['ratingPending'] is bool) {
        return json['ratingPending'] as bool;
      }
      if (json['pendingRating'] is bool) {
        return json['pendingRating'] as bool;
      }
      return false;
    }

    bool _parseRatedByMe() {
      final raw = json.containsKey('isRatedByMe')
          ? json['isRatedByMe']
          : (json.containsKey('ratedByMe') ? json['ratedByMe'] : json['hasRated']);
      if (raw is bool) {
        return raw;
      }
      if (raw is String) {
        final normalized = raw.trim().toLowerCase();
        if (normalized == 'true') {
          return true;
        }
        if (normalized == 'false') {
          return false;
        }
      }
      return false;
    }

    final status = P2PTradeStatus.fromBackend(json['status']?.toString());
    final rating = _parseUserRating();
    final isRatedByMe = _parseRatedByMe();

    return P2PTrade(
      id: (json['id'] ?? '').toString(),
      adId: (json['adId'] ?? '').toString(),
      buyerId: (json['buyerId'] ?? '').toString(),
      sellerId: (json['sellerId'] ?? '').toString(),
      amount: Money.fromCents(amountCents, currency: currency),
      sendAmount: _parseSendAmount(),
      rate: Money.fromCents(rateCents, currency: currency),
      currency: currency,
      status: status,
      expiresAt: _parseDate(json['expiresAt']),
      paidAt: _parseDate(json['paidAt']),
      releasedAt: _parseDate(json['releasedAt']),
      completedAt: _parseDate(json['completedAt']),
      cancelledAt: _parseDate(json['cancelledAt']),
      cancelReason: json['cancelReason'] is String && json['cancelReason'].toString().trim().isNotEmpty
          ? json['cancelReason'].toString().trim()
          : null,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      ad: P2PTradeAdSummary.fromJson(json['ad'] as Map<String, dynamic>?),
      selectedPaymentMethod: selectedMethod,
      proofs: (json['proofs'] is List)
          ? (json['proofs'] as List)
              .whereType<Map<String, dynamic>>()
              .map(P2PTradeProof.fromJson)
              .toList(growable: false)
          : const <P2PTradeProof>[],
      yourRating: rating,
      canRate: _parseCanRate(status, rating),
      ratingPending: _parsePending(),
      isRatedByMe: isRatedByMe,
    );
  }

  bool occursAfter(DateTime? other) {
    if (createdAt == null || other == null) {
      return false;
    }
    return createdAt!.isAfter(other);
  }

  String get roleLabel {
    switch (ad.type) {
      case P2PAdType.buy:
        return 'Seller';
      case P2PAdType.sell:
        return 'Buyer';
    }
  }

  String get statusLabel => status.displayLabel;

  bool get hasUserRating => yourRating != null && yourRating!.isValid;

  bool get isRatingEligibleByStatus {
    return status == P2PTradeStatus.releasedBySeller || status == P2PTradeStatus.completed;
  }

  bool get shouldOfferRating => !hasUserRating && !isRatedByMe && (canRate || isRatingEligibleByStatus);

  P2PTrade copyWith({
    P2PTradeStatus? status,
    DateTime? paidAt,
    DateTime? releasedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancelReason,
    DateTime? updatedAt,
    P2PTradePaymentMethod? selectedPaymentMethod,
    bool clearSelectedPaymentMethod = false,
    List<P2PTradeProof>? proofs,
    P2PTradeRating? yourRating,
    bool? canRate,
    bool? ratingPending,
    bool? isRatedByMe,
    Money? sendAmount,
  }) {
    return P2PTrade(
      id: id,
      adId: adId,
      buyerId: buyerId,
      sellerId: sellerId,
      amount: amount,
      rate: rate,
      currency: currency,
      sendAmount: sendAmount ?? this.sendAmount,
      status: status ?? this.status,
      expiresAt: expiresAt,
      paidAt: paidAt ?? this.paidAt,
      releasedAt: releasedAt ?? this.releasedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelReason: cancelReason ?? this.cancelReason,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ad: ad,
      selectedPaymentMethod: clearSelectedPaymentMethod ? null : (selectedPaymentMethod ?? this.selectedPaymentMethod),
      proofs: proofs ?? this.proofs,
      yourRating: yourRating ?? this.yourRating,
      canRate: canRate ?? this.canRate,
      ratingPending: ratingPending ?? this.ratingPending,
      isRatedByMe: isRatedByMe ?? this.isRatedByMe,
    );
  }
}