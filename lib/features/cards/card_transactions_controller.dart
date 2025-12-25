import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tt1/core/network/api_error.dart';
import 'package:tt1/core/providers/providers.dart';
import 'package:tt1/core/utils/error_helper.dart';
import 'package:tt1/data/models/card_transactions_page.dart';
import 'package:tt1/data/repositories/card_repository.dart';
import 'package:tt1/features/cards/card_transactions_state.dart';

final cardTransactionsControllerProvider =
    NotifierProvider<CardTransactionsController, CardTransactionsState>(
  CardTransactionsController.new,
);

class CardTransactionsController extends Notifier<CardTransactionsState> {
  static const int _defaultTake = 20;

  late CardRepository _cardRepository;

  @override
  CardTransactionsState build() {
    _cardRepository = ref.read(cardRepositoryProvider);
    return const CardTransactionsState();
  }

  CardTransactionsFeed feedFor(String cardId) => state.feedFor(cardId);

  Future<void> loadInitial(String cardId, {bool force = false}) async {
    final feed = feedFor(cardId);
    if (!force && (feed.isLoading || feed.hasLoaded || feed.transactions.isNotEmpty)) {
      return;
    }
    await _fetch(cardId, mode: _FetchMode.initial);
  }

  Future<void> refresh(String cardId) => _fetch(cardId, mode: _FetchMode.refresh);

  Future<void> loadMore(String cardId) => _fetch(cardId, mode: _FetchMode.loadMore);

  Future<void> _fetch(String cardId, {required _FetchMode mode}) async {
    final currentFeed = feedFor(cardId);

    if (mode == _FetchMode.initial && currentFeed.isLoading) {
      return;
    }

    if (mode == _FetchMode.refresh && currentFeed.isRefreshing) {
      return;
    }

    if (mode == _FetchMode.loadMore) {
      if (!currentFeed.hasMore || currentFeed.isLoadingMore) {
        return;
      }
    }

    final updatedFeed = _statusForMode(
      currentFeed,
      mode,
    );

    _updateFeed(cardId, updatedFeed);

    try {
      final targetPage = mode == _FetchMode.loadMore ? currentFeed.currentPage + 1 : 1;

      final CardTransactionsPage pageResult = await _cardRepository.fetchCardTransactions(
        cardId,
        page: targetPage,
        take: _defaultTake,
      );

      final mergedTransactions = mode == _FetchMode.loadMore
          ? [...currentFeed.transactions, ...pageResult.items]
          : pageResult.items;

      final nextFeed = updatedFeed.copyWith(
        transactions: mergedTransactions,
        isLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
        hasMore: pageResult.hasMore,
        currentPage: pageResult.page,
        hasLoaded: true,
        clearError: true,
        clearLoadMoreError: true,
      );

      _updateFeed(cardId, nextFeed);

      debugPrint('🧾 Loaded ${pageResult.items.length} card transactions for $cardId (page ${pageResult.page}).');
    } catch (error) {
      final resolution = _resolveError(error);

      if (resolution.shouldResetSession) {
        scheduleMicrotask(() {
          ref.read(authSessionProvider.notifier).clearSession();
        });
      }

      if (mode == _FetchMode.loadMore) {
        final nextFeed = updatedFeed.copyWith(
          isLoadingMore: false,
          loadMoreError: resolution.message,
        );
        _updateFeed(cardId, nextFeed);
        debugPrint('⚠️ Load-more failed for card $cardId: ${resolution.message}');
      } else {
        final nextFeed = updatedFeed.copyWith(
          isLoading: false,
          isRefreshing: false,
          hasLoaded: mode == _FetchMode.initial ? true : currentFeed.hasLoaded,
          errorMessage: resolution.message,
        );
        _updateFeed(cardId, nextFeed);
        debugPrint('❌ Failed to fetch transactions for $cardId: ${resolution.message}');
      }
    }
  }

  void _updateFeed(String cardId, CardTransactionsFeed feed) {
    final nextFeeds = Map<String, CardTransactionsFeed>.from(state.feeds);
    nextFeeds[cardId] = feed;
    state = state.copyWith(feeds: nextFeeds);
  }

  CardTransactionsFeed _statusForMode(CardTransactionsFeed feed, _FetchMode mode) {
    switch (mode) {
      case _FetchMode.initial:
        return feed.copyWith(
          isLoading: true,
          hasLoaded: feed.hasLoaded,
          clearError: true,
        );
      case _FetchMode.refresh:
        return feed.copyWith(
          isRefreshing: true,
          clearError: true,
        );
      case _FetchMode.loadMore:
        return feed.copyWith(
          isLoadingMore: true,
          clearLoadMoreError: true,
        );
    }
  }

  _ErrorResolution _resolveError(Object error) {
    if (error is ApiError) {
      switch (error.statusCode) {
        case 401:
          return const _ErrorResolution(
            'Your session has expired. Please log in again.',
            shouldResetSession: true,
          );
        case 404:
          return const _ErrorResolution("We couldn't find this card.");
        case 503:
          return const _ErrorResolution(
            "We're having trouble loading your transactions. Please try again soon.",
          );
        case 400:
        case 422:
          return const _ErrorResolution('Something went wrong. Please try again.');
      }
    }

    final fallback = ErrorHelper.getErrorMessage(error);
    if (fallback.isEmpty) {
      return const _ErrorResolution('Something went wrong. Please try again.');
    }
    return _ErrorResolution(fallback);
  }
}

enum _FetchMode { initial, refresh, loadMore }

class _ErrorResolution {
  final String message;
  final bool shouldResetSession;

  const _ErrorResolution(this.message, {this.shouldResetSession = false});
}