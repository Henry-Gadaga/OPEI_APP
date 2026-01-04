import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opei/data/models/p2p_ad.dart';
import 'package:opei/data/models/p2p_trade.dart';
import 'package:opei/features/p2p/p2p_controller.dart';
import 'package:opei/features/p2p/p2p_screen.dart';
import 'package:opei/features/p2p/p2p_state.dart';
import 'package:opei/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('P2PExchangeScreen', () {
    testWidgets('shows info message when there are no ads', (tester) async {
      final adsController = _StubAdsController(
        const P2PAdsState(
          hasLoaded: true,
          infoMessage: 'Come back soon.',
        ),
      );

      await _pumpP2PScreen(tester, adsController: adsController);

      expect(find.text('Come back soon.'), findsOneWidget);
    });

    testWidgets('tapping Sell toggle requests ads controller to update type', (tester) async {
      final adsController = _StubAdsController(
        const P2PAdsState(
          hasLoaded: true,
          selectedType: P2PAdType.buy,
        ),
      );

      await _pumpP2PScreen(tester, adsController: adsController);

      await tester.tap(find.text('Sell').first);
      await tester.pump();

      expect(adsController.updateTypeCalls, contains(P2PAdType.sell));
    });
  });
}

Future<void> _pumpP2PScreen(
  WidgetTester tester, {
  required _StubAdsController adsController,
}) async {
  await tester.binding.setSurfaceSize(const Size(430, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final router = GoRouter(
    initialLocation: '/p2p',
    routes: [
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
        p2pOrdersControllerProvider.overrideWith(
          () => _StubOrdersController(const P2POrdersState(hasLoaded: true)),
        ),
        myP2PAdsControllerProvider.overrideWith(
          () => _StubMyAdsController(const MyP2PAdsState(hasLoaded: true)),
        ),
        p2pProfileControllerProvider.overrideWith(
          () => _StubProfileController(const P2PProfileState(hasLoaded: true)),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
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
      ),
    ),
  );

  await tester.pumpAndSettle();
}

class _StubAdsController extends P2PAdsController {
  _StubAdsController(this.initialState);

  final P2PAdsState initialState;
  final List<P2PAdType> updateTypeCalls = [];

  @override
  P2PAdsState build() => initialState;

  @override
  Future<void> ensureInitialLoad() async {}

  @override
  Future<void> reload() async {}

  @override
  Future<void> refresh() async {}

  @override
  Future<void> updateType(P2PAdType type) async {
    updateTypeCalls.add(type);
    state = state.copyWith(selectedType: type);
  }
}

class _StubOrdersController extends P2POrdersController {
  _StubOrdersController(this.initialState);

  final P2POrdersState initialState;

  @override
  P2POrdersState build() => initialState;

  @override
  Future<void> ensureInitialLoad() async {}

  @override
  Future<void> refresh() async {}

  @override
  Future<P2PTrade> cancelTrade(P2PTrade trade) async => trade;
}

class _StubMyAdsController extends MyP2PAdsController {
  _StubMyAdsController(this.initialState);

  final MyP2PAdsState initialState;

  @override
  MyP2PAdsState build() => initialState;

  @override
  Future<void> ensureInitialLoad() async {}

  @override
  Future<void> refresh() async {}
}

class _StubProfileController extends P2PProfileController {
  _StubProfileController(this.initialState);

  final P2PProfileState initialState;

  @override
  P2PProfileState build() => initialState;

  @override
  Future<void> ensureProfileLoaded() async {}

  @override
  Future<void> refresh() async {}
}
