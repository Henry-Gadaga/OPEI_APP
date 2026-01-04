import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opei/core/money/money.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/data/models/transfer_fee_response.dart';
import 'package:opei/data/models/transfer_response.dart';
import 'package:opei/data/models/wallet_lookup_response.dart';
import 'package:opei/data/repositories/transfer_repository.dart';
import 'package:opei/features/dashboard/dashboard_controller.dart';
import 'package:opei/features/dashboard/dashboard_state.dart';
import 'package:opei/features/send_money/send_money_controller.dart';
import 'package:opei/features/send_money/send_money_state.dart';

class _MockTransferRepository extends Mock implements TransferRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(Money.fromCents(0));
  });

  group('SendMoneyNotifier', () {
    test('fails lookup when email is empty', () async {
      final harness = _SendMoneyTestHarness();
      addTearDown(harness.container.dispose);

      final notifier = harness.container.read(sendMoneyControllerProvider.notifier);
      final success = await notifier.lookupWallet('   ');

      expect(success, isFalse);
      expect(
        harness.container.read(sendMoneyControllerProvider).errorMessage,
        'Please enter an email address',
      );
    });

    test('lookupWallet stores recipient and advances to amount step', () async {
      final harness = _SendMoneyTestHarness();
      addTearDown(harness.container.dispose);
      final lookupResponse = WalletLookupResponse(
        userId: 'user-123',
        email: 'payee@example.com',
        status: 'ACTIVE',
        userStage: 'VERIFIED',
        firstName: 'Payee',
        lastName: 'Example',
      );

      when(() => harness.transferRepository.lookupWallet('payee@example.com'))
          .thenAnswer((_) async => lookupResponse);

      final notifier = harness.container.read(sendMoneyControllerProvider.notifier);
      final success = await notifier.lookupWallet('payee@example.com');

      expect(success, isTrue);
      final state = harness.container.read(sendMoneyControllerProvider);
      expect(state.lookupResult, lookupResponse);
      expect(state.currentStep, SendMoneyStep.amountEntry);
    });

    test('previewTransfer validates lookup and amount before calling repository', () async {
      final harness = _SendMoneyTestHarness();
      addTearDown(harness.container.dispose);
      final notifier = harness.container.read(sendMoneyControllerProvider.notifier);

      final missingRecipient = await notifier.previewTransfer(Money.fromMajor(10));
      expect(missingRecipient, isFalse);
      expect(
        harness.container.read(sendMoneyControllerProvider).errorMessage,
        'No recipient selected',
      );

      final lookupResponse = WalletLookupResponse(
        userId: 'user-123',
        email: 'payee@example.com',
        status: 'ACTIVE',
        userStage: 'VERIFIED',
      );
      when(() => harness.transferRepository.lookupWallet(any()))
          .thenAnswer((_) async => lookupResponse);
      await notifier.lookupWallet('payee@example.com');

      final invalidAmount = await notifier.previewTransfer(Money.fromMajor(0));
      expect(invalidAmount, isFalse);
      expect(
        harness.container.read(sendMoneyControllerProvider).errorMessage,
        'Please enter a valid amount',
      );
    });

    test('previewTransfer populates preview result and moves to preview step', () async {
      final harness = _SendMoneyTestHarness();
      addTearDown(harness.container.dispose);
      final amount = Money.fromMajor(25);
      final lookupResponse = WalletLookupResponse(
        userId: 'user-123',
        email: 'payee@example.com',
        status: 'ACTIVE',
        userStage: 'VERIFIED',
      );
      final previewResponse = TransferPreviewResponse(
        fromWalletId: 'wallet-a',
        toWalletId: 'wallet-b',
        transferAmount: amount,
        estimatedFee: Money.fromMajor(0.5),
        feeAppliedTo: 'sender',
        totalDebit: Money.fromMajor(25.5),
        senderBalanceBefore: Money.fromMajor(200),
        senderBalanceAfter: Money.fromMajor(174.5),
        receiverCreditAmount: amount,
      );

      when(() => harness.transferRepository.lookupWallet(any()))
          .thenAnswer((_) async => lookupResponse);
      when(() => harness.transferRepository.previewTransfer('user-123', amount))
          .thenAnswer((_) async => previewResponse);

      final notifier = harness.container.read(sendMoneyControllerProvider.notifier);
      await notifier.lookupWallet('payee@example.com');
      final success = await notifier.previewTransfer(amount);

      expect(success, isTrue);
      final state = harness.container.read(sendMoneyControllerProvider);
      expect(state.previewResult, previewResponse);
      expect(state.currentStep, SendMoneyStep.preview);
    });

    test('confirmTransfer executes transfer and refreshes dashboard balance', () async {
      final harness = _SendMoneyTestHarness();
      addTearDown(harness.container.dispose);
      final amount = Money.fromMajor(10);
      final lookupResponse = WalletLookupResponse(
        userId: 'user-789',
        email: 'recipient@example.com',
        status: 'ACTIVE',
        userStage: 'VERIFIED',
      );
      final previewResponse = TransferPreviewResponse(
        fromWalletId: 'wallet-a',
        toWalletId: 'wallet-b',
        transferAmount: amount,
        estimatedFee: Money.fromMajor(0),
        feeAppliedTo: 'sender',
        totalDebit: amount,
        senderBalanceBefore: Money.fromMajor(100),
        senderBalanceAfter: Money.fromMajor(90),
        receiverCreditAmount: amount,
      );
      final transferResponse = TransferResponse(
        fromWalletId: 'wallet-a',
        reference: 'TRX-1',
        amount: amount,
        fromBalance: Money.fromMajor(90),
        currency: 'USD',
      );

      when(() => harness.transferRepository.lookupWallet(any()))
          .thenAnswer((_) async => lookupResponse);
      when(() => harness.transferRepository.previewTransfer(any(), any()))
          .thenAnswer((_) async => previewResponse);
      when(
        () => harness.transferRepository.executeTransfer(
          any(),
          any(),
          any(),
          description: any(named: 'description'),
          expectedSenderBalanceAfter: any(named: 'expectedSenderBalanceAfter'),
        ),
      ).thenAnswer((_) async => transferResponse);

      final notifier = harness.container.read(sendMoneyControllerProvider.notifier);
      await notifier.lookupWallet('recipient@example.com');
      await notifier.previewTransfer(amount);
      final success = await notifier.confirmTransfer();

      expect(success, isTrue);
      final state = harness.container.read(sendMoneyControllerProvider);
      expect(state.transferResult, transferResponse);
      expect(state.transferSuccess, isTrue);
      expect(state.currentStep, SendMoneyStep.result);
      expect(harness.dashboardController.refreshCalls, greaterThanOrEqualTo(1));
    });
  });
}

class _SendMoneyTestHarness {
  _SendMoneyTestHarness()
      : transferRepository = _MockTransferRepository(),
        dashboardController = _StubDashboardController() {
    container = ProviderContainer(
      overrides: [
        transferRepositoryProvider.overrideWithValue(transferRepository),
        dashboardControllerProvider.overrideWith(() => dashboardController),
      ],
    );
  }

  final _MockTransferRepository transferRepository;
  final _StubDashboardController dashboardController;
  late final ProviderContainer container;
}

class _StubDashboardController extends DashboardController {
  int refreshCalls = 0;

  @override
  DashboardState build() => const DashboardState();

  @override
  Future<void> refreshBalance({bool showSpinner = true}) async {
    refreshCalls += 1;
  }
}
