import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/models/express_order.dart';
import 'package:opei/features/express_p2p/express_ui.dart';
import 'package:opei/theme.dart';
import 'package:url_launcher/url_launcher.dart';

/// Entry hub for Express P2P (customer). Shows active orders + history and a
/// button to start a new deposit. Source of truth is `GET /express-orders/mine`.
class ExpressP2PHubScreen extends ConsumerStatefulWidget {
  const ExpressP2PHubScreen({super.key});

  @override
  ConsumerState<ExpressP2PHubScreen> createState() =>
      _ExpressP2PHubScreenState();
}

class _ExpressP2PHubScreenState extends ConsumerState<ExpressP2PHubScreen> {
  List<ExpressOrder> _orders = const <ExpressOrder>[];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final orders = await ref
          .read(expressOrderRepositoryProvider)
          .fetchMyOrders();
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = ErrorHelper.getErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _startNew() async {
    await context.push('/express-p2p/setup');
    if (mounted) _load();
  }

  Future<void> _openOrder(ExpressOrder order) async {
    await context.push('/express-p2p/order/${order.id}');
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).viewPadding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: OpeiBrand.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: OpeiBrand.surface,
        body: RefreshIndicator(
          onRefresh: _load,
          color: OpeiBrand.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: _Header(topPad: topPad, onBack: _handleBack),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(_buildBody()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBody() {
    if (_isLoading) {
      return const [
        SizedBox(height: 80),
        Center(child: CircularProgressIndicator(color: OpeiBrand.primary)),
      ];
    }

    if (_error != null) {
      return [
        const SizedBox(height: 24),
        _StartNewButton(onTap: _startNew),
        const SizedBox(height: 32),
        _ErrorState(message: _error!, onRetry: _load),
      ];
    }

    final active = _orders.where((o) => o.status.isActive).toList();
    final history = _orders.where((o) => o.status.isTerminal).toList();

    return [
      _StartNewButton(onTap: _startNew),
      const SizedBox(height: 18),
      if (active.isNotEmpty) ...[
        const _SectionLabel('ACTIVE'),
        const SizedBox(height: 10),
        ...active.map(
          (o) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _OrderCard(order: o, onTap: () => _openOrder(o)),
          ),
        ),
        const SizedBox(height: 14),
      ],
      if (history.isNotEmpty) ...[
        const _SectionLabel('HISTORY'),
        const SizedBox(height: 10),
        ...history.map(
          (o) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _OrderCard(order: o, onTap: () => _openOrder(o)),
          ),
        ),
      ],
      if (active.isEmpty && history.isEmpty) ...[
        const SizedBox(height: 40),
        const _EmptyState(),
      ],
    ];
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go('/dashboard');
  }
}

class _Header extends StatelessWidget {
  final double topPad;
  final VoidCallback onBack;
  const _Header({required this.topPad, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E55D8), Color(0xFF3D7BFF)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 20, 14),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Express P2P',
                      style: TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.4,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pay local currency · get USD fast',
                      style: TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.70),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartNewButton extends StatelessWidget {
  final VoidCallback onTap;
  const _StartNewButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: OpeiBrand.primaryTint,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: OpeiBrand.primary,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Start new deposit',
                      style: TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: OpeiBrand.ink,
                        letterSpacing: -0.1,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Choose amount and payment method',
                      style: TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 11.8,
                        fontWeight: FontWeight.w500,
                        color: OpeiBrand.inkSecondary,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: OpeiBrand.primary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: kPrimaryFontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: OpeiBrand.inkTertiary,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final ExpressOrder order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final view = expressCustomerStatusView(order.status);
    final provider = order.paymentMethodType?.providerName ?? '';
    final finalPhone =
        (order.agentContactNumber ?? order.agent?.phoneNumber ?? '').trim();
    final showAgentNumber =
        (order.status == ExpressOrderStatus.awaitingPayment ||
            order.status == ExpressOrderStatus.paidByUser ||
            order.status == ExpressOrderStatus.completed ||
            order.status == ExpressOrderStatus.expired) &&
        order.agent != null &&
        finalPhone.isNotEmpty;

    return Material(
      color: OpeiBrand.surface,
      borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
            border: Border.all(color: OpeiBrand.hairline),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            expressUsd(order.amountUsdCents),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: kPrimaryFontFamily,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: OpeiBrand.ink,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ExpressStatusPill(view: view),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${expressFiat(order.fiatAmountCents, order.quoteCurrency)}'
                      '${provider.isNotEmpty ? ' · $provider' : ''}',
                      style: const TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 12.6,
                        fontWeight: FontWeight.w500,
                        color: OpeiBrand.inkSecondary,
                        letterSpacing: -0.1,
                      ),
                    ),
                    if (showAgentNumber) ...[
                      const SizedBox(height: 7),
                      _CustomerContactRow(
                        number: finalPhone,
                        onCall: () => _callNumber(context, finalPhone),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: OpeiBrand.inkTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _callNumber(BuildContext context, String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not open dialer.'),
          backgroundColor: OpeiBrand.ink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
    }
  }
}

class _CustomerContactRow extends StatelessWidget {
  final String number;
  final VoidCallback onCall;

  const _CustomerContactRow({required this.number, required this.onCall});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: OpeiBrand.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.phone_rounded,
            size: 13,
            color: OpeiBrand.inkTertiary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              number,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: OpeiBrand.inkSecondary,
              ),
            ),
          ),
          GestureDetector(
            onTap: onCall,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: OpeiBrand.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.call_rounded, size: 12, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Call',
                    style: TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: OpeiBrand.surfaceMuted,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.bolt_rounded,
            size: 26,
            color: OpeiBrand.inkSecondary,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'No deposits yet',
          style: TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: OpeiBrand.ink,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Start a deposit to add USD to your wallet by paying a local agent.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: 13,
            color: OpeiBrand.inkSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: OpeiBrand.surfaceMuted,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.wifi_off_rounded,
            size: 24,
            color: OpeiBrand.inkSecondary,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          "Couldn't load your deposits",
          style: TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: OpeiBrand.ink,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: 13,
            color: OpeiBrand.inkSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: OpeiBrand.primaryTint,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Try again',
              style: TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: OpeiBrand.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
