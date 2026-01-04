import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opei/core/money/money.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/data/models/wallet_balance.dart';
import 'package:opei/data/models/wallet_transaction.dart';
import 'package:opei/data/repositories/transaction_repository.dart';
import 'package:opei/data/repositories/wallet_repository.dart';
import 'package:opei/features/dashboard/dashboard_controller.dart';
import 'package:opei/features/dashboard/dashboard_state.dart';

class _MockWalletRepository extends Mock implements WalletRepository {}

class _MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DashboardController', () {
    test('ensureBalanceLoaded fetches wallet and transactions for active user', () async {
      final walletRepository = _MockWalletRepository();
      final transactionsRepository = _MockTransactionRepository();
      final wallet = WalletBalance(
        walletId: 'wallet-1',
        userId: 'user-1',
        balance: Money.fromMajor(150),
        reservedBalance: Money.fromMajor(10),
      );
      final transaction = WalletTransaction(
        id: 'tx-1',
        title: 'Deposit',
        currency: 'USD',
        amount: Money.fromMajor(50),
        isCredit: true,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
        status: 'COMPLETED',
        reference: 'ref',
        rawType: 'deposit',
        description: 'Test',
        direction: 'IN',
        metadata: null,
      );

      when(() => walletRepository.getWallet('user-1')).thenAnswer((_) async => wallet);
      when(() => transactionsRepository.getRecentTransactions('user-1'))
          .thenAnswer((_) async => [transaction]);

      final container = _createDashboardContainer(
        walletRepository: walletRepository,
        transactionRepository: transactionsRepository,
        authSession: const AuthSession(userId: 'user-1', accessToken: 'token', sessionNonce: 1),
      );
      addTearDown(container.dispose);

      container.read(dashboardControllerProvider);
      await Future<void>.delayed(const Duration(milliseconds: 200));

      verify(() => walletRepository.getWallet('user-1')).called(1);
      verify(() => transactionsRepository.getRecentTransactions('user-1')).called(1);

      final state = container.read(dashboardControllerProvider);
      expect(state.wallet, wallet);
      expect(state.recentTransactions, isNotEmpty);
      expect(state.error, isNull);
      expect(state.transactionsError, isNull);
    });

    test('refreshBalance captures wallet errors and surfaces friendly message', () async {
      final walletRepository = _MockWalletRepository();
      final transactionsRepository = _MockTransactionRepository();

      final wallet = WalletBalance(
        walletId: 'wallet-1',
        userId: 'user-1',
        balance: Money.fromMajor(140),
        reservedBalance: Money.fromMajor(0),
      );
      var walletCalls = 0;
      when(() => walletRepository.getWallet('user-1')).thenAnswer((_) async {
        walletCalls += 1;
        if (walletCalls == 1) {
          return wallet;
        }
        throw ApiError(message: 'Wallet service unavailable');
      });
      when(() => transactionsRepository.getRecentTransactions('user-1'))
          .thenAnswer((_) async => const []);

      final container = _createDashboardContainer(
        walletRepository: walletRepository,
        transactionRepository: transactionsRepository,
        authSession: const AuthSession(userId: 'user-1', accessToken: 'token', sessionNonce: 1),
      );
      addTearDown(container.dispose);

      container.read(dashboardControllerProvider);
      await Future<void>.delayed(const Duration(milliseconds: 200));

      final controller = container.read(dashboardControllerProvider.notifier);
      await controller.refreshBalance(showSpinner: true);
      await Future<void>.delayed(const Duration(milliseconds: 200));

      final state = container.read(dashboardControllerProvider);
      expect(state.error, 'Wallet service unavailable');
      expect(state.isLoading, isFalse);
      expect(state.isRefreshing, isFalse);
    });
  });
}

ProviderContainer _createDashboardContainer({
  required WalletRepository walletRepository,
  required TransactionRepository transactionRepository,
  required AuthSession authSession,
}) {
  return ProviderContainer(
    overrides: [
      walletRepositoryProvider.overrideWithValue(walletRepository),
      transactionRepositoryProvider.overrideWithValue(transactionRepository),
      authSessionProvider.overrideWith(() => _TestAuthSessionNotifier(authSession)),
    ],
  );
}

class _TestAuthSessionNotifier extends AuthSessionNotifier {
  _TestAuthSessionNotifier(this._initialState);

  final AuthSession _initialState;

  @override
  AuthSession build() => _initialState;
}
