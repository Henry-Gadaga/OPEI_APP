import 'package:tt1/core/money/money.dart';

class CardTransaction {
  final String id;
  final String? cardId;
  final Money amount;
  final bool isCredit;
  final Money? runningBalance;
  final Money? fee;
  final String? status;
  final String? type;
  final String? transactionType;
  final String? method;
  final String? narrative;
  final String? merchant;
  final String? reference;
  final DateTime? createdAt;
  final String? cardBalanceAfterRaw;

  const CardTransaction({
    required this.id,
    required this.amount,
    required this.isCredit,
    this.cardId,
    this.runningBalance,
    this.fee,
    this.status,
    this.type,
    this.transactionType,
    this.method,
    this.narrative,
    this.merchant,
    this.reference,
    this.createdAt,
    this.cardBalanceAfterRaw,
  });

  Money get signedAmount => isCredit ? amount : amount.negated();

  String get formattedAmount => signedAmount.formatWithSign(includeCurrencySymbol: true);

  String get normalizedStatus {
    final raw = status?.trim() ?? '';
    if (raw.isEmpty) return '';
    final lower = raw.toLowerCase();
    return lower
        .split(RegExp(r'[\s_]+'))
        .where((segment) => segment.isNotEmpty)
        .map((segment) => segment[0].toUpperCase() + segment.substring(1))
        .join(' ');
  }

  String get formattedDate {
    final date = createdAt;
    if (date == null) return '';
    return _formatDateTime(date);
  }

  String get title {
    final raw = (narrative ?? merchant ?? method ?? reference ?? '').trim();
    if (raw.isNotEmpty) {
      return raw;
    }
    return 'Card transaction';
  }

  String get subtitle {
    final labels = <String>[
      if (formattedDate.isNotEmpty) formattedDate,
      if (normalizedStatus.isNotEmpty) normalizedStatus,
      if (normalizedType.isNotEmpty) normalizedType,
    ];
    return labels.join(' • ');
  }

  String get balanceAfterLabel => balanceAfterDetail;

  String get balanceAfterDetail {
    if (runningBalance != null) {
      return runningBalance!.format(includeCurrencySymbol: true);
    }
    final raw = cardBalanceAfterRaw;
    if (raw != null && raw.isNotEmpty) {
      final sanitized = raw.trim();
      final numeric = num.tryParse(sanitized.replaceAll(',', ''));
      if (numeric != null) {
        final money = Money.fromMajor(numeric, currency: amount.currency);
        return money.format(includeCurrencySymbol: true);
      }
      return sanitized;
    }
    return '';
  }

  String get normalizedType => _normalizeLabel(type);

  String get normalizedTransactionType => _normalizeLabel(transactionType);

  String get normalizedMethod => _normalizeLabel(method);

  String get currencyLabel => amount.currency.toUpperCase();

  factory CardTransaction.fromJson(Map<String, dynamic> json) {
    final currency = _readString(json, const [
      'currency',
      'currencyCode',
      'currency_code',
      'amountCurrency',
      'amount_currency',
    ], fallback: 'USD').toUpperCase();

    final amountCents = _parseAmountCents(json);
    final signedAmount = _parseSignedAmount(json);
    final amountMoney = Money.fromCents(amountCents.abs(), currency: currency);

    final explicitIsCredit = _parseBool(json, const [
      'isCredit',
      'credit',
      'is_credit',
      'creditIndicator',
      'credit_indicator',
    ]);

    final rawDirectionLabel = _readString(json, const [
      'direction',
      'flow',
      'transactionType',
      'transaction_type',
      'entryType',
      'entry_type',
      'type',
      'debitCreditIndicator',
      'dcIndicator',
      'postingType',
      'posting_type',
    ]);

    final transactionTypeRaw = _readString(json, const [
      'transactionType',
      'transaction_type',
      'category',
    ], fallback: '').trim();

    final directionLabel = _overrideDirectionLabel(
      directionLabel: rawDirectionLabel,
      transactionType: transactionTypeRaw,
    );

    final isCredit = _resolveIsCredit(
      amountCents: amountCents,
      signedAmount: signedAmount,
      explicitIsCredit: explicitIsCredit,
      directionLabel: directionLabel,
    );

    final runningBalanceMoney = _parseMoney(json, const [
      'runningBalance',
      'running_balance',
      'balanceAfter',
      'balance_after',
      'cardBalanceAfter',
      'card_balance_after',
      'balanceAfterCents',
      'balance_after_cents',
      'availableBalance',
      'available_balance',
    ], currency: currency);

    final feeMoney = _parseMoney(json, const [
      'feeCent',
      'feeCents',
      'feeInCents',
      'fee_in_cents',
      'fee',
      'fees',
    ], currency: currency);

    final cardBalanceAfterRaw = _readString(json, const [
      'cardBalanceAfter',
      'card_balance_after',
    ], fallback: '').trim();

    return CardTransaction(
      id: _readString(json, const [
        'id',
        'transactionId',
        'transaction_id',
        'reference',
        'ref',
        'txRef',
        'tx_ref',
        'uuid',
      ], fallback: ''),
      cardId: _readString(json, const [
        'cardId',
        'card_id',
        'crid',
      ], fallback: null),
      amount: amountMoney,
      isCredit: isCredit,
      runningBalance: runningBalanceMoney,
      fee: feeMoney,
      status: _readString(json, const [
        'status',
        'state',
        'result',
        'outcome',
      ], fallback: null),
      type: directionLabel.trim().isEmpty ? null : directionLabel.trim(),
      transactionType: transactionTypeRaw.isEmpty ? null : transactionTypeRaw,
      method: _readString(json, const [
        'method',
        'channel',
        'fundingSource',
        'funding_source',
        'paymentMethod',
        'payment_method',
      ], fallback: null),
      narrative: _readString(json, const [
        'narrative',
        'description',
        'memo',
        'note',
        'details',
        'statementDescriptor',
        'statement_descriptor',
      ], fallback: null),
      merchant: _readString(json, const [
        'merchant',
        'merchantName',
        'merchant_name',
        'merchantDescriptor',
        'merchant_descriptor',
      ], fallback: null),
      reference: _readString(json, const [
        'reference',
        'referenceNumber',
        'reference_number',
        'transactionReference',
        'transaction_reference',
        'externalReference',
        'external_reference',
      ], fallback: null),
      createdAt: _parseDate(json, const [
        'createdAt',
        'created_at',
        'transactionDate',
        'transaction_date',
        'updatedAt',
        'updated_at',
        'timestamp',
        'time',
        'date',
        'postedAt',
        'posted_at',
      ], millisKeys: const [
        'createdAtMs',
        'created_at_ms',
        'timestampMs',
        'timestamp_ms',
        'dateMs',
        'date_ms',
      ]),
      cardBalanceAfterRaw: cardBalanceAfterRaw.isEmpty ? null : cardBalanceAfterRaw,
    );
  }

