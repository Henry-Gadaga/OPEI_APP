import 'package:opei/data/models/transaction_summary.dart';
import 'package:opei/data/models/wallet_transaction.dart';

class TransactionsState {
  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final List<WalletTransaction> transactions;
  final String? error;
  final String? loadMoreError;
  final bool hasAttemptedInitialLoad;
  final String? lastFetchedUserId;
  final int currentPage;
  final int pageSize;
  final bool hasMore;
  final TransactionSummary? summary;

  const TransactionsState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.transactions = const [],
    this.error,
    this.loadMoreError,
    this.hasAttemptedInitialLoad = false,
    this.lastFetchedUserId,
    this.currentPage = 1,
    this.pageSize = 0,
    this.hasMore = false,
    this.summary,
  });

  bool get showSkeleton => isLoading && transactions.isEmpty && !isRefreshing;

  TransactionsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    List<WalletTransaction>? transactions,
    String? error,
    String? loadMoreError,
    bool? hasAttemptedInitialLoad,
    String? lastFetchedUserId,
    bool clearError = false,
    bool clearLoadMoreError = false,
    bool clearTransactions = false,
    int? currentPage,
    int? pageSize,
    bool? hasMore,
    TransactionSummary? summary,
    bool clearSummary = false,
  }) {
    return TransactionsState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      transactions: clearTransactions ? const [] : (transactions ?? this.transactions),
      error: clearError ? null : (error ?? this.error),
      loadMoreError:
          clearLoadMoreError ? null : (loadMoreError ?? this.loadMoreError),
      hasAttemptedInitialLoad: hasAttemptedInitialLoad ?? this.hasAttemptedInitialLoad,
      lastFetchedUserId: lastFetchedUserId ?? this.lastFetchedUserId,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
      summary: clearSummary ? null : (summary ?? this.summary),
    );
  }
}