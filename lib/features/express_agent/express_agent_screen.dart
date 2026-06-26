import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/core/providers/express_agent_access_provider.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/models/express_order.dart';
import 'package:opei/features/express_p2p/express_ui.dart';
import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/theme.dart';
import 'package:url_launcher/url_launcher.dart';

/// Express Agent work area. Embedded as a bottom-nav tab and shown only when the
/// signed-in user is a registered agent (`isAgent == true`). Accept/confirm are
/// disabled when the agent account is inactive (`isActive == false`).
class ExpressAgentScreen extends ConsumerStatefulWidget {
  const ExpressAgentScreen({super.key});

  @override
  ConsumerState<ExpressAgentScreen> createState() => _ExpressAgentScreenState();
}

class _ExpressAgentScreenState extends ConsumerState<ExpressAgentScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _lastTabIndex = 0;

  List<ExpressOrder> _available = const <ExpressOrder>[];
  List<ExpressOrder> _mine = const <ExpressOrder>[];
  bool _loading = true;
  bool _loadingRequestInFlight = false;
  String? _error;
  String? _acceptingId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _lastTabIndex = _tabController.index;
    _tabController.addListener(_handleTabChanged);
    _load();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    // Trigger refresh once a swipe/tap tab transition has completed.
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == _lastTabIndex) return;
    _lastTabIndex = _tabController.index;
    _load();
  }

  Future<void> _load() async {
    if (_loadingRequestInFlight) return;
    _loadingRequestInFlight = true;
    setState(() {
      _loading = true;
      _error = null;
      // Clear stale lists so only loader is visible while fetching.
      _available = const <ExpressOrder>[];
      _mine = const <ExpressOrder>[];
    });
    try {
      final repo = ref.read(expressOrderRepositoryProvider);
      final results = await Future.wait([
        repo.fetchAvailableOrders(),
        repo.fetchAgentOrders(),
      ]);
      if (!mounted) return;
      setState(() {
        _available = results[0];
        _mine = results[1];
        _loading = false;
      });
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = ErrorHelper.getErrorMessage(e);
        _loading = false;
      });
    } finally {
      _loadingRequestInFlight = false;
    }
  }

  Future<void> _accept(ExpressOrder order) async {
    if (_acceptingId != null) return;
    final confirmed = await _confirmAccept(order);
    if (confirmed != true) return;

    setState(() => _acceptingId = order.id);
    try {
      await ref.read(expressOrderRepositoryProvider).acceptOrder(order.id);
      if (!mounted) return;
      setState(() => _acceptingId = null);
      _toast(
        AppLocalizations.of(context)!.expressOrderAcceptedToast,
        OpeiBrand.success,
      );
      _tabController.animateTo(1);
      await _load();
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _acceptingId = null);
      _toast(e.message, OpeiBrand.danger);
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() => _acceptingId = null);
      _toast(ErrorHelper.getErrorMessage(e), OpeiBrand.danger);
    }
  }

  Future<bool?> _confirmAccept(ExpressOrder order) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OpeiBrand.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
        ),
        title: Text(
          AppLocalizations.of(context)!.expressAcceptOrderTitle,
          style: const TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: OpeiBrand.ink,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)!
              .expressAcceptOrderMessage(expressUsd(order.amountUsdCents)),
          style: const TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: 13.5,
            color: OpeiBrand.inkSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              AppLocalizations.of(context)!.cancelCta,
              style: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                color: OpeiBrand.inkSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: OpeiBrand.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.expressAcceptCta,
              style: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openOrder(ExpressOrder order) async {
    await context.push(
      '/express-agent/order/${order.id}',
      extra: order.buyerContactNumber,
    );
    if (mounted) _load();
  }

  void _toast(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final access = ref.watch(expressAgentAccessProvider);
    final topPad = MediaQuery.of(context).viewPadding.top;

    final queue = _mine.where((o) => o.status.isActive).toList();
    final history = _mine.where((o) => o.status.isTerminal).toList();

    return Scaffold(
      backgroundColor: OpeiBrand.surface,
      body: Column(
        children: [
          _Header(topPad: topPad, onRefresh: _load),
          if (!access.isActive) const _InactiveBanner(),
          Container(
            color: OpeiBrand.surface,
            child: TabBar(
              controller: _tabController,
              onTap: (index) {
                // Always refresh immediately on tab open to avoid stale flashes.
                _load();
              },
              labelColor: OpeiBrand.primary,
              unselectedLabelColor: OpeiBrand.inkTertiary,
              indicatorColor: OpeiBrand.primary,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
              tabs: [
                Tab(
                  text: AppLocalizations.of(context)!
                      .expressTabAvailable(_available.length),
                ),
                Tab(
                  text: AppLocalizations.of(context)!
                      .expressTabQueue(queue.length),
                ),
                Tab(text: AppLocalizations.of(context)!.expressTabHistory),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: OpeiBrand.primary),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _OrderList(
                        orders: _available,
                        emptyText: AppLocalizations.of(context)!
                            .expressNoAvailableOrders,
                        error: _error,
                        onRefresh: _load,
                        builder: (o) => _AvailableCard(
                          order: o,
                          accepting: _acceptingId == o.id,
                          canAccept: access.isActive && _acceptingId == null,
                          onAccept: () => _accept(o),
                        ),
                      ),
                      _OrderList(
                        orders: queue,
                        emptyText:
                            AppLocalizations.of(context)!.expressNoQueueOrders,
                        error: _error,
                        onRefresh: _load,
                        builder: (o) =>
                            _QueueCard(order: o, onTap: () => _openOrder(o)),
                      ),
                      _OrderList(
                        orders: history,
                        emptyText: AppLocalizations.of(context)!
                            .expressNoCompletedOrders,
                        error: _error,
                        onRefresh: _load,
                        builder: (o) =>
                            _QueueCard(order: o, onTap: () => _openOrder(o)),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final double topPad;
  final VoidCallback onRefresh;

  const _Header({required this.topPad, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPad + 16, 12, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E55D8), Color(0xFF3D7BFF)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.expressAgentTitle,
                  style: const TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context)!.expressAgentSubtitle,
                  style: const TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: AppLocalizations.of(context)!.refreshCta,
          ),
        ],
      ),
    );
  }
}

class _InactiveBanner extends StatelessWidget {
  const _InactiveBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF4E0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 16, color: OpeiBrand.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.expressAgentInactiveViewOnly,
              style: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 12.5,
                color: Color(0xFF8A5A00),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<ExpressOrder> orders;
  final String emptyText;
  final String? error;
  final Future<void> Function() onRefresh;
  final Widget Function(ExpressOrder) builder;

  const _OrderList({
    required this.orders,
    required this.emptyText,
    required this.error,
    required this.onRefresh,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: OpeiBrand.primary,
      child: orders.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              children: [
                const SizedBox(height: 80),
                Center(
                  child: Text(
                    error ?? emptyText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 14,
                      color: OpeiBrand.inkSecondary,
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              itemCount: orders.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: builder(orders[i]),
              ),
            ),
    );
  }
}

class _AvailableCard extends StatelessWidget {
  final ExpressOrder order;
  final bool accepting;
  final bool canAccept;
  final VoidCallback onAccept;

  const _AvailableCard({
    required this.order,
    required this.accepting,
    required this.canAccept,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final provider = order.paymentMethodType?.providerName ?? '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OpeiBrand.surface,
        borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
        border: Border.all(color: OpeiBrand.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                expressUsd(order.amountUsdCents),
                style: const TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: OpeiBrand.ink,
                  letterSpacing: -0.4,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  expressFiat(order.fiatAmountCents, order.quoteCurrency),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: OpeiBrand.inkSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (provider.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              provider,
              style: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: OpeiBrand.inkTertiary,
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (canAccept && !accepting) ? onAccept : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: OpeiBrand.primary,
                disabledBackgroundColor: OpeiBrand.primaryTintStrong,
                elevation: 0,
                minimumSize: const Size.fromHeight(48),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: accepting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      AppLocalizations.of(context)!.expressAcceptOrderCta,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueCard extends StatelessWidget {
  final ExpressOrder order;
  final VoidCallback onTap;

  const _QueueCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final view = expressAgentStatusView(
      order.status,
      AppLocalizations.of(context)!,
    );
    final provider = order.paymentMethodType?.providerName ?? '';
    final showBuyerNumber = order.status.shouldShowContact;
    final buyerNumber = order.buyerContactNumber;
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
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: OpeiBrand.inkSecondary,
                      ),
                    ),
                    if (showBuyerNumber) ...[
                      const SizedBox(height: 7),
                      _AgentContactRow(
                        number: buyerNumber,
                        onCall: buyerNumber == null
                            ? null
                            : () => _callBuyer(context, buyerNumber),
                        onCopy: buyerNumber == null
                            ? null
                            : () => _copyBuyer(context, buyerNumber),
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

  Future<void> _callBuyer(BuildContext context, String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.couldNotOpenDialer),
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

  Future<void> _copyBuyer(BuildContext context, String phoneNumber) async {
    await Clipboard.setData(ClipboardData(text: phoneNumber));
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.buyerNumberCopied),
        backgroundColor: OpeiBrand.ink,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }
}

class _AgentContactRow extends StatelessWidget {
  final String? number;
  final VoidCallback? onCall;
  final VoidCallback? onCopy;

  const _AgentContactRow({required this.number, this.onCall, this.onCopy});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final contact = number?.trim();
    final hasNumber = contact != null && contact.isNotEmpty;
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
              hasNumber
                  ? contact
                  : AppLocalizations.of(context)!.expressBuyerContactUnavailable,
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
          if (hasNumber) ...[
            _CompactActionButton(
              label: l10n.depositCopyCta,
              icon: Icons.content_copy_rounded,
              onTap: onCopy,
              background: Colors.white,
              foreground: OpeiBrand.inkSecondary,
            ),
            const SizedBox(width: 6),
            _CompactActionButton(
              label: l10n.callCta,
              icon: Icons.call_rounded,
              onTap: onCall,
              background: OpeiBrand.primary,
              foreground: Colors.white,
            ),
          ],
        ],
      ),
    );
  }
}

class _CompactActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color background;
  final Color foreground;

  const _CompactActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
          border: background == Colors.white
              ? Border.all(color: OpeiBrand.hairlineStrong)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11.5, color: foreground),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
