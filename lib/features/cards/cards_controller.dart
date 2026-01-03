import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tt1/core/network/api_error.dart';
import 'package:tt1/core/providers/providers.dart';
import 'package:tt1/core/utils/error_helper.dart';
import 'package:tt1/data/models/card_details.dart';
import 'package:tt1/data/models/virtual_card.dart';
import 'package:tt1/data/repositories/card_repository.dart';
import 'package:tt1/features/cards/cards_state.dart';

final cardsControllerProvider = NotifierProvider<CardsController, CardsState>(
  CardsController.new,
);

class CardsController extends Notifier<CardsState> {
  late CardRepository _cardRepository;
  bool _isFetching = false;
  bool _listeningForSession = false;

  @override
  CardsState build() {
    _cardRepository = ref.read(cardRepositoryProvider);

    if (!_listeningForSession) {
      _listeningForSession = true;
      ref.listen<AuthSession>(
        authSessionProvider,
        (previous, next) => _handleSessionUpdate(previous, next),
        fireImmediately: false,
      );
    }

    return const CardsState();
  }

  Future<void> ensureLoaded() async {
    if (state.hasLoaded || _isFetching) {
      return;
    }
    await _fetchCards(showFullLoader: true);
  }

  Future<void> refresh() async {
    await _fetchCards(showFullLoader: false);
  }

