import 'package:opei/data/models/transaction_summary.dart';
import 'package:opei/data/models/wallet_transaction.dart';

class TransactionsPage {
  final List<WalletTransaction> items;
  final int page;
  final int limit;
  final bool hasMore;
  final TransactionSummary? summary;

  const TransactionsPage({
    required this.items,
    required this.page,
    required this.limit,
    required this.hasMore,
    this.summary,
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
    TransactionSummary? summary;

    final searchRoots = <Map<String, dynamic>>[];
    if (payload is Map<String, dynamic>) {
      searchRoots.add(payload);
      // Server envelope wraps the real payload under `data` (e.g.
      // `{ success, data: { data: [...], pagination, summary30d } }`).
      final inner = payload['data'];
      if (inner is Map<String, dynamic>) {
        searchRoots.add(inner);
      }
    }

    for (final root in searchRoots) {
      meta ??= _firstMap(
        root,
        const ['pagination', 'meta', 'pageInfo', 'page'],
      );

      summary ??= TransactionSummary.tryParse(
        root['summary30d'] ??
            root['summary'] ??
            root['stats'] ??
            root['totals'],
      );

      if (meta == null) {
        final directMeta = <String, dynamic>{};
        for (final key in ['page', 'currentPage', 'pageNumber', 'page_index']) {
          final parsed = _parseInt(root[key]);
          if (parsed != null) {
            directMeta['page'] = parsed;
            break;
          }
        }

        for (final key in ['limit', 'pageSize', 'perPage', 'size']) {
          final parsed = _parseInt(root[key]);
          if (parsed != null) {
            directMeta['limit'] = parsed;
            break;
          }
        }

        if (directMeta.isNotEmpty) {
          meta = directMeta;
        }
      }

      if (meta != null && summary != null) break;
    }

    if (meta != null) {
      page = _parseInt(meta['page'] ?? meta['currentPage'] ?? meta['pageNumber']) ?? page;
      limit = _parseInt(meta['limit'] ?? meta['pageSize'] ?? meta['perPage'] ?? meta['size']) ?? limit;

      if (meta.containsKey('hasNextPage')) {
        hasMore = _parseBool(meta['hasNextPage']);
      } else if (meta.containsKey('hasMore')) {
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
      summary: summary,
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