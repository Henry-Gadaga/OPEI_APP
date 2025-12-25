import 'package:tt1/data/models/wallet_transaction.dart';

class TransactionsPage {
  final List<WalletTransaction> items;
  final int page;
  final int limit;
  final bool hasMore;

  const TransactionsPage({
    required this.items,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory TransactionsPage.fromPayload({
    required dynamic payload,
    required List<WalletTransaction> items,
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
        final directMeta = <String, dynamic>{};
        for (final key in ['page', 'currentPage', 'pageNumber', 'page_index']) {
          final parsed = _parseInt(payload[key]);
          if (parsed != null) {
            directMeta['page'] = parsed;
            break;
          }
        }

        for (final key in ['limit', 'pageSize', 'perPage', 'size']) {
          final parsed = _parseInt(payload[key]);
          if (parsed != null) {
            directMeta['limit'] = parsed;
            break;
          }
        }

        if (directMeta.isNotEmpty) {
          meta = directMeta;
        }
      }
    }

    if (meta != null) {
      page = _parseInt(meta['page'] ?? meta['currentPage'] ?? meta['pageNumber']) ?? page;
      limit = _parseInt(meta['limit'] ?? meta['pageSize'] ?? meta['perPage'] ?? meta['size']) ?? limit;

      if (meta.containsKey('hasMore')) {
        hasMore = _parseBool(meta['hasMore']);
      } else if (meta.containsKey('totalPages')) {
        final totalPages = _parseInt(meta['totalPages']);
        if (totalPages != null) {
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

    return TransactionsPage(
      items: items,
      page: page < 1 ? 1 : page,
      limit: limit < 1 ? items.length : limit,
      hasMore: hasMore,
    );
  }

  static Map<String, dynamic>? _firstMap(
    Map<String, dynamic> payload,
    List<String> keys,
  ) {
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
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is num) {
      return value != 0;
    }
    return false;
  }
}