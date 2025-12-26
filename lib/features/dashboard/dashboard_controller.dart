import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tt1/core/money/money.dart';
import 'package:tt1/core/providers/providers.dart';
import 'package:tt1/core/utils/error_helper.dart';
import 'package:tt1/data/repositories/transaction_repository.dart';
import 'package:tt1/data/repositories/wallet_repository.dart';
import 'package:tt1/features/dashboard/dashboard_state.dart';

final dashboardControllerProvider =
    NotifierProvider<DashboardController, DashboardState>(
  DashboardController.new,
);

class DashboardController extends Notifier<DashboardState> {
  late WalletRepository _walletRepository;
  late TransactionRepository _transactionRepository;
  bool _sessionListenerAttached = false;
  String? _activeUserId;
  int? _lastSessionNonce;
  bool _isFetching = false;
  bool _pendingForcedRefresh = false;
  bool _isFetchingTransactions = false;
  bool _pendingTransactionsForcedRefresh = false;

  @override
  DashboardState build() {
    _walletRepository = ref.read(walletRepositoryProvider);
    _transactionRepository = ref.read(transactionRepositoryProvider);

    if (!_sessionListenerAttached) {
      _sessionListenerAttached = true;
      ref.listen<AuthSession>(
        authSessionProvider,
        (previous, next) => _handleSessionUpdate(previous, next),
        fireImmediately: true,
      );
    }

    return const DashboardState();
  }

  Future<void> ensureBalanceLoaded() async {
    await Future.wait([
      _fetchBalance(force: false),
      _fetchRecentTransactions(force: false),
    ]);
  }

  Future<void> refreshBalance({bool showSpinner = true}) async {
    await Future.wait([
      _fetchBalance(force: true, asRefresh: showSpinner),
      _fetchRecentTransactions(force: true, asRefresh: showSpinner),
    ]);
  }

