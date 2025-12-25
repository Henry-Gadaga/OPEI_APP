import 'package:flutter/foundation.dart';
import 'package:tt1/data/models/card_transaction.dart';

class CardTransactionsPage {
  final List<CardTransaction> items;
  final int page;
  final int limit;
  final bool hasMore;

  const CardTransactionsPage({
    required this.items,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory CardTransactionsPage.fromPayload({
    required dynamic payload,
    required List<CardTransaction> items,
    required int fallbackPage,
    required int fallbackLimit,
  }) {
    int page = fallbackPage;
    int limit = fallbackLimit;
    bool hasMore = false;

    Map<String, dynamic>? meta;

    if (payload is Map<String, dynamic>) {
      meta = _firstMap(payload, const ['meta', 'pagination', 'pageInfo', 'page']);

      if (meta == null) {
        final inferred = <String, dynamic>{};

        for (final key in ['page', 'currentPage', 'pageNumber', 'page_index']) {
          final parsed = _parseInt(payload[key]);
          if (parsed != null) {
            inferred['page'] = parsed;
            break;
          }
        }

        for (final key in ['limit', 'pageSize', 'perPage', 'size', 'take']) {
          final parsed = _parseInt(payload[key]);
          if (parsed != null) {
            inferred['limit'] = parsed;
            break;
          }
        }

        if (inferred.isNotEmpty) {
          meta = inferred;
        }
      }
    }

    if (meta != null) {
      page = _parseInt(meta['page'] ?? meta['currentPage'] ?? meta['pageNumber']) ?? page;
      limit = _parseInt(meta['limit'] ?? meta['pageSize'] ?? meta['perPage'] ?? meta['size'] ?? meta['take']) ?? limit;

      if (meta.containsKey('hasMore')) {
        hasMore = _parseBool(meta['hasMore']);
      } else if (meta.containsKey('hasNextPage')) {
        hasMore = _parseBool(meta['hasNextPage']);
      } else if (meta.containsKey('totalPages')) {
        final totalPages = _parseInt(meta['totalPages']);
        if (totalPages != null && page > 0) {
          hasMore = page < totalPages;
        }
      } else if (meta.containsKey('total')) {
        final total = _parseInt(meta['total']);
        if (total != null && limit > 0) {
          hasMore = page * limit < total;
        }
      } else if (meta.containsKey('count')) {
        final count = _parseInt(meta['count']);
        if (count != null && limit > 0) {
          hasMore = page * limit < count;
        }
      }
    }

    if (limit <= 0) {
      limit = items.length;
    }

    if (meta == null) {
      hasMore = items.length >= limit && limit > 0;
    }

    return CardTransactionsPage(
      items: items,
      page: page < 1 ? 1 : page,
      limit: limit < 1 ? items.length : limit,
      hasMore: hasMore,
    );
  }

  static List<CardTransaction> extractItems(dynamic payload) {
    final rawList = _extractList(payload);

    if (kDebugMode) {
      debugPrint('🧾 Parsing card transactions from payload type: ${payload.runtimeType}');
      if (payload is Map) {
        debugPrint('🧾 Payload keys: ${payload.keys.join(', ')}');
      }
      debugPrint('🧾 Resolved raw list type: ${rawList.runtimeType} with length ${rawList.length}');
    }

    final items = rawList
        .whereType<Map<String, dynamic>>()
        .map(CardTransaction.fromJson)
        .toList(growable: false);

    final sorted = [...items];
    sorted.sort((a, b) {
      final aDate = a.createdAt;
      final bDate = b.createdAt;
      if (aDate == null && bDate == null) {
        return 0;
      }
      if (aDate == null) {
        return 1;
      }
      if (bDate == null) {
        return -1;
      }
      return bDate.compareTo(aDate);
    });

    return sorted;
  }

  static Iterable<dynamic> _extractList(dynamic payload) {
    if (payload is List) {
      return payload;
    }

    if (payload is Map<String, dynamic>) {
      for (final key in const [
        'data',
        'transactions',
        'cardTransactions',
        'card_transactions',
        'items',
        'results',
        'records',
      ]) {
        final value = payload[key];
        if (value is List) {
          return value;
        }
        if (value is Map<String, dynamic>) {
          final nested = _extractList(value);
          if (nested.isNotEmpty) {
            return nested;
          }
        }
      }
    }

    return const [];
  }

  static Map<String, dynamic>? _firstMap(Map<String, dynamic> payload, List<String> keys) {
    for (final key in keys) {
      final value = payload[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
    }
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') {
        return true;
      }
      if (lower == 'false' || lower == '0') {
        return false;
      }
    }
    if (value is num) {
      return value != 0;
    }
    return false;
  }
}