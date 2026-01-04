import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opei/core/money/money.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/data/models/card_creation_preview.dart';
import 'package:opei/data/models/card_creation_response.dart';
import 'package:opei/data/models/card_user_registration_response.dart';
import 'package:opei/data/models/virtual_card.dart';
import 'package:opei/data/repositories/card_repository.dart';
import 'package:opei/features/cards/card_creation_controller.dart';
import 'package:opei/features/cards/card_creation_state.dart';
import 'package:opei/features/dashboard/dashboard_controller.dart';
import 'package:opei/features/dashboard/dashboard_state.dart';

class _MockCardRepository extends Mock implements CardRepository {}

class _FakeDashboardController extends DashboardController {
  @override
  DashboardState build() => const DashboardState();

  @override
  void prepareForFreshLaunch() {}

  @override
  Future<void> refreshBalance({bool showSpinner = true}) async {}
}

void main() {
  late _MockCardRepository cardRepository;

  ProviderContainer createContainer({CardCreationState? initialState}) {
    final container = ProviderContainer(
      overrides: [
        cardRepositoryProvider.overrideWithValue(cardRepository),
        dashboardControllerProvider.overrideWith(() => _FakeDashboardController()),
      ],
    );

    if (initialState != null) {
      final controller = container.read(cardCreationControllerProvider.notifier);
      controller.state = initialState;
    }

    return container;
  }

  setUp(() {
    cardRepository = _MockCardRepository();
  });

  group('CardCreationController', () {
    test('transitions to amount entry after startRegistration success', () async {
      when(() => cardRepository.registerUser()).thenAnswer(
        (_) async => const CardUserRegistrationResponse(alreadyRegistered: false),
      );

      final container = createContainer();
      addTearDown(container.dispose);
      final controller = container.read(cardCreationControllerProvider.notifier);

      await controller.startRegistration();

      final state = container.read(cardCreationControllerProvider);
      expect(state.stage, CardCreationStage.amountEntry);
      expect(state.isBusy, isFalse);
      verify(() => cardRepository.registerUser()).called(1);
    });

    test('maps registration error to allowContinue when 409', () async {
      when(() => cardRepository.registerUser()).thenThrow(ApiError(
        statusCode: 409,
        message: 'Already registered',
      ));

      final container = createContainer();
      addTearDown(container.dispose);
      final controller = container.read(cardCreationControllerProvider.notifier);

      await controller.startRegistration();

      final state = container.read(cardCreationControllerProvider);
      expect(state.stage, CardCreationStage.amountEntry);
      expect(state.infoMessage, isNotNull);
      expect(state.errorMessage, isNull);
    });

    test('loadPreview populates preview on success', () async {
      final preview = CardCreationPreview(
        cardWillReceive: Money.fromMajor(20),
        creationFee: Money.fromMajor(1),
        totalToCharge: Money.fromMajor(21),
        walletBalance: Money.fromMajor(120),
        walletBalanceAfter: Money.fromMajor(100),
        canCreate: true,
      );

      when(() => cardRepository.previewCreation(initialLoadCents: any(named: 'initialLoadCents')))
          .thenAnswer((_) async => preview);

      final container = createContainer(initialState: const CardCreationState());
      addTearDown(container.dispose);
      final controller = container.read(cardCreationControllerProvider.notifier);

      await controller.loadPreview(Money.fromMajor(21));

      final state = container.read(cardCreationControllerProvider);
      expect(state.stage, CardCreationStage.preview);
      expect(state.preview, preview);
      expect(state.isBusy, isFalse);
    });

    test('loadPreview shows validation error for zero amount', () async {
      final container = createContainer(initialState: const CardCreationState());
      addTearDown(container.dispose);
      final controller = container.read(cardCreationControllerProvider.notifier);

      await controller.loadPreview(Money.fromMajor(0));

      final state = container.read(cardCreationControllerProvider);
      expect(state.errorMessage, isNotNull);
      verifyNever(() => cardRepository.previewCreation(initialLoadCents: any(named: 'initialLoadCents')));
    });

    test('submitCreation triggers wallet refresh and success stage', () async {
      final response = CardCreationResponse(
        reference: 'ref-456',
        cardId: 'card-id',
        status: 'created',
        creationFee: Money.fromMajor(2),
        cardWillReceive: Money.fromMajor(23),
        totalCharged: Money.fromMajor(25),
      );

      when(() => cardRepository.createCard(initialLoadCents: any(named: 'initialLoadCents')))
          .thenAnswer((_) async => response);
      when(() => cardRepository.fetchCards())
          .thenAnswer(
            (_) async => [
              VirtualCard(
                id: 'card-id',
                cardName: 'Card',
                status: 'active',
                balance: Money.fromMajor(10),
              ),
            ],
          );

      final initialState = CardCreationState(
        stage: CardCreationStage.preview,
        amount: Money.fromMajor(25),
        preview: CardCreationPreview(
          cardWillReceive: Money.fromMajor(23),
          creationFee: Money.fromMajor(2),
          totalToCharge: Money.fromMajor(25),
          walletBalance: Money.fromMajor(75),
          walletBalanceAfter: Money.fromMajor(50),
          canCreate: true,
        ),
      );

      final container = createContainer(initialState: initialState);
      addTearDown(container.dispose);
      final controller = container.read(cardCreationControllerProvider.notifier);

      await controller.submitCreation();

      final state = container.read(cardCreationControllerProvider);
      expect(state.stage, CardCreationStage.success);
      verify(() => cardRepository.createCard(initialLoadCents: any(named: 'initialLoadCents'))).called(1);
    });
  });
}
