import 'package:flutter/foundation.dart';
import 'package:tt1/core/money/money.dart';

class WalletTransaction {
  final String id;
  final String title;
  final String currency;
  final Money amount;
  final bool isCredit;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? status;
  final String? reference;
  final String? rawType;
  final String? description;
  final String? direction;
  final String? source;
  final dynamic metadata;

  WalletTransaction({
    required this.id,
    required this.title,
    required this.currency,
    required this.amount,
    required this.isCredit,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.reference,
    this.rawType,
    this.description,
    this.direction,
    this.source,
    this.metadata,
  });

  int get amountCents => amount.cents;

  int get signedAmountCents => isCredit ? amount.cents : -amount.cents;

  Money get amountMoney => amount;

  Money get signedAmount => isCredit ? amount : amount.negated();

  String get formattedAmount =>
      signedAmount.formatWithSign(includeCurrencySymbol: true);

  bool get isPeerToPeer => rawType?.toUpperCase().startsWith('P2P') == true;

  bool get isCryptoTransfer =>
      (rawType?.trim().toUpperCase() ?? '').startsWith('CRYPTO');

  String get humanizedTransactionType {
    if (isCryptoTransfer) {
      return isIncoming ? 'USD Deposit' : 'USD Withdrawal';
    }
    if (_hasTrdReferencePrefix) {
      return isIncoming ? 'Buy USD' : 'Sell USD';
    }

    final type = rawType?.trim();
    if (type == null || type.isEmpty) {
      return 'Deposit / Withdraw';
    }

    final spaced = type.replaceAll('_', ' ').replaceAll('-', ' ').trim();
    final parts = spaced.split(RegExp(r'\s+')).map((segment) {
      if (segment.isEmpty) return segment;
      final lower = segment.toLowerCase();
      if (lower == 'p2p') {
        return 'P2P';
      }
      return segment[0].toUpperCase() + segment.substring(1).toLowerCase();
    }).toList();

    return parts.join(' ');
  }

  String get listTitle {
    if (isCryptoTransfer) {
      return isIncoming ? 'USD Deposit' : 'USD Withdrawal';
    }
    if (_hasTrdReferencePrefix) {
      return isIncoming ? 'Buy USD' : 'Sell USD';
    }
    if (isPeerToPeer) {
      final derived = _derivePeerToPeerName(description ?? title);
      if (derived != null && derived.isNotEmpty) {
        return derived;
      }
    }
    return humanizedTransactionType;
  }

  String get displayStatus {
    final value = normalizedStatus;
    return value.isEmpty ? '—' : value;
  }

  bool get isPending => (status?.trim().toUpperCase() == 'PENDING');

  bool get isCompleted => (status?.trim().toUpperCase() == 'COMPLETED');

  bool get isIncoming {
    final normalized = direction?.trim().toUpperCase();
    if (normalized == 'IN') return true;
    if (normalized == 'OUT') return false;
    return isCredit;
  }

  bool get _hasTrdReferencePrefix {
    final value = reference?.trim();
    if (value == null || value.length < 3) return false;
    return value.substring(0, 3).toUpperCase() == 'TRD';
  }

  String get displayReference {
    final value = reference?.trim() ?? '';
    return value.isEmpty ? '—' : value;
  }

  String get formattedCreatedDateTime {
    final date = createdAt;
    if (date == null) return '—';
    return _formatDateTime(date);
  }

  String get formattedUpdatedDateTime {
    final date = updatedAt;
    if (date == null) return '—';
    return _formatDateTime(date);
  }

  String get formattedDate {
    final date = createdAt;
    if (date == null) return '';

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

    final month = monthNames[date.month - 1];
    final day = date.day;
    final year = date.year;
    return '$month $day, $year';
  }

