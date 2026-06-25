import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/data/models/promo_card_create_result.dart';
import 'package:opei/data/models/promo_card_prepare.dart';
import 'package:opei/features/cards/create_virtual_card_flow.dart';
import 'package:opei/features/cards/promo_card_creation_controller.dart';
import 'package:opei/features/cards/promo_card_creation_state.dart';
import 'package:opei/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CreateVirtualCardFlow', () {
    testWidgets('shows prepare error state and retries on tap', (tester) async {
      var prepareCalls = 0;

      final controller = _FakePromoCardCreationController(
        initialState: const PromoCardCreationState(
          stage: PromoCardStage.preparing,
          errorMessage: 'Network down',
        ),
        onPrepare: () => prepareCalls++,
      );

      await _pumpCreateVirtualCardFlow(tester, controller: controller);

      expect(find.text('Couldn\'t load card details'), findsOneWidget);
      expect(find.text('Network down'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      // One prepare call happens from initState post-frame callback.
      expect(prepareCalls, 1);

      await tester.tap(find.text('Try again'));
      await tester.pump();

      expect(prepareCalls, 2);
    });

    testWidgets('confirm stage submits card creation', (tester) async {
      var createCalls = 0;

      final controller = _FakePromoCardCreationController(
        initialState: PromoCardCreationState(
          stage: PromoCardStage.confirm,
          prepare: _prepare(canCreate: true),
        ),
        onCreateCard: () => createCalls++,
      );

      await _pumpCreateVirtualCardFlow(tester, controller: controller);

      expect(find.text('PAYMENT SUMMARY'), findsOneWidget);
      expect(find.text('Create my card'), findsOneWidget);

      await tester.tap(find.text('Create my card'));
      await tester.pump();

      expect(createCalls, 1);
    });

    testWidgets('shows top-up UI when wallet balance is insufficient', (tester) async {
      final controller = _FakePromoCardCreationController(
        initialState: PromoCardCreationState(
          stage: PromoCardStage.confirm,
          prepare: _prepare(
            canCreate: false,
            walletBalanceCents: 4000,
            totalToChargeCents: 5100,
          ),
        ),
      );

      await _pumpCreateVirtualCardFlow(tester, controller: controller);

      expect(find.text('Top up your wallet to continue card creation.'), findsOneWidget);
      expect(find.text('TOP UP REQUIRED'), findsOneWidget);
      expect(find.text('Add to continue'), findsOneWidget);
      expect(find.text('Add funds'), findsOneWidget);
    });

    testWidgets('success stage renders completion UI', (tester) async {
      final controller = _FakePromoCardCreationController(
        initialState: const PromoCardCreationState(
          stage: PromoCardStage.success,
          result: PromoCardCreateResult(
            cardId: 'card_123',
            reference: 'ref_abc',
            status: 'pending',
            initialLoadCents: 1000,
            creationFeeCents: 200,
            totalChargedCents: 1200,
            sweepCents: 100,
            referralRewardCents: 0,
          ),
        ),
      );

      await _pumpCreateVirtualCardFlow(tester, controller: controller);

      expect(
        find.text('Card on its way!'),
        findsOneWidget,
      );
      expect(find.text('ref_abc'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });
  });
}

class _FakePromoCardCreationController extends PromoCardCreationController {
  _FakePromoCardCreationController({
    required this.initialState,
    this.onPrepare,
    this.onCreateCard,
  });

  final PromoCardCreationState initialState;
  final VoidCallback? onPrepare;
  final VoidCallback? onCreateCard;

  @override
  PromoCardCreationState build() => initialState;

  @override
  void reset() {}

  @override
  Future<void> prepare() async {
    onPrepare?.call();
  }

  @override
  Future<void> createCard() async {
    onCreateCard?.call();
  }
}

PromoCardPrepare _prepare({
  required bool canCreate,
  int walletBalanceCents = 200000,
  int totalToChargeCents = 5100,
}) {
  return PromoCardPrepare(
    success: true,
    canCreate: canCreate,
    reason: null,
    cardUserId: 'user_1',
    alreadyRegistered: true,
    walletBalanceCents: walletBalanceCents,
    walletBalanceAfterCents: walletBalanceCents - totalToChargeCents,
    isFirstCard: true,
    promoReferralEligible: false,
    creationFeeCents: 200,
    initialLoadCents: 4800,
    sweepCents: 100,
    cardWillReceiveCents: 4800,
    totalToChargeCents: totalToChargeCents,
    referralRewardCents: 0,
    feeVersion: 1,
  );
}

Future<void> _pumpCreateVirtualCardFlow(
  WidgetTester tester, {
  required PromoCardCreationController controller,
}) async {
  await tester.binding.setSurfaceSize(const Size(600, 1024));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        promoCardCreationControllerProvider.overrideWith(() => controller),
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

  // Flush first frame + post-frame callback without waiting on indefinite animations.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
}
