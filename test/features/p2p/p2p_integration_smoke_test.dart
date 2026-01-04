import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opei/data/models/p2p_trade.dart';
import 'package:opei/data/models/p2p_ad.dart';
import 'package:opei/features/p2p/p2p_controller.dart';
import 'package:opei/features/p2p/p2p_screen.dart';
import 'package:opei/features/p2p/p2p_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('navigates to P2P flow and syncs tab controllers', (tester) async {
    await tester.binding.setSurfaceSize(const Size(450, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final adsController = _TrackingAdsController();
    final ordersController = _TrackingOrdersController();
    final myAdsController = _TrackingMyAdsController();
    final profileController = _TrackingProfileController();

    final router = GoRouter(
      initialLocation: '/dashboard',
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const _DashboardStub(),
        ),
        GoRoute(
          path: '/p2p',
          builder: (context, state) => const P2PExchangeScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          p2pAdsControllerProvider.overrideWith(() => adsController),
          p2pOrdersControllerProvider.overrideWith(() => ordersController),
          myP2PAdsControllerProvider.overrideWith(() => myAdsController),
          p2pProfileControllerProvider.overrideWith(() => profileController),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    expect(find.text('Dashboard Home'), findsOneWidget);

    await tester.tap(find.text('Open P2P'));
    await tester.pumpAndSettle();

    expect(find.text('P2P'), findsWidgets);
    await tester.pump();

    expect(adsController.ensureInitialLoadCalls, greaterThanOrEqualTo(1));

    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();
    expect(ordersController.ensureInitialLoadCalls, greaterThanOrEqualTo(1));

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(profileController.ensureProfileCalls, greaterThanOrEqualTo(1));

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(adsController.refreshCalls, greaterThanOrEqualTo(1));
  });
}

class _DashboardStub extends StatelessWidget {
  const _DashboardStub();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Dashboard Home'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go('/p2p'),
              child: const Text('Open P2P'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackingAdsController extends P2PAdsController {
  int ensureInitialLoadCalls = 0;
  int refreshCalls = 0;

  @override
  P2PAdsState build() => const P2PAdsState();

  @override
  Future<void> ensureInitialLoad() async {
    ensureInitialLoadCalls += 1;
    state = state.copyWith(hasLoaded: true);
  }

  @override
  Future<void> refresh() async {
    refreshCalls += 1;
  }

  @override
  Future<void> reload() async {}

  @override
  Future<void> updateType(P2PAdType type) async {
    state = state.copyWith(selectedType: type);
  }
}

class _TrackingOrdersController extends P2POrdersController {
  int ensureInitialLoadCalls = 0;

  @override
  P2POrdersState build() => const P2POrdersState();

  @override
  Future<void> ensureInitialLoad() async {
    ensureInitialLoadCalls += 1;
    state = state.copyWith(hasLoaded: true);
  }

  @override
  Future<void> refresh() async {}

  @override
  Future<P2PTrade> cancelTrade(P2PTrade trade) async => trade;
}

class _TrackingMyAdsController extends MyP2PAdsController {
  int ensureInitialLoadCalls = 0;

  @override
  MyP2PAdsState build() => const MyP2PAdsState();

  @override
  Future<void> ensureInitialLoad() async {
    ensureInitialLoadCalls += 1;
    state = state.copyWith(hasLoaded: true);
  }

  @override
  Future<void> refresh() async {}
}

class _TrackingProfileController extends P2PProfileController {
  int ensureProfileCalls = 0;

  @override
  P2PProfileState build() => const P2PProfileState();

  @override
  Future<void> ensureProfileLoaded() async {
    ensureProfileCalls += 1;
    state = state.copyWith(hasLoaded: true);
  }

  @override
  Future<void> refresh() async {}
}
