import 'package:opei/data/models/wallet_transaction.dart';

class TransactionsState {
  final bool isLoading;
  final bool isRefreshing;
  final List<WalletTransaction> transactions;
  final String? error;
  final bool hasAttemptedInitialLoad;
  final String? lastFetchedUserId;
  final int currentPage;
  final int pageSize;
  final bool hasMore;

  const TransactionsState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.transactions = const [],
    this.error,
    this.hasAttemptedInitialLoad = false,
    this.lastFetchedUserId,
    this.currentPage = 1,
    this.pageSize = 0,
    this.hasMore = false,
  });

  bool get showSkeleton => isLoading && transactions.isEmpty && !isRefreshing;

  TransactionsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    List<WalletTransaction>? transactions,
    String? error,
    bool? hasAttemptedInitialLoad,
    String? lastFetchedUserId,
    bool clearError = false,
    bool clearTransactions = false,
    int? currentPage,
    int? pageSize,
    bool? hasMore,
  }) {
    return TransactionsState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      transactions: clearTransactions ? const [] : (transactions ?? this.transactions),
      error: clearError ? null : (error ?? this.error),
      hasAttemptedInitialLoad: hasAttemptedInitialLoad ?? this.hasAttemptedInitialLoad,
      lastFetchedUserId: lastFetchedUserId ?? this.lastFetchedUserId,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}