import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opei/core/money/money.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/data/models/p2p_ad.dart';
import 'package:opei/data/models/p2p_trade.dart';
import 'package:opei/data/repositories/p2p_repository.dart';
import 'package:opei/features/p2p/p2p_controller.dart';

class _MockP2PRepository extends Mock implements P2PRepository {}

void main() {
  late _MockP2PRepository repository;

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        p2pRepositoryProvider.overrideWithValue(repository),
      ],
    );
  }

  setUp(() {
    repository = _MockP2PRepository();
  });

  group('P2PAdsController', () {
    test('updateAmountBounds shows error when min is greater than max', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      final controller = container.read(p2pAdsControllerProvider.notifier);

      await controller.updateAmountBounds(minAmountCents: 20000, maxAmountCents: 1000);

      final state = container.read(p2pAdsControllerProvider);
      expect(state.errorMessage, 'The minimum amount can’t be higher than the maximum.');
      verifyZeroInteractions(repository);
    });

    test('updatePaymentMethod filters ads list by provider label', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      final controller = container.read(p2pAdsControllerProvider.notifier);

      final ads = [
        _buildAd(id: 'buy-1', providerLabel: 'Bank Transfer'),
        _buildAd(id: 'buy-2', providerLabel: 'Mobile Money'),
      ];

      controller.state = controller.state.copyWith(
        allAds: ads,
        filteredAds: ads,
        paymentMethods: const ['Bank Transfer', 'Mobile Money'],
      );

      controller.updatePaymentMethod('Bank Transfer');

      final state = container.read(p2pAdsControllerProvider);
      expect(state.filteredAds.map((ad) => ad.id), ['buy-1']);
      expect(state.infoMessage, isNull);
    });
  });

  group('P2POrdersController', () {
    test('cancelTrade marks trade cancelling, calls repository, and refreshes', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      final controller = container.read(p2pOrdersControllerProvider.notifier);
      final trade = _buildTrade(id: 'trade-1', status: P2PTradeStatus.initiated);
      final cancelled = _buildTrade(id: 'trade-1', status: P2PTradeStatus.cancelled);

      controller.state = controller.state.copyWith(
        trades: [trade],
        hasLoaded: true,
      );

      when(() => repository.cancelTrade(tradeId: trade.id)).thenAnswer((_) async => cancelled);
      when(() => repository.fetchMyTrades(status: null))
          .thenAnswer((_) async => const []);

      final result = await controller.cancelTrade(trade);

      expect(result.status, P2PTradeStatus.cancelled);
      final state = container.read(p2pOrdersControllerProvider);
      expect(state.cancellingTradeIds, isEmpty);
      verify(() => repository.cancelTrade(tradeId: trade.id)).called(1);
      verify(() => repository.fetchMyTrades(status: null)).called(greaterThanOrEqualTo(1));
    });
  });
}

P2PAd _buildAd({required String id, required String providerLabel}) {
  return P2PAd(
    id: id,
    userId: 'user-$id',
    type: P2PAdType.buy,
    currency: 'USD',
    totalAmount: Money.fromMajor(100),
    remainingAmount: Money.fromMajor(80),
    minOrder: Money.fromMajor(10),
    maxOrder: Money.fromMajor(50),
    rate: Money.fromMajor(1),
    instructions: '',
    status: 'ACTIVE',
    paymentMethods: [
      P2PAdPaymentMethod(
        id: 'pm-$id',
        providerName: providerLabel,
        methodType: 'BANK',
        currency: 'USD',
      ),
    ],
    seller: const P2PAdSeller(
      id: 'seller',
      displayName: 'Seller',
      nickname: 'seller',
      rating: 4.5,
      totalTrades: 10,
    ),
  );
}

P2PTrade _buildTrade({required String id, required P2PTradeStatus status}) {
  final summary = P2PTradeAdSummary(
    id: 'ad-$id',
    type: P2PAdType.sell,
    currency: 'USD',
    rate: Money.fromMajor(1),
    paymentMethods: const [],
  );

  return P2PTrade(
    id: id,
    adId: summary.id,
    buyerId: 'buyer',
    sellerId: 'seller',
    amount: Money.fromMajor(50),
    sendAmount: Money.fromMajor(50),
    rate: Money.fromMajor(1),
    currency: 'USD',
    status: status,
    expiresAt: DateTime.now(),
    paidAt: null,
    releasedAt: null,
    completedAt: null,
    cancelledAt: null,
    cancelReason: null,
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    updatedAt: DateTime.now(),
    ad: summary,
    selectedPaymentMethod: null,
    proofs: const [],
    yourRating: const P2PTradeRating.empty(),
    canRate: false,
    ratingPending: false,
    isRatedByMe: false,
  );
}