  static String _normalizeLabel(String? value) {
    final raw = value?.replaceAll('_', ' ').trim() ?? '';
    if (raw.isEmpty) {
      return '';
    }
    return raw
        .split(RegExp(r"\s+"))
        .where((segment) => segment.isNotEmpty)
        .map((segment) => segment[0].toUpperCase() + segment.substring(1).toLowerCase())
        .join(' ');
  }

  static String _readString(
    Map<String, dynamic> json,
    List<String> keys, {
    String? fallback,
  }) {
    for (final key in keys) {
      if (json.containsKey(key) && json[key] != null) {
        final value = json[key];
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
    }
    return fallback ?? '';
  }

  static bool? _parseBool(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (!json.containsKey(key)) continue;
      final value = json[key];
      if (value is bool) {
        return value;
      }
      if (value is String) {
        final lower = value.toLowerCase().trim();
        if (lower == 'true' || lower == '1' || lower == 'credit') {
          return true;
        }
        if (lower == 'false' || lower == '0' || lower == 'debit') {
          return false;
        }
      }
      if (value is num) {
        if (value == 1) return true;
        if (value == 0) return false;
      }
    }
    return null;
  }

  static Money? _parseMoney(
    Map<String, dynamic> json,
    List<String> keys, {
    required String currency,
  }) {
    for (final key in keys) {
      if (!json.containsKey(key)) continue;
      final value = json[key];
      if (value == null) continue;

      if (value is Map<String, dynamic>) {
        final inner = _firstNonNull(value, const [
          'centAmount',
          'cents',
          'minor',
          'amountInCents',
          'amount_in_cents',
          'value',
        ]);
        if (inner != null) {
          final cents = _coerceToInt(inner);
          if (cents != null) {
            return Money.fromCents(cents, currency: currency);
          }
        }
      } else {
        final cents = _coerceToInt(value);
        if (cents != null) {
          return Money.fromCents(cents, currency: currency);
        }
      }
    }
    return null;
  }

