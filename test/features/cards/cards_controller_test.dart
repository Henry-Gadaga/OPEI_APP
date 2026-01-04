import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opei/core/money/money.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/data/models/card_details.dart';
import 'package:opei/data/models/virtual_card.dart';
import 'package:opei/data/repositories/card_repository.dart';
import 'package:opei/features/cards/cards_controller.dart';
import 'package:opei/features/cards/cards_state.dart';

class _MockCardRepository extends Mock implements CardRepository {}

void main() {
  late _MockCardRepository cardRepository;

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        cardRepositoryProvider.overrideWithValue(cardRepository),
      ],
    );
  }

  setUp(() {
    cardRepository = _MockCardRepository();
  });

  group('CardsController', () {
    test('ensureLoaded fetches cards when not loaded', () async {
      final sampleCards = <VirtualCard>[
        const VirtualCard(id: 'card-1', cardName: 'Card 1', status: 'active'),
      ];

      when(() => cardRepository.fetchCards()).thenAnswer((_) async => sampleCards);

      final container = createContainer();
      addTearDown(container.dispose);
      final controller = container.read(cardsControllerProvider.notifier);

      await controller.ensureLoaded();

      final state = container.read(cardsControllerProvider);
      expect(state.cards, sampleCards);
      expect(state.hasLoaded, isTrue);
      verify(() => cardRepository.fetchCards()).called(1);
    });

    test('toggleCardDetails fetches details and reveals card', () async {
      final card = VirtualCard(
        id: 'card-1',
        cardName: 'Card',
        status: 'active',
        balance: Money.fromMajor(25),
      );
      final details = CardDetails(
        cardNumber: '**** 1234',
        cvv: '999',
        balance: Money.fromMajor(30),
      );

      when(() =>
          cardRepository.fetchCardDetails(card.id, currency: any(named: 'currency'), fallbackBalance: any(named: 'fallbackBalance')))
          .thenAnswer((_) async => details);

      final container = createContainer();
      addTearDown(container.dispose);
      final controller = container.read(cardsControllerProvider.notifier);

      container.read(cardsControllerProvider);
      controller.state = CardsState(cards: [card], hasLoaded: true);

      final result = await controller.toggleCardDetails(card);

      expect(result, isNull);
      final state = container.read(cardsControllerProvider);
      expect(state.revealedCardIds.contains(card.id), isTrue);
      expect(state.detailsById[card.id], details);
    });
  });
}
