import 'package:tt1/data/models/card_details.dart';
import 'package:tt1/data/models/virtual_card.dart';

class CardsState {
  final List<VirtualCard> cards;
  final bool isLoading;
  final bool hasLoaded;
  final String? error;
  final Map<String, CardDetails> detailsById;
  final Set<String> detailLoadingIds;
  final Set<String> revealedCardIds;
  final Set<String> actionInFlightIds;

  const CardsState({
    this.cards = const [],
    this.isLoading = false,
    this.hasLoaded = false,
    this.error,
    this.detailsById = const <String, CardDetails>{},
    this.detailLoadingIds = const <String>{},
    this.revealedCardIds = const <String>{},
    this.actionInFlightIds = const <String>{},
  });

  CardsState copyWith({
    List<VirtualCard>? cards,
    bool? isLoading,
    bool? hasLoaded,
    String? error,
    bool clearError = false,
    Map<String, CardDetails>? detailsById,
    Set<String>? detailLoadingIds,
    Set<String>? revealedCardIds,
    Set<String>? actionInFlightIds,
  }) {
    return CardsState(
      cards: cards ?? this.cards,
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      error: clearError ? null : (error ?? this.error),
      detailsById: detailsById != null ? Map.unmodifiable(detailsById) : this.detailsById,
      detailLoadingIds:
          detailLoadingIds != null ? Set.unmodifiable(detailLoadingIds) : this.detailLoadingIds,
      revealedCardIds:
          revealedCardIds != null ? Set.unmodifiable(revealedCardIds) : this.revealedCardIds,
      actionInFlightIds: actionInFlightIds != null
          ? Set.unmodifiable(actionInFlightIds)
          : this.actionInFlightIds,
    );
  }
}