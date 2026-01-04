import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/repositories/transaction_repository.dart';
import 'package:opei/features/transactions/transactions_state.dart';

final transactionsControllerProvider =
    NotifierProvider<TransactionsController, TransactionsState>(
  TransactionsController.new,
);

class TransactionsController extends Notifier<TransactionsState> {
  late TransactionRepository _transactionRepository;
  bool _sessionListenerAttached = false;
  String? _activeUserId;
  int? _lastSessionNonce;
  bool _isFetching = false;

  @override
  TransactionsState build() {
    _transactionRepository = ref.read(transactionRepositoryProvider);

    if (!_sessionListenerAttached) {
      _sessionListenerAttached = true;
      ref.listen<AuthSession>(
        authSessionProvider,
        (previous, next) => _handleSessionUpdate(previous, next),
        fireImmediately: true,
      );
    }

    return const TransactionsState();
  }

  Future<void> ensureLoaded() async {
    await _fetchTransactions(force: false);
  }

  Future<void> refresh() async {
    await _fetchTransactions(force: true, asRefresh: true);
  }

  Future<void> _fetchTransactions({required bool force, bool asRefresh = false}) async {
    final userId = await _resolveActiveUserId();
    if (userId == null) {
      debugPrint('⚠️ Cannot fetch transactions: user id is unavailable');
      return;
    }

    if (_isFetching) {
      debugPrint('⏳ Transaction history request already running - skipping duplicate call.');
      return;
    }

    final currentState = state;
    final alreadyLoaded =
        currentState.transactions.isNotEmpty &&
        currentState.lastFetchedUserId == userId &&
        currentState.hasAttemptedInitialLoad;

    if (!force && alreadyLoaded) {
      debugPrint('✅ Transaction history already loaded for $userId. Skipping fetch.');
      return;
    }

    _isFetching = true;

    final isInitialLoad = !currentState.hasAttemptedInitialLoad ||
        currentState.lastFetchedUserId != userId;

    state = currentState.copyWith(
      isLoading:
          asRefresh ? currentState.isLoading : (isInitialLoad ? true : currentState.isLoading),
      isRefreshing: asRefresh,
      hasAttemptedInitialLoad: true,
      lastFetchedUserId: userId,
      clearError: true,
    );

    try {
      final result = await _transactionRepository.getAllTransactions(userId);

      state = state.copyWith(
        transactions: result.items,
        isLoading: false,
        isRefreshing: false,
        clearError: true,
        currentPage: result.page,
        pageSize: result.limit,
        hasMore: result.hasMore,
      );

      debugPrint('🧾 Loaded ${result.items.length} transactions for $userId');
    } catch (error) {
      final friendly = ErrorHelper.getErrorMessage(error);
      debugPrint('❌ Failed to load transactions for $userId: $friendly');
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: friendly,
        currentPage: 1,
        pageSize: 0,
        hasMore: false,
      );
    } finally {
      _isFetching = false;
    }
  }

  void _handleSessionUpdate(AuthSession? previous, AuthSession next) {
    final nextUserId = next.userId;

    if (nextUserId == null || next.accessToken == null) {
      _activeUserId = null;
      _lastSessionNonce = next.sessionNonce;
      state = const TransactionsState();
      debugPrint('ℹ️ Cleared transaction history state due to missing session.');
      return;
    }

    final previousUserId = previous?.userId;
    final sessionNonceChanged = _lastSessionNonce != next.sessionNonce;
    _activeUserId = nextUserId;
    _lastSessionNonce = next.sessionNonce;

    if (previousUserId != nextUserId) {
      debugPrint('👤 Active user switched (transactions). Forcing reload.');
      state = const TransactionsState();
      scheduleMicrotask(() {
        _fetchTransactions(force: true);
      });
      return;
    }

    if (!state.hasAttemptedInitialLoad || sessionNonceChanged) {
      scheduleMicrotask(() {
        _fetchTransactions(force: true);
      });
    }
  }

  Future<String?> _resolveActiveUserId() async {
    if (_activeUserId != null) {
      return _activeUserId;
    }

    final session = ref.read(authSessionProvider);
    if (session.userId != null) {
      _activeUserId = session.userId;
      return _activeUserId;
    }

    try {
      final storage = ref.read(secureStorageServiceProvider);
      final storedUser = await storage.getUser();
      if (storedUser != null) {
        _activeUserId = storedUser.id;
        return _activeUserId;
      }
    } catch (error) {
      debugPrint('⚠️ Failed to resolve stored user for transactions: $error');
    }

    return null;
  }
}