  Future<void> _fetchBalance({required bool force, bool asRefresh = false}) async {
    final userId = await _resolveActiveUserId();
    if (userId == null) {
      debugPrint('⚠️ Cannot fetch balance: user id is unavailable');
      return;
    }

    if (_isFetching) {
      if (force) {
        _pendingForcedRefresh = true;
      }
      debugPrint('⏳ Wallet fetch already in progress. Skipping duplicate call.');
      return;
    }

    final currentState = state;
    final alreadyLoaded = currentState.wallet != null &&
        currentState.lastFetchedUserId == userId &&
        currentState.hasAttemptedInitialLoad;
    if (!force && alreadyLoaded) {
      debugPrint('✅ Wallet already loaded for $userId. Skipping fetch.');
      return;
    }

    _isFetching = true;

    final isInitialLoad =
        !currentState.hasAttemptedInitialLoad || currentState.lastFetchedUserId != userId;

    state = currentState.copyWith(
      isLoading: asRefresh ? currentState.isLoading : (isInitialLoad ? true : currentState.isLoading),
      isRefreshing: asRefresh,
      hasAttemptedInitialLoad: true,
      clearError: true,
      lastFetchedUserId: userId,
    );

    try {
      final wallet = await _walletRepository.getWallet(userId);

      state = state.copyWith(
        wallet: wallet,
        clearWallet: wallet == null,
        isLoading: false,
        isRefreshing: false,
        clearError: true,
        lastSyncedAt: DateTime.now(),
      );

      debugPrint('💼 Wallet synced for $userId: ${wallet?.formattedAvailableBalance ?? 'no wallet'}');
    } catch (error) {
      final friendly = ErrorHelper.getErrorMessage(error);
      debugPrint('❌ Failed to sync wallet for $userId: $friendly');
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: friendly,
      );
    } finally {
      _isFetching = false;

      if (_pendingForcedRefresh) {
        _pendingForcedRefresh = false;
        scheduleMicrotask(() {
          _fetchBalance(force: true, asRefresh: asRefresh);
        });
      }
    }
  }

  Future<void> _fetchRecentTransactions({required bool force, bool asRefresh = false}) async {
    final userId = await _resolveActiveUserId();
    if (userId == null) {
      debugPrint('⚠️ Cannot fetch transactions: user id is unavailable');
      return;
    }

    if (_isFetchingTransactions) {
      if (force) {
        _pendingTransactionsForcedRefresh = true;
      }
      debugPrint('⏳ Transactions fetch already in flight. Skipping duplicate call.');
      return;
    }

    final currentState = state;
    final alreadyLoaded =
        currentState.recentTransactions.isNotEmpty &&
        currentState.lastFetchedUserId == userId &&
        currentState.hasAttemptedTransactionsLoad;

    if (!force && alreadyLoaded) {
      debugPrint('✅ Recent transactions already loaded for $userId. Skipping fetch.');
      return;
    }

    _isFetchingTransactions = true;

    final isInitialLoad = !currentState.hasAttemptedTransactionsLoad ||
        currentState.lastFetchedUserId != userId;

    state = currentState.copyWith(
      isLoadingTransactions: asRefresh
          ? currentState.isLoadingTransactions
          : (isInitialLoad ? true : currentState.isLoadingTransactions),
      isRefreshingTransactions: asRefresh,
      hasAttemptedTransactionsLoad: true,
      lastFetchedUserId: userId,
      clearTransactionsError: true,
    );

    try {
      final transactions = await _transactionRepository.getRecentTransactions(userId);

      state = state.copyWith(
        recentTransactions: transactions,
        isLoadingTransactions: false,
        isRefreshingTransactions: false,
        clearTransactionsError: true,
      );

      debugPrint('🧾 Loaded ${transactions.length} recent transactions for $userId');
    } catch (error) {
      final friendly = ErrorHelper.getErrorMessage(error);
      debugPrint('❌ Failed to load recent transactions for $userId: $friendly');
      state = state.copyWith(
        isLoadingTransactions: false,
        isRefreshingTransactions: false,
        transactionsError: friendly,
      );
    } finally {
      _isFetchingTransactions = false;

      if (_pendingTransactionsForcedRefresh) {
        _pendingTransactionsForcedRefresh = false;
        scheduleMicrotask(() {
          _fetchRecentTransactions(force: true, asRefresh: asRefresh);
        });
      }
    }
  }

  void _handleSessionUpdate(AuthSession? previous, AuthSession next) {
    final nextUserId = next.userId;

    if (nextUserId == null || next.accessToken == null) {
      _activeUserId = null;
      _lastSessionNonce = next.sessionNonce;
      state = const DashboardState();
      debugPrint('ℹ️ Cleared dashboard state due to missing session.');
      return;
    }

    final previousUserId = previous?.userId;
    final sessionNonceChanged = _lastSessionNonce != next.sessionNonce;
    _activeUserId = nextUserId;
    _lastSessionNonce = next.sessionNonce;

    if (previousUserId != nextUserId) {
      debugPrint('👤 Active user changed from $previousUserId to $nextUserId. Forcing reload.');
      state = const DashboardState();
      scheduleMicrotask(() {
        _fetchBalance(force: true);
        _fetchRecentTransactions(force: true);
      });
      return;
    }

    if (!state.hasAttemptedInitialLoad || sessionNonceChanged) {
      scheduleMicrotask(() {
        _fetchBalance(force: true);
        _fetchRecentTransactions(force: true);
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
      debugPrint('⚠️ Failed to resolve stored user: $error');
    }

    return null;
  }

  void markBalanceStale() {
    state = state.copyWith(lastSyncedAt: null);
  }

  void prepareForFreshLaunch() {
    state = const DashboardState(isLoading: true);
  }

  void applyOptimisticDelta(int amountInCents) {
    final wallet = state.wallet;
    if (wallet == null) return;

    final delta = Money.fromCents(amountInCents, currency: wallet.balance.currency);
    final updated = wallet.copyWith(
      balance: wallet.balance + delta,
    );

    state = state.copyWith(wallet: updated, clearError: true);
  }
}