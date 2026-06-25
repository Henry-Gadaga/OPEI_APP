import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/data/models/express_agent_status.dart';
import 'package:opei/data/models/express_order.dart';
import 'package:opei/data/repositories/express_order_repository.dart';
import 'package:opei/features/express_agent/express_agent_order_screen.dart';
import 'package:opei/features/express_agent/express_agent_screen.dart';
import 'package:opei/features/express_p2p/express_order_detail_screen.dart';
import 'package:opei/features/express_p2p/express_p2p_hub_screen.dart';

const _viewports = <({String label, Size size})>[
  (label: 'iPhone SE 320x568', size: Size(320, 568)),
  (label: 'Galaxy A10 360x640', size: Size(360, 640)),
  (label: 'iPhone 14 393x852', size: Size(393, 852)),
  (label: 'iPhone 15 Pro Max 430x932', size: Size(430, 932)),
  (label: 'iPad mini 768x1024', size: Size(768, 1024)),
];

class _MockExpressOrderRepository extends Mock
    implements ExpressOrderRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const customerOrderId = 'customer-order-1';
  const agentOrderId = 'agent-order-1';

  final customerOrder = ExpressOrder(
    id: customerOrderId,
    userId: 'user-1',
    status: ExpressOrderStatus.awaitingPayment,
    amountUsdCents: 1200,
    lockedRateCents: 7400,
    fiatAmountCents: 88800,
    quoteCurrency: 'MZN',
    agent: const ExpressOrderAgent(
      id: 'agent-profile-1',
      userId: 'agent-user-1',
      isActive: true,
      phoneNumber: '+26312345678',
    ),
    agentPaymentMethod: const ExpressAgentPaymentMethod(
      accountName: 'Agent Account',
      accountNumber: '258840001111',
      providerName: 'M-Pesa',
    ),
    agentContactNumber: '+26312345678',
  );

  final agentOrder = ExpressOrder(
    id: agentOrderId,
    userId: 'buyer-1',
    status: ExpressOrderStatus.paidByUser,
    amountUsdCents: 1200,
    lockedRateCents: 7400,
    fiatAmountCents: 88800,
    quoteCurrency: 'MZN',
    buyerContactNumber: '+16865656555',
    proofUrls: const <String>[
      'https://example.com/proof-1.jpg',
      'https://example.com/proof-2.jpg',
    ],
  );

  // Stress values: very large amounts/fiat to expose any header overflow.
  final largeOrders = <ExpressOrder>[
    ExpressOrder(
      id: 'list-order-1',
      userId: 'user-1',
      status: ExpressOrderStatus.awaitingPayment,
      amountUsdCents: 999999900,
      lockedRateCents: 7400,
      fiatAmountCents: 9999999900,
      quoteCurrency: 'MZN',
      agent: const ExpressOrderAgent(
        id: 'agent-profile-1',
        userId: 'agent-user-1',
        isActive: true,
        phoneNumber: '+26312345678',
      ),
      agentContactNumber: '+26312345678',
      paymentMethodType: const ExpressMethodType(
        id: 'pm-1',
        providerName: 'M-Pesa',
        methodType: 'MOBILE_MONEY',
        currency: 'MZN',
      ),
    ),
    ExpressOrder(
      id: 'list-order-2',
      userId: 'buyer-1',
      status: ExpressOrderStatus.paidByUser,
      amountUsdCents: 999999900,
      lockedRateCents: 7400,
      fiatAmountCents: 9999999900,
      quoteCurrency: 'MZN',
      buyerContactNumber: '+16865656555',
      paymentMethodType: const ExpressMethodType(
        id: 'pm-1',
        providerName: 'M-Pesa',
        methodType: 'MOBILE_MONEY',
        currency: 'MZN',
      ),
    ),
  ];

  group('Express multi-viewport responsiveness', () {
    for (final vp in _viewports) {
      testWidgets(
        'Customer express order detail has no layout errors on ${vp.label}',
        (tester) async {
          final repo = _MockExpressOrderRepository();
          when(
            () => repo.fetchOrder(customerOrderId),
          ).thenAnswer((_) async => customerOrder);

          await tester.binding.setSurfaceSize(vp.size);
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                expressOrderRepositoryProvider.overrideWithValue(repo),
              ],
              child: const MaterialApp(
                home: ExpressOrderDetailScreen(orderId: customerOrderId),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.byType(ExpressOrderDetailScreen), findsOneWidget);
          expect(find.text("I've paid — upload proof"), findsOneWidget);
        },
      );

      testWidgets(
        'Agent express order detail has no layout errors on ${vp.label}',
        (tester) async {
          final repo = _MockExpressOrderRepository();
          when(
            () => repo.fetchOrder(agentOrderId),
          ).thenAnswer((_) async => agentOrder);

          await tester.binding.setSurfaceSize(vp.size);
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                expressOrderRepositoryProvider.overrideWithValue(repo),
              ],
              child: const MaterialApp(
                home: ExpressAgentOrderScreen(orderId: agentOrderId),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.byType(ExpressAgentOrderScreen), findsOneWidget);
          expect(find.text('Confirm payment received'), findsOneWidget);
        },
      );

      testWidgets(
        'Customer hub list (large amounts) has no overflow on ${vp.label}',
        (tester) async {
          final repo = _MockExpressOrderRepository();
          when(() => repo.fetchMyOrders()).thenAnswer((_) async => largeOrders);

          await tester.binding.setSurfaceSize(vp.size);
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                expressOrderRepositoryProvider.overrideWithValue(repo),
              ],
              child: const MaterialApp(home: ExpressP2PHubScreen()),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.byType(ExpressP2PHubScreen), findsOneWidget);
        },
      );

      testWidgets(
        'Agent queue list (large amounts) has no overflow on ${vp.label}',
        (tester) async {
          final repo = _MockExpressOrderRepository();
          when(() => repo.getAgentStatus()).thenAnswer(
            (_) async => const ExpressAgentStatus(
              isAgent: true,
              isActive: true,
              agentProfileId: 'agent-profile-1',
            ),
          );
          when(
            () => repo.fetchAvailableOrders(),
          ).thenAnswer((_) async => largeOrders);
          when(
            () => repo.fetchAgentOrders(),
          ).thenAnswer((_) async => largeOrders);

          await tester.binding.setSurfaceSize(vp.size);
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                expressOrderRepositoryProvider.overrideWithValue(repo),
              ],
              child: const MaterialApp(home: ExpressAgentScreen()),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.byType(ExpressAgentScreen), findsOneWidget);
        },
      );
    }
  });
}