  String get normalizedStatus {
    final value = status?.trim() ?? '';
    if (value.isEmpty) return '';
    final lower = value.toLowerCase();
    return lower.split(' ').map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  String get subtitleLabel {
    final dateLabel = formattedDate;
    final statusLabel = normalizedStatus;

    final hasDate = dateLabel.isNotEmpty;
    final hasStatus = statusLabel.isNotEmpty;

    if (hasDate && hasStatus) {
      return '$dateLabel · $statusLabel';
    }
    if (hasDate) {
      return dateLabel;
    }
    if (hasStatus) {
      return statusLabel;
    }
    return '';
  }

  WalletTransaction copyWith({
    String? id,
    String? title,
    String? currency,
    Money? amount,
    bool? isCredit,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    String? reference,
    String? rawType,
    String? description,
    String? direction,
    String? source,
    dynamic metadata,
  }) {
    return WalletTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      currency: currency ?? this.currency,
      amount: amount ?? this.amount,
      isCredit: isCredit ?? this.isCredit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      reference: reference ?? this.reference,
      rawType: rawType ?? this.rawType,
      description: description ?? this.description,
      direction: direction ?? this.direction,
      source: source ?? this.source,
      metadata: metadata ?? this.metadata,
    );
  }

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    String readString(List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        if (json.containsKey(key) && json[key] != null) {
          final value = json[key];
          if (value is String && value.trim().isNotEmpty) {
            return value.trim();
          }
          if (value != null) {
            final text = value.toString().trim();
            if (text.isNotEmpty) {
              return text;
            }
          }
        }
      }
      return fallback;
    }

    T? readValue<T>(List<String> keys) {
      for (final key in keys) {
        if (json.containsKey(key) && json[key] != null) {
          final value = json[key];
          if (value is T) {
            return value;
          }
          if (T == String && value != null) {
            return value.toString() as T;
          }
        }
      }
      return null;
    }

    DateTime? parseDate(
      List<String> keys, {
      List<String> millisKeys = const [],
    }) {
      final raw = readString(keys);

      if (raw.isEmpty) {
        for (final key in millisKeys) {
          if (json.containsKey(key)) {
            final value = json[key];
            if (value is int) {
              return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true)
                  .toLocal();
            }
            if (value is num) {
              return DateTime.fromMillisecondsSinceEpoch(value.toInt(),
                      isUtc: true)
                  .toLocal();
            }
            if (value is String) {
              final parsed = int.tryParse(value);
              if (parsed != null) {
                return DateTime.fromMillisecondsSinceEpoch(parsed, isUtc: true)
                    .toLocal();
              }
            }
          }
        }
        return null;
      }

      final parsed = DateTime.tryParse(raw);
      return parsed?.toLocal();
    }

    int parseAmountCents() {
      num? parseToNum(dynamic value) {
        if (value == null) return null;
        if (value is num) return value;
        if (value is String) {
          final sanitized = value.replaceAll(',', '').trim();
          if (sanitized.isEmpty) return null;
          return num.tryParse(sanitized);
        }
        return null;
      }

      bool hasDecimal(num parsed) => parsed is double && (parsed % 1) != 0;

      final centCandidates = [
        json['amountInCents'],
        json['amount_in_cents'],
        json['amountMinor'],
        json['amount_minor'],
        json['minorAmount'],
        json['minor_amount'],
        json['valueInCents'],
        json['value_in_cents'],
        json['amount'],
        json['value'],
        json['total'],
        json['gross'],
      ];

      for (final candidate in centCandidates) {
        final parsed = parseToNum(candidate);
        if (parsed != null) {
          if (hasDecimal(parsed)) {
            return (parsed * 100).round();
          }
          return parsed.round();
        }
      }

      return 0;
    }

    bool parseIsCredit(int cents) {
      final explicit = readValue<bool>(['isCredit', 'credit']);
      if (explicit != null) {
        return explicit;
      }

      final direction = readString([
        'direction',
        'flow',
        'transactionType',
        'transaction_type',
        'type',
        'category',
        'nature',
      ]).toLowerCase();

      if (direction.isNotEmpty) {
        if (direction.contains('p2p') && direction.contains('send')) {
          return false;
        }
        if (direction.contains('p2p') && direction.contains('receive')) {
          return true;
        }
        if (['credit', 'cr', 'incoming', 'in', 'deposit', 'receive', 'received']
            .contains(direction)) {
          return true;
        }
        if ([
          'debit',
          'dr',
          'outgoing',
          'out',
          'withdraw',
          'withdrawal',
          'send',
          'sent',
          'transfer'
        ].contains(direction)) {
          return false;
        }
      }

      if (cents < 0) return false;
      if (cents > 0) return true;

      final signed = readValue<num>(['signedAmount', 'signed_amount']);
      if (signed != null) {
        return signed >= 0;
      }

      return true;
    }

    final rawDescription = readString([
      'description',
      'narration',
      'note',
      'summary',
      'details',
      'memo',
      'label',
      'message',
    ]);

    final rawTitle = readString([
      'title',
      'transactionName',
      'transaction_name',
      'eventTitle',
      'event_title',
    ], fallback: rawDescription.isNotEmpty ? rawDescription : 'Transaction');

    final id = readString([
      'id',
      'transactionId',
      'transaction_id',
      'reference',
      'ref',
      'txRef',
      'tx_ref',
    ], fallback: UniqueKey().toString());

    final currency = readString([
      'currency',
      'currencyCode',
      'currency_code',
    ], fallback: 'USD')
        .toUpperCase();

    final status = readString([
      'status',
      'state',
      'result',
      'outcome',
    ]);

    final reference = readString([
      'reference',
      'ref',
      'txRef',
      'tx_ref',
      'externalReference',
      'external_reference',
    ]);

    final rawType = readString([
      'type',
      'transactionType',
      'transaction_type',
      'category',
      'subtype',
    ]);

    final direction = readString([
      'direction',
      'flow',
    ]);

    final source = readString([
      'source',
      'origin',
    ]);

    final metadata = json['metadata'];

    final createdAt = parseDate(
      const [
        'createdAt',
        'created_at',
        'timestamp',
        'time',
        'date',
        'transactionDate',
        'transaction_date',
        'postedAt',
        'posted_at',
      ],
      millisKeys: const [
        'createdAtMs',
        'created_at_ms',
        'timestampMs',
        'timestamp_ms',
      ],
    );

    final updatedAt = parseDate(
      const [
        'updatedAt',
        'updated_at',
        'modifiedAt',
        'modified_at',
      ],
      millisKeys: const [
        'updatedAtMs',
        'updated_at_ms',
        'modifiedAtMs',
        'modified_at_ms',
      ],
    );

    final amountCents = parseAmountCents();
    final isCredit = parseIsCredit(amountCents);
    final amountMoney = Money.fromCents(amountCents.abs(), currency: currency);
    var title = rawTitle.isEmpty ? 'Transaction' : rawTitle;

    if (rawType.toUpperCase().startsWith('P2P')) {
      final derived = _derivePeerToPeerName(
          rawDescription.isNotEmpty ? rawDescription : rawTitle);
      if (derived != null && derived.isNotEmpty) {
        title = derived;
      }
    }

    return WalletTransaction(
      id: id,
      title: title,
      currency: currency,
      amount: amountMoney,
      isCredit: isCredit,
      createdAt: createdAt,
      updatedAt: updatedAt,
      status: status.isEmpty ? null : status,
      reference: reference.isEmpty ? null : reference,
      rawType: rawType.isEmpty ? null : rawType,
      description: rawDescription.isEmpty ? null : rawDescription,
      direction: direction.isEmpty ? null : direction,
      source: source.isEmpty ? null : source,
      metadata: metadata,
    );
  }

  static String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
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

  static String? _derivePeerToPeerName(String? raw) {
    if (raw == null) return null;
    var working = raw.trim();
    if (working.isEmpty) {
      return null;
    }

    final lower = working.toLowerCase();
    const prefixes = [
      'transfer to',
      'transfer from',
      'sent to',
      'sent from',
      'received from',
      'payment to',
      'payment from',
      'transfer',
    ];

    for (final prefix in prefixes) {
      if (lower.startsWith(prefix)) {
        working = working.substring(prefix.length).trim();
        break;
      }
    }

    working = working.replaceAll(RegExp(r'^[:\-]+'), '').trim();

    if (working.contains('@')) {
      final segments = working.split(RegExp(r'\s+'));
      final emailCandidate = segments.firstWhere(
        (segment) => segment.contains('@'),
        orElse: () => working,
      );
      working = emailCandidate.split('@').first;
      working = working.replaceAll(RegExp(r'[0-9]+'), '');
      working = working.replaceAll(RegExp(r'[._]+'), ' ');
    }

    working = working.replaceAll(RegExp(r'[_\-]+'), ' ');
    working = working.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (working.isEmpty) {
      return null;
    }

    if (!working.contains(' ') && working.length >= 8) {
      final midpoint = (working.length / 2).floor();
      working =
          '${working.substring(0, midpoint)} ${working.substring(midpoint)}';
    }

    final parts = working
        .split(' ')
        .where((segment) => segment.trim().isNotEmpty)
        .map((segment) {
      final lowerSegment = segment.toLowerCase();
      return lowerSegment[0].toUpperCase() + lowerSegment.substring(1);
    }).toList();

    return parts.join(' ');
  }
}
