import 'package:opei/data/models/wallet_balance.dart';
import 'package:opei/data/models/wallet_transaction.dart';

class DashboardState {
  final bool isLoading;
  final bool isRefreshing;
  final WalletBalance? wallet;
  final String? error;
  final DateTime? lastSyncedAt;
  final String? lastFetchedUserId;
  final bool hasAttemptedInitialLoad;
  final bool isLoadingTransactions;
  final bool isRefreshingTransactions;
  final List<WalletTransaction> recentTransactions;
  final String? transactionsError;
  final bool hasAttemptedTransactionsLoad;
  final bool transactionsHydrated;

  const DashboardState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.wallet,
    this.error,
    this.lastSyncedAt,
    this.lastFetchedUserId,
    this.hasAttemptedInitialLoad = false,
    this.isLoadingTransactions = false,
    this.isRefreshingTransactions = false,
    this.recentTransactions = const [],
    this.transactionsError,
    this.hasAttemptedTransactionsLoad = false,
    this.transactionsHydrated = false,
  });

  bool get showSkeleton =>
      wallet == null || (!transactionsHydrated && transactionsError == null);

  bool get showTransactionsSkeleton =>
      !transactionsHydrated && transactionsError == null;

  DashboardState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    WalletBalance? wallet,
    String? error,
    DateTime? lastSyncedAt,
    String? lastFetchedUserId,
    bool? hasAttemptedInitialLoad,
    bool clearError = false,
    bool clearWallet = false,
    bool? isLoadingTransactions,
    bool? isRefreshingTransactions,
    List<WalletTransaction>? recentTransactions,
    String? transactionsError,
    bool? hasAttemptedTransactionsLoad,
    bool clearTransactionsError = false,
    bool clearRecentTransactions = false,
    bool? transactionsHydrated,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      wallet: clearWallet ? null : (wallet ?? this.wallet),
      error: clearError ? null : (error ?? this.error),
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastFetchedUserId: lastFetchedUserId ?? this.lastFetchedUserId,
      hasAttemptedInitialLoad:
          hasAttemptedInitialLoad ?? this.hasAttemptedInitialLoad,
      isLoadingTransactions:
          isLoadingTransactions ?? this.isLoadingTransactions,
      isRefreshingTransactions:
          isRefreshingTransactions ?? this.isRefreshingTransactions,
      recentTransactions: clearRecentTransactions
          ? const []
          : (recentTransactions ?? this.recentTransactions),
      transactionsError: clearTransactionsError
          ? null
          : (transactionsError ?? this.transactionsError),
      hasAttemptedTransactionsLoad:
          hasAttemptedTransactionsLoad ?? this.hasAttemptedTransactionsLoad,
      transactionsHydrated: transactionsHydrated ?? this.transactionsHydrated,
    );
  }
}
