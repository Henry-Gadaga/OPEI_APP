import 'package:tt1/data/models/card_transaction.dart';

class CardTransactionsState {
  final Map<String, CardTransactionsFeed> feeds;

  const CardTransactionsState({
    this.feeds = const <String, CardTransactionsFeed>{},
  });

  CardTransactionsFeed feedFor(String cardId) =>
      feeds[cardId] ?? const CardTransactionsFeed();

  CardTransactionsState copyWith({
    Map<String, CardTransactionsFeed>? feeds,
  }) {
    return CardTransactionsState(
      feeds: feeds ?? this.feeds,
    );
  }
}

class CardTransactionsFeed {
  final List<CardTransaction> transactions;
  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? errorMessage;
  final String? loadMoreError;
  final bool hasLoaded;

  const CardTransactionsFeed({
    this.transactions = const <CardTransaction>[],
    this.isLoading = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.currentPage = 1,
    this.errorMessage,
    this.loadMoreError,
    this.hasLoaded = false,
  });

  bool get showSkeleton => isLoading && !hasLoaded;

  CardTransactionsFeed copyWith({
    List<CardTransaction>? transactions,
    bool? isLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? errorMessage,
    String? loadMoreError,
    bool? hasLoaded,
    bool clearError = false,
    bool clearLoadMoreError = false,
  }) {
    return CardTransactionsFeed(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      loadMoreError: clearLoadMoreError ? null : (loadMoreError ?? this.loadMoreError),
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}