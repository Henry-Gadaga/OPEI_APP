import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/money/money.dart';
import 'package:opei/data/models/card_creation_preview.dart';
import 'package:opei/features/cards/card_creation_controller.dart';
import 'package:opei/features/cards/card_creation_state.dart';
import 'package:opei/features/cards/cards_controller.dart';
import 'package:opei/features/cards/cards_state.dart';
import 'package:opei/features/cards/create_virtual_card_flow.dart';
import 'package:opei/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CreateVirtualCardFlow', () {
    testWidgets('shows registration error state and retries on tap', (tester) async {
      var startRegistrationCalls = 0;

      final controller = _FakeCardCreationController(
        initialState: const CardCreationState(
          stage: CardCreationStage.registering,
          errorMessage: 'Network down',
        ),
        onStartRegistration: () => startRegistrationCalls++,
      );

      await _pumpCreateVirtualCardFlow(tester, controller: controller);

      expect(find.text("We couldn't start card setup"), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      // One call happens during initState.
      expect(startRegistrationCalls, 1);

      await tester.tap(find.text('Try again'));
      await tester.pump();

      expect(startRegistrationCalls, 2);
    });

    testWidgets('submitting amount entry calls loadPreview with parsed amount', (tester) async {
      Money? capturedAmount;

      final controller = _FakeCardCreationController(
        initialState: const CardCreationState(stage: CardCreationStage.amountEntry),
        onLoadPreview: (amount) => capturedAmount = amount,
      );

      await _pumpCreateVirtualCardFlow(tester, controller: controller);

      await tester.enterText(find.byType(TextFormField), '25.50');
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(capturedAmount, isNotNull);
      expect(capturedAmount!.cents, 2550);
    });

    testWidgets('shows insufficient funds banner in preview and allows editing amount', (tester) async {
      var backToAmountCalled = false;

      final controller = _FakeCardCreationController(
        initialState: CardCreationState(
          stage: CardCreationStage.preview,
          amount: Money.fromMajor(51),
          preview: CardCreationPreview(
            canCreate: true,
            cardWillReceive: Money.fromMajor(49),
            creationFee: Money.fromMajor(2),
            totalToCharge: Money.fromMajor(51),
            walletBalance: Money.fromMajor(40),
            walletBalanceAfter: Money.fromMajor(-5),
          ),
        ),
        onBackToAmountEntry: () => backToAmountCalled = true,
      );

      await _pumpCreateVirtualCardFlow(tester, controller: controller);

      expect(
        find.text(
          'Wallet balance is too low to cover this card creation. Please add funds and try again.',
        ),
        findsOneWidget,
      );
      expect(find.text('Summary'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Add funds to continue'), findsOneWidget);

      final editFinder = find.text('Edit amount');
      expect(editFinder, findsOneWidget);
      await tester.tap(editFinder);
      await tester.pump();

      expect(backToAmountCalled, isTrue);
    });
  });
}

class _FakeCardCreationController extends CardCreationController {
  _FakeCardCreationController({
    required this.initialState,
    this.onStartRegistration,
    this.onLoadPreview,
    this.onBackToAmountEntry,
  });

  final CardCreationState initialState;
  final VoidCallback? onStartRegistration;
  final ValueSetter<Money>? onLoadPreview;
  final VoidCallback? onBackToAmountEntry;

  @override
  CardCreationState build() => initialState;

  @override
  void reset() {}

  @override
  Future<void> startRegistration() async {
    onStartRegistration?.call();
  }

  @override
  Future<void> loadPreview(Money amount) async {
    onLoadPreview?.call(amount);
  }

  @override
  Future<void> submitCreation() async {
    // no-op for tests
  }

  @override
  void backToAmountEntry() {
    onBackToAmountEntry?.call();
  }
}

class _FakeCardsController extends CardsController {
  _FakeCardsController();

  @override
  CardsState build() => const CardsState();

  @override
  Future<void> refresh() async {
    // no-op
  }

  @override
  Future<bool> preloadCardDetails(String cardId, {bool reveal = true}) async {
    return true;
  }
}

Future<void> _pumpCreateVirtualCardFlow(
  WidgetTester tester, {
  required CardCreationController controller,
  CardsController? cardsController,
}) async {
  await tester.binding.setSurfaceSize(const Size(600, 1024));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        cardCreationControllerProvider.overrideWith(() => controller),
        cardsControllerProvider.overrideWith(() => cardsController ?? _FakeCardsController()),
      ],
      child: MaterialApp(
        theme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        ).copyWith(
          textTheme: ThemeData.light().textTheme.copyWith(
                bodyMedium: ThemeData.light()
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: OpeiColors.pureBlack),
              ),
        ),
        home: const CreateVirtualCardFlow(),
      ),
    ),
  );

  await tester.pumpAndSettle();
}