  Future<void> _fetchCards({required bool showFullLoader}) async {
    if (_isFetching) {
      debugPrint('🔄 Card fetch already in progress, skipping.');
      return;
    }

    _isFetching = true;

    final hadCards = state.cards.isNotEmpty;
    final shouldShowFullLoader = showFullLoader || !hadCards;
    final shouldClearError = hadCards;

    state = state.copyWith(
      isLoading: shouldShowFullLoader ? true : state.isLoading,
      clearError: shouldClearError,
    );

    try {
      final cards = await _cardRepository.fetchCards();
      final immutable = List<VirtualCard>.unmodifiable(cards);
      final idSet = immutable.map((card) => card.id).where((id) => id.isNotEmpty).toSet();
      final prunedDetails = Map<String, CardDetails>.from(state.detailsById)
        ..removeWhere((key, _) => !idSet.contains(key));
      final prunedRevealed = Set<String>.from(state.revealedCardIds)
        ..removeWhere((id) => !idSet.contains(id));
      final prunedLoading = Set<String>.from(state.detailLoadingIds)
        ..removeWhere((id) => !idSet.contains(id));
      final prunedActions = Set<String>.from(state.actionInFlightIds)
        ..removeWhere((id) => !idSet.contains(id));

      final cardsById = <String, VirtualCard>{};
      for (final card in immutable) {
        final rawId = card.id;
        if (rawId.isNotEmpty) {
          cardsById[rawId] = card;
        }
        final trimmedId = rawId.trim();
        if (trimmedId.isNotEmpty) {
          cardsById[trimmedId] = card;
        }
      }

      final updatedDetails = <String, CardDetails>{};
      prunedDetails.forEach((rawId, details) {
        final normalizedId = rawId.trim();
        final matchingCard = cardsById[normalizedId];
        if (matchingCard != null && matchingCard.balance != null) {
          updatedDetails[rawId] = CardDetails(
            cardNumber: details.cardNumber,
            cvv: details.cvv,
            balance: matchingCard.balance,
          );
        } else {
          updatedDetails[rawId] = details;
        }
      });

      state = state.copyWith(
        cards: immutable,
        isLoading: false,
        hasLoaded: true,
        clearError: true,
        detailsById: updatedDetails,
        revealedCardIds: prunedRevealed,
        detailLoadingIds: prunedLoading,
        actionInFlightIds: prunedActions,
      );

      debugPrint('💳 Loaded ${immutable.length} card(s) for the active user.');
    } catch (error) {
      final friendly = ErrorHelper.getErrorMessage(error);

      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        error: friendly,
      );

      debugPrint('❌ Failed to load cards: $friendly');
    } finally {
      _isFetching = false;
    }
  }

  void _handleSessionUpdate(AuthSession? previous, AuthSession next) {
    final hasToken = next.accessToken != null;

    if (!hasToken) {
      if (state.cards.isNotEmpty || state.error != null || state.hasLoaded) {
        state = const CardsState();
        debugPrint('ℹ️ Cleared cards state due to missing session.');
      }
      return;
    }

    final previousUser = previous?.userId;
    final nextUser = next.userId;

    final sessionChanged = previousUser != nextUser || previous?.sessionNonce != next.sessionNonce;

    if (sessionChanged) {
      state = const CardsState();
      Future.microtask(() => _fetchCards(showFullLoader: true));
    } else if (!state.hasLoaded && !_isFetching) {
      Future.microtask(() => _fetchCards(showFullLoader: true));
    }
  }

  Future<String?> toggleCardDetails(VirtualCard card) async {
    final cardId = card.id.trim();
    if (cardId.isEmpty) {
      return "We couldn't find this card.";
    }

    if (state.detailLoadingIds.contains(cardId)) {
      debugPrint('⌛ Card detail request already in flight for $cardId.');
      return null;
    }

    final revealed = state.revealedCardIds.contains(cardId);
    if (revealed) {
      final updatedRevealed = Set<String>.from(state.revealedCardIds)..remove(cardId);
      final trimmedDetails = Map<String, CardDetails>.from(state.detailsById)
        ..remove(cardId)
        ..remove(card.id);
      state = state.copyWith(
        revealedCardIds: updatedRevealed,
        detailsById: trimmedDetails,
      );
      return null;
    }

    final cached = state.detailsById[cardId];
    if (cached != null) {
      final updatedRevealed = Set<String>.from(state.revealedCardIds)..add(cardId);
      state = state.copyWith(revealedCardIds: updatedRevealed);
      return null;
    }

    final nextLoading = Set<String>.from(state.detailLoadingIds)..add(cardId);
    state = state.copyWith(detailLoadingIds: nextLoading);

    try {
      final currency = card.balance?.currency ?? 'USD';
      final details = await _cardRepository.fetchCardDetails(
        cardId,
        currency: currency,
        fallbackBalance: card.balance,
      );

      final updatedDetails = Map<String, CardDetails>.from(state.detailsById)
        ..[cardId] = details;
      final updatedLoading = Set<String>.from(state.detailLoadingIds)..remove(cardId);
      final updatedRevealed = Set<String>.from(state.revealedCardIds)..add(cardId);

      state = state.copyWith(
        detailsById: updatedDetails,
        detailLoadingIds: updatedLoading,
        revealedCardIds: updatedRevealed,
      );

      return null;
    } catch (error, stackTrace) {
      debugPrint('❌ Failed to fetch card details for $cardId: $error');
      debugPrint('$stackTrace');
      final updatedLoading = Set<String>.from(state.detailLoadingIds)..remove(cardId);
      state = state.copyWith(detailLoadingIds: updatedLoading);
      return _mapCardDetailError(error);
    }
  }

  String _mapCardDetailError(Object error) {
    if (error is ApiError) {
      switch (error.statusCode) {
        case 400:
          return 'Something went wrong. Please try again.';
        case 401:
          return 'Your session has expired. Please log in again.';
        case 404:
          return "We couldn't find this card.";
        case 503:
          return "We're having trouble loading your card details. Please try again soon.";
        default:
          return ErrorHelper.getErrorMessage(error);
      }
    }
    return ErrorHelper.getErrorMessage(error);
  }

  Future<CardActionResult> freezeCard(VirtualCard card) async {
    final cardId = card.id.trim();
    if (cardId.isEmpty) {
      return const CardActionResult(error: "We couldn't find this card.");
    }

    if (state.actionInFlightIds.contains(cardId)) {
      debugPrint('⚠️ Freeze already in progress for $cardId.');
      return const CardActionResult();
    }

    final nextInFlight = Set<String>.from(state.actionInFlightIds)..add(cardId);
    state = state.copyWith(actionInFlightIds: nextInFlight);

    try {
      final responseMessage = await _cardRepository.freezeCard(cardId);
      _updateCardStatus(cardId, 'locked');
      return CardActionResult(
        message: responseMessage.isNotEmpty ? responseMessage : 'Card locked',
      );
    } catch (error, stackTrace) {
      debugPrint('❌ Failed to freeze card $cardId: $error');
      debugPrint('$stackTrace');
      final friendly = _mapFreezeCardError(error);
      return CardActionResult(error: friendly);
    } finally {
      final trimmed = Set<String>.from(state.actionInFlightIds)..remove(cardId);
      state = state.copyWith(actionInFlightIds: trimmed);
    }
  }

  Future<CardActionResult> unfreezeCard(VirtualCard card) async {
    final cardId = card.id.trim();
    if (cardId.isEmpty) {
      return const CardActionResult(error: "We couldn't find this card.");
    }

    if (state.actionInFlightIds.contains(cardId)) {
      debugPrint('⚠️ Unfreeze already in progress for $cardId.');
      return const CardActionResult();
    }

    final nextInFlight = Set<String>.from(state.actionInFlightIds)..add(cardId);
    state = state.copyWith(actionInFlightIds: nextInFlight);

    try {
      final responseMessage = await _cardRepository.unfreezeCard(cardId);
      _updateCardStatus(cardId, 'active');
      return CardActionResult(
        message: responseMessage.isNotEmpty ? responseMessage : 'Card unlocked',
      );
    } catch (error, stackTrace) {
      debugPrint('❌ Failed to unfreeze card $cardId: $error');
      debugPrint('$stackTrace');
      final friendly = _mapUnfreezeCardError(error);
      return CardActionResult(error: friendly);
    } finally {
      final trimmed = Set<String>.from(state.actionInFlightIds)..remove(cardId);
      state = state.copyWith(actionInFlightIds: trimmed);
    }
  }

  Future<CardActionResult> terminateCard(VirtualCard card) async {
    final cardId = card.id.trim();
    if (cardId.isEmpty) {
      return const CardActionResult(error: "We couldn't find this card.");
    }

    if (state.actionInFlightIds.contains(cardId)) {
      debugPrint('⚠️ Terminate already in progress for $cardId.');
      return const CardActionResult();
    }

    final nextInFlight = Set<String>.from(state.actionInFlightIds)..add(cardId);
    state = state.copyWith(actionInFlightIds: nextInFlight);

    try {
      final responseMessage = await _cardRepository.terminateCard(cardId);
      _updateCardStatus(cardId, 'terminated');
      return CardActionResult(
        message: responseMessage.isNotEmpty ? responseMessage : 'Card terminated',
      );
    } catch (error, stackTrace) {
      debugPrint('❌ Failed to terminate card $cardId: $error');
      debugPrint('$stackTrace');
      final friendly = _mapTerminateCardError(error);
      return CardActionResult(error: friendly);
    } finally {
      final trimmed = Set<String>.from(state.actionInFlightIds)..remove(cardId);
      state = state.copyWith(actionInFlightIds: trimmed);
    }
  }

  void _updateCardStatus(String cardId, String status) {
    final cards = state.cards;
    if (cards.isEmpty) {
      return;
    }

    final updated = cards
        .map((existing) => existing.id.trim() == cardId ? existing.copyWith(status: status) : existing)
        .toList(growable: false);

    state = state.copyWith(cards: List<VirtualCard>.unmodifiable(updated));
  }

  String _mapFreezeCardError(Object error) {
    if (error is ApiError) {
      switch (error.statusCode) {
        case 401:
          return 'Your session has expired. Please log in again.';
        case 404:
          return "We couldn't find this card.";
        case 503:
          return "We're having trouble updating your card. Please try again soon.";
        default:
          return ErrorHelper.getErrorMessage(error);
      }
    }
    return ErrorHelper.getErrorMessage(error);
  }

  String _mapUnfreezeCardError(Object error) {
    if (error is ApiError) {
      switch (error.statusCode) {
        case 400:
          return 'Something went wrong. Please try again.';
        case 401:
          return 'Your session has expired. Please log in again.';
        case 404:
          return "We couldn't find this card.";
        case 503:
          return "We're having trouble updating your card. Please try again soon.";
        default:
          return ErrorHelper.getErrorMessage(error);
      }
    }
    return ErrorHelper.getErrorMessage(error);
  }

  String _mapTerminateCardError(Object error) {
    if (error is ApiError) {
      switch (error.statusCode) {
        case 401:
          return 'Your session has expired. Please log in again.';
        case 404:
          return "We couldn't find this card.";
        case 503:
          return "We're having trouble closing your card. Please try again soon.";
        default:
          return ErrorHelper.getErrorMessage(error);
      }
    }
    return ErrorHelper.getErrorMessage(error);
  }

  Future<bool> preloadCardDetails(String cardId, {bool reveal = true}) async {
    final normalizedId = cardId.trim();
    if (normalizedId.isEmpty) {
      return false;
    }

    final card = _findCardById(normalizedId);
    if (card == null) {
      debugPrint('⚠️ Cannot preload card details. No card found for ID $normalizedId.');
      return false;
    }

    if (state.detailsById.containsKey(normalizedId)) {
      if (reveal && !state.revealedCardIds.contains(normalizedId)) {
        final updatedRevealed = Set<String>.from(state.revealedCardIds)..add(normalizedId);
        state = state.copyWith(revealedCardIds: updatedRevealed);
      }
      return true;
    }

    if (state.detailLoadingIds.contains(normalizedId)) {
      debugPrint('⌛ Detail request already running for $normalizedId.');
      return false;
    }

    final nextLoading = Set<String>.from(state.detailLoadingIds)..add(normalizedId);
    state = state.copyWith(detailLoadingIds: nextLoading);

    try {
      final details = await _cardRepository.fetchCardDetails(
        normalizedId,
        currency: card.balance?.currency ?? 'USD',
        fallbackBalance: card.balance,
      );

      final updatedDetails = Map<String, CardDetails>.from(state.detailsById)
        ..[normalizedId] = details;
      final trimmedLoading = Set<String>.from(state.detailLoadingIds)..remove(normalizedId);

      state = state.copyWith(
        detailsById: updatedDetails,
        detailLoadingIds: trimmedLoading,
        revealedCardIds:
            reveal ? (Set<String>.from(state.revealedCardIds)..add(normalizedId)) : null,
      );

      return true;
    } catch (error, stackTrace) {
      debugPrint('❌ Failed to preload card details for $normalizedId: $error');
      debugPrint('$stackTrace');
      final trimmedLoading = Set<String>.from(state.detailLoadingIds)..remove(normalizedId);
      state = state.copyWith(detailLoadingIds: trimmedLoading);
      return false;
    }
  }

  VirtualCard? _findCardById(String cardId) {
    final normalizedId = cardId.trim();
    if (normalizedId.isEmpty) {
      return null;
    }

    for (final card in state.cards) {
      if (card.id.trim() == normalizedId) {
        return card;
      }
    }
    return null;
  }
}

class CardActionResult {
  final String? message;
  final String? error;

  const CardActionResult({this.message, this.error});

  bool get hasMessage => message != null && message!.trim().isNotEmpty;
  bool get hasError => error != null && error!.trim().isNotEmpty;
}