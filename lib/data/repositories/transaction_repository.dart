import 'package:flutter/foundation.dart';
import 'package:opei/core/network/api_client.dart';
import 'package:opei/data/models/transactions_page.dart';
import 'package:opei/data/models/wallet_transaction.dart';

class TransactionRepository {
  final ApiClient _apiClient;

  TransactionRepository(this._apiClient);

  Future<List<WalletTransaction>> getRecentTransactions(String userId) async {
    debugPrint('📄 Fetching recent transactions for $userId');
    final payload =
        await _apiClient.get<dynamic>('/wallets/transactions/$userId/recent');
    return _mapTransactions(payload);
  }

  Future<TransactionsPage> getAllTransactions(
    String userId, {
    int page = 1,
    int? limit,
  }) async {
    debugPrint('📚 Fetching transactions page $page for $userId');

    final queryParameters = <String, dynamic>{};
    if (page > 1) {
      queryParameters['page'] = page;
    }
    if (limit != null && limit > 0) {
      queryParameters['limit'] = limit;
    }

    final payload = await _apiClient.get<dynamic>(
      '/wallets/transactions/$userId',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );

    final items = _mapTransactions(payload);
    return TransactionsPage.fromPayload(
      payload: payload,
      items: items,
      fallbackPage: page,
      fallbackLimit: limit ?? items.length,
    );
  }

  List<WalletTransaction> _mapTransactions(dynamic payload) {
    Iterable<dynamic>? extractList(dynamic source) {
      if (source is List) {
        return source;
      }

      if (source is Map<String, dynamic>) {
        const preferredKeys = ['data', 'transactions', 'items', 'results'];

        for (final key in preferredKeys) {
          if (!source.containsKey(key)) continue;

          final value = source[key];
          if (value is List) {
            return value;
          }

          final nested = extractList(value);
          if (nested != null) {
            return nested;
          }
        }

        for (final value in source.values) {
          final nested = extractList(value);
          if (nested != null) {
            return nested;
          }
        }
      }

      return null;
    }

    final items = extractList(payload) ?? const <dynamic>[];
    final transactions = items
        .whereType<Map<String, dynamic>>()
        .map(WalletTransaction.fromJson)
        .toList(growable: false);

    final sorted = [...transactions];
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
}