  static dynamic _firstNonNull(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key) && json[key] != null) {
        return json[key];
      }
    }
    return null;
  }

  static int _parseAmountCents(Map<String, dynamic> json) {
    final candidates = [
      _firstNonNull(json, const [
        'centAmount',
        'amountCent',
        'amount_cents',
        'amountCents',
        'amountInCents',
        'amount_in_cents',
        'minorAmount',
        'minor_amount',
        'amountMinor',
        'amount_minor',
        'valueInCents',
        'value_in_cents',
      ]),
      _firstNonNull(json, const [
        'amount',
        'value',
        'total',
        'gross',
        'net',
      ]),
    ];

    for (final candidate in candidates) {
      final parsed = _coerceToInt(candidate);
      if (parsed != null) {
        return parsed;
      }
      if (candidate is Map<String, dynamic>) {
        final nested = _firstNonNull(candidate, const [
          'centAmount',
          'amountInCents',
          'minor',
          'value',
        ]);
        final nestedParsed = _coerceToInt(nested);
        if (nestedParsed != null) {
          return nestedParsed;
        }
      }
    }

    return 0;
  }

  static num? _parseSignedAmount(Map<String, dynamic> json) {
    final candidate = _firstNonNull(json, const [
      'signedAmount',
      'signed_amount',
      'netAmount',
      'net_amount',
      'amountSigned',
      'amount_signed',
    ]);
    if (candidate == null) return null;
    if (candidate is num) {
      return candidate;
    }
    if (candidate is String) {
      final sanitized = candidate.replaceAll(',', '').trim();
      if (sanitized.isEmpty) return null;
      return num.tryParse(sanitized);
    }
    return null;
  }

  static int? _coerceToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) {
      final sanitized = value.replaceAll(',', '').trim();
      if (sanitized.isEmpty) return null;
      final parsedInt = int.tryParse(sanitized);
      if (parsedInt != null) return parsedInt;
      final parsedDouble = double.tryParse(sanitized);
      if (parsedDouble != null) return parsedDouble.round();
    }
    return null;
  }

  static bool _resolveIsCredit({
    required int amountCents,
    required num? signedAmount,
    required bool? explicitIsCredit,
    required String directionLabel,
  }) {
    if (explicitIsCredit != null) {
      return explicitIsCredit;
    }

    if (directionLabel.isNotEmpty) {
      final lower = directionLabel.toLowerCase();
      if (lower.contains('credit') || lower == 'cr' || lower.contains('incoming') || lower.contains('receive')) {
        return true;
      }
      if (lower.contains('debit') || lower == 'dr' || lower.contains('withdraw') || lower.contains('send') || lower.contains('purchase')) {
        return false;
      }
    }

    if (signedAmount != null) {
      return signedAmount >= 0;
    }

    if (amountCents < 0) {
      return false;
    }
    if (amountCents > 0) {
      return true;
    }

    return true;
  }

  static DateTime? _parseDate(
    Map<String, dynamic> json,
    List<String> keys, {
    List<String> millisKeys = const [],
  }) {
    for (final key in keys) {
      if (!json.containsKey(key) || json[key] == null) continue;
      final value = json[key];
      if (value is String) {
        final trimmed = value.trim();
        if (trimmed.isEmpty) continue;
        final parsed = DateTime.tryParse(trimmed);
        if (parsed != null) {
          return parsed.toLocal();
        }
      } else if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true).toLocal();
      } else if (value is num) {
        return DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true).toLocal();
      }
    }

    for (final key in millisKeys) {
      if (!json.containsKey(key) || json[key] == null) continue;
      final value = json[key];
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true).toLocal();
      }
      if (value is num) {
        return DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true).toLocal();
      }
      if (value is String) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null) {
          return DateTime.fromMillisecondsSinceEpoch(parsed, isUtc: true).toLocal();
        }
      }
    }

    return null;
  }

  static String _formatDateTime(DateTime dateTime) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final local = dateTime.toLocal();
    final month = monthNames[local.month - 1];
    final day = local.day;
    final year = local.year;

    int hour = local.hour;
    final minute = local.minute;
    final isPm = hour >= 12;
    hour = hour % 12;
    if (hour == 0) {
      hour = 12;
    }

    final minuteLabel = minute.toString().padLeft(2, '0');
    final period = isPm ? 'PM' : 'AM';

    return '$month $day, $year • $hour:$minuteLabel $period';
  }

  static String _overrideDirectionLabel({
    required String directionLabel,
    required String transactionType,
  }) {
    final trimmedDirection = directionLabel.trim();
    final normalizedTransactionType = transactionType.trim().toLowerCase();
    final hasExplicitDirection = _hasExplicitDirection(trimmedDirection);

    if (normalizedTransactionType.isEmpty) {
      return trimmedDirection;
    }

    if (_looksLikeSettlement(normalizedTransactionType) && !hasExplicitDirection) {
      return 'debit';
    }

    if (_looksLikeAuthorizationHold(normalizedTransactionType)) {
      return 'debit';
    }

    if (_looksLikeAuthorizationRelease(normalizedTransactionType)) {
      return 'credit';
    }

    return trimmedDirection;
  }

  static bool _looksLikeAuthorizationHold(String transactionType) {
    if (!transactionType.contains('author')) {
      return false;
    }

    if (transactionType.contains('reversal') ||
        transactionType.contains('reverse') ||
        transactionType.contains('release') ||
        transactionType.contains('refund') ||
        transactionType.contains('credit')) {
      return false;
    }

    return true;
  }

  static bool _looksLikeAuthorizationRelease(String transactionType) {
    if (!transactionType.contains('author')) {
      return false;
    }

    return transactionType.contains('reversal') ||
        transactionType.contains('reverse') ||
        transactionType.contains('release');
  }

  static bool _looksLikeSettlement(String transactionType) {
    if (transactionType.isEmpty) {
      return false;
    }
    return transactionType.contains('settlement');
  }

  static bool _hasExplicitDirection(String label) {
    if (label.isEmpty) {
      return false;
    }
    final lower = label.toLowerCase();
    if (lower == 'dr' || lower == 'cr') {
      return true;
    }
    return lower.contains('debit') || lower.contains('credit');
  }
}