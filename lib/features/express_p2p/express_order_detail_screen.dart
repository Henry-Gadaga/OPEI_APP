import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/models/express_order.dart';
import 'package:opei/data/repositories/express_order_repository.dart';
import 'package:opei/features/dashboard/dashboard_controller.dart';
import 'package:opei/features/express_p2p/express_ui.dart';
import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/theme.dart';
import 'package:url_launcher/url_launcher.dart';

/// Customer order detail. Fetches the order, polls while in a waiting state
/// (every 10s), and renders a status-specific screen:
/// finding agent → pay agent (+ upload proof) → verifying → success / expired.
class ExpressOrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;
  const ExpressOrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<ExpressOrderDetailScreen> createState() =>
      _ExpressOrderDetailScreenState();
}

class _ExpressOrderDetailScreenState
    extends ConsumerState<ExpressOrderDetailScreen> {
  static const Duration _pollInterval = Duration(seconds: 10);

  ExpressOrder? _order;
  bool _loading = true;
  String? _error;

  Timer? _pollTimer;
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;
  bool _walletRefreshed = false;
  bool _cancelling = false;
  bool _openingDispute = false;

  @override
  void initState() {
    super.initState();
    _fetch(initial: true);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetch({bool initial = false}) async {
    if (initial) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final order = await ref
          .read(expressOrderRepositoryProvider)
          .fetchOrder(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = order;
        _loading = false;
        _error = null;
      });
      _afterOrderUpdate(order);
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() {
        if (initial) _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (initial) _error = ErrorHelper.getErrorMessage(e);
        _loading = false;
      });
    }
  }

  void _afterOrderUpdate(ExpressOrder order) {
    // Polling: only while in a waiting state.
    if (order.status.shouldPoll) {
      _ensurePolling();
    } else {
      _pollTimer?.cancel();
      _pollTimer = null;
    }

    // Countdown ticker only while finding an agent.
    if (order.status == ExpressOrderStatus.pendingAgent &&
        order.expiresAt != null) {
      _ensureCountdown(order.expiresAt!);
    } else {
      _countdownTimer?.cancel();
      _countdownTimer = null;
    }

    // Refresh wallet once when the deposit completes.
    if (order.status == ExpressOrderStatus.completed && !_walletRefreshed) {
      _walletRefreshed = true;
      try {
        ref
            .read(dashboardControllerProvider.notifier)
            .refreshBalance(showSpinner: false);
      } catch (_) {
        // Best effort — never block the success screen on a wallet refresh.
      }
    }
  }

  void _ensurePolling() {
    _pollTimer ??= Timer.periodic(_pollInterval, (_) => _fetch());
  }

  void _ensureCountdown(DateTime expiresAt) {
    void update() {
      final remaining = expiresAt.difference(DateTime.now());
      if (!mounted) return;
      setState(() {
        _remaining = remaining.isNegative ? Duration.zero : remaining;
      });
    }

    update();
    _countdownTimer ??= Timer.periodic(
      const Duration(seconds: 1),
      (_) => update(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: OpeiBrand.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: OpeiBrand.surface,
        appBar: AppBar(
          backgroundColor: OpeiBrand.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: OpeiBrand.ink),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Text(
            'Deposit',
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: OpeiBrand.ink,
              letterSpacing: -0.3,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(top: false, child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: OpeiBrand.primary),
      );
    }

    if (_order == null) {
      return _CenteredError(
        message: _error ?? 'Order not found.',
        onRetry: () => _fetch(initial: true),
      );
    }

    final order = _order!;
    final myUserId = ref.read(authSessionProvider).userId;
    final isBuyer = myUserId != null && myUserId == order.userId;
    final canCancel =
        isBuyer &&
        (order.status == ExpressOrderStatus.pendingAgent ||
            order.status == ExpressOrderStatus.awaitingPayment);
    final canDispute =
        isBuyer &&
        order.status == ExpressOrderStatus.paidByUser &&
        (order.dispute == null || order.dispute!.isResolved);
    switch (order.status) {
      case ExpressOrderStatus.pendingAgent:
        return _FindingAgentView(
          order: order,
          remaining: _remaining,
          onLeave: _goToExpressHub,
          onCancel: canCancel ? _cancelOrder : null,
          isCancelling: _cancelling,
        );
      case ExpressOrderStatus.awaitingPayment:
        return _PayAgentView(
          order: order,
          onMarkPaid: _openMarkPaidSheet,
          onCancel: canCancel ? _cancelOrder : null,
          isCancelling: _cancelling,
        );
      case ExpressOrderStatus.paidByUser:
        return _VerifyingView(
          order: order,
          onLeave: _goToExpressHub,
          onOpenDispute: canDispute ? _openDisputeSheet : null,
          openingDispute: _openingDispute,
        );
      case ExpressOrderStatus.disputed:
        return _DisputedView(order: order, onLeave: _goToExpressHub);
      case ExpressOrderStatus.completed:
        return _SuccessView(
          order: order,
          onDone: () => Navigator.of(context).maybePop(),
        );
      case ExpressOrderStatus.expired:
      case ExpressOrderStatus.cancelled:
        return _TerminalView(order: order);
      case ExpressOrderStatus.unknown:
        return _VerifyingView(order: order, onLeave: _goToExpressHub);
    }
  }

  void _goToExpressHub() {
    context.go('/express-p2p');
  }

  Future<void> _openMarkPaidSheet() async {
    final order = _order;
    if (order == null) return;

    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MarkPaidSheet(orderId: order.id, ref: ref),
    );

    if (submitted == true && mounted) {
      // Refresh immediately so we transition to "verifying" without waiting.
      _fetch();
    }
  }

  Future<void> _cancelOrder() async {
    final order = _order;
    if (order == null || _cancelling) return;
    final confirmed = await _confirmCancel(order);
    if (confirmed != true || !mounted) return;
    setState(() => _cancelling = true);
    try {
      final updated = await ref
          .read(expressOrderRepositoryProvider)
          .cancelOrder(order.id);
      if (!mounted) return;
      setState(() {
        _order = updated;
        _cancelling = false;
      });
      _toast('Order cancelled.');
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _cancelling = false);
      await _handleOrderActionError(e);
    } catch (e) {
      if (!mounted) return;
      setState(() => _cancelling = false);
      _toast(ErrorHelper.getErrorMessage(e));
    }
  }

  Future<void> _openDisputeSheet() async {
    final order = _order;
    if (order == null || _openingDispute) return;
    final draft = await showModalBottomSheet<_DisputeDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _DisputeSheet(),
    );
    if (draft == null || draft.message.trim().isEmpty) return;
    setState(() => _openingDispute = true);
    try {
      final uploads = draft.images
          .where((f) => f.bytes != null)
          .map(
            (f) => ExpressProofUpload(
              contentType: _mimeFor(f.extension),
              bytes: f.bytes!,
            ),
          )
          .toList(growable: false);
      final imageUrls = uploads.isEmpty
          ? const <String>[]
          : await ref
                .read(expressOrderRepositoryProvider)
                .uploadProofs(uploads);

      final updated = await ref
          .read(expressOrderRepositoryProvider)
          .openDispute(
            orderId: order.id,
            message: draft.message,
            imageUrls: imageUrls.take(5).toList(growable: false),
          );
      if (!mounted) return;
      setState(() {
        _order = updated;
        _openingDispute = false;
      });
      _toast('Dispute opened. Under admin review.');
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _openingDispute = false);
      await _handleOrderActionError(e);
    } catch (e) {
      if (!mounted) return;
      setState(() => _openingDispute = false);
      _toast(ErrorHelper.getErrorMessage(e));
    }
  }

  String _mimeFor(String? ext) {
    switch ((ext ?? '').toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  Future<void> _handleOrderActionError(ApiError e) async {
    switch (e.statusCode) {
      case 403:
        _toast('You are not allowed to perform this action.');
        break;
      case 404:
        _toast('Order no longer exists.');
        break;
      case 409:
        _toast('Order updated by another action. Refreshing...');
        await _fetch(initial: true);
        break;
      case 400:
      default:
        _toast(e.message);
        break;
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: OpeiBrand.ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  Future<bool?> _confirmCancel(ExpressOrder order) {
    final paidRisk = order.status == ExpressOrderStatus.awaitingPayment;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OpeiBrand.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
        ),
        title: const Text(
          'Cancel this order?',
          style: TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: OpeiBrand.ink,
          ),
        ),
        content: Text(
          paidRisk
              ? 'If you already sent money to the agent and cancel now, that payment may be lost and cannot be recovered in-app. Cancel only if you have NOT paid yet.'
              : 'This will cancel the order and stop the current express deposit flow.',
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
            child: const Text(
              'Keep order',
              style: TextStyle(
                fontFamily: kPrimaryFontFamily,
                color: OpeiBrand.inkSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: OpeiBrand.danger,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Yes, cancel',
              style: TextStyle(
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
}

// ── Finding agent ─────────────────────────────────────────────────────────────

class _FindingAgentView extends StatelessWidget {
  final ExpressOrder order;
  final Duration remaining;
  final VoidCallback onLeave;
  final VoidCallback? onCancel;
  final bool isCancelling;

  const _FindingAgentView({
    required this.order,
    required this.remaining,
    required this.onLeave,
    this.onCancel,
    this.isCancelling = false,
  });

  String _formatRemaining(Duration d) {
    if (d <= Duration.zero) return 'Expiring…';
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) return 'Expires in ${h}h ${m}m';
    if (m > 0) return 'Expires in ${m}m ${s}s';
    return 'Expires in ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;
    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: OpeiBrand.primaryTint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pending_actions_rounded,
                    size: 32,
                    color: OpeiBrand.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Order placed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: OpeiBrand.ink,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "We're looking for an agent for you now. Once matched, you'll be notified and can continue payment.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 13.5,
                  color: OpeiBrand.inkSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  _formatRemaining(remaining),
                  style: const TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: OpeiBrand.inkTertiary,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _OrderSummaryCard(order: order),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottomPad),
          child: Column(
            children: [
              if (onCancel != null) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: isCancelling ? null : onCancel,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: OpeiBrand.danger),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          OpeiBrand.radiusCard,
                        ),
                      ),
                    ),
                    child: isCancelling
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: OpeiBrand.danger,
                            ),
                          )
                        : const Text(
                            'Cancel order',
                            style: TextStyle(
                              fontFamily: kPrimaryFontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: OpeiBrand.danger,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: onLeave,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: OpeiBrand.hairlineStrong),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
                    ),
                  ),
                  child: const Text(
                    'View my orders',
                    style: TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: OpeiBrand.ink,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Pay agent ─────────────────────────────────────────────────────────────────

class _PayAgentView extends StatelessWidget {
  final ExpressOrder order;
  final VoidCallback onMarkPaid;
  final VoidCallback? onCancel;
  final bool isCancelling;

  const _PayAgentView({
    required this.order,
    required this.onMarkPaid,
    this.onCancel,
    this.isCancelling = false,
  });

  @override
  Widget build(BuildContext context) {
    final agent = order.agentPaymentMethod;
    final detailAgentPhone = _detailAgentPhone(order);
    final showAgentNumber = _shouldShowAgentContact(order, detailAgentPhone);
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;

    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: OpeiBrand.primaryTint,
                  borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
                  border: Border.all(color: OpeiBrand.primaryTintStrong),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pay your agent',
                      style: TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: OpeiBrand.ink,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Send exactly ${expressFiat(order.fiatAmountCents, order.quoteCurrency)} to the account below, then upload your proof.',
                      style: const TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 13,
                        color: OpeiBrand.inkSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (agent != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: OpeiBrand.surface,
                    borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
                    border: Border.all(color: OpeiBrand.hairline),
                  ),
                  child: Column(
                    children: [
                      _CopyRow(
                        label: AppLocalizations.of(context)!.amountLabel,
                        value: expressFiat(
                          order.fiatAmountCents,
                          order.quoteCurrency,
                        ),
                      ),
                      const _RowDivider(),
                      _CopyRow(
                        label: AppLocalizations.of(context)!.providerLabel,
                        value: agent.providerName,
                      ),
                      const _RowDivider(),
                      _CopyRow(
                        label: AppLocalizations.of(context)!.accountNameLabel,
                        value: agent.accountName,
                      ),
                      const _RowDivider(),
                      _CopyRow(
                        label: AppLocalizations.of(context)!.accountNumberLabel,
                        value: agent.accountNumber,
                        copyable: true,
                      ),
                      if (agent.extraDetails != null) ...[
                        const _RowDivider(),
                        _CopyRow(
                          label: AppLocalizations.of(context)!.detailsLabel,
                          value: agent.extraDetails!,
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: OpeiBrand.inkTertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pay outside the app, then upload a screenshot or receipt as proof of payment.',
                      style: TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 12.5,
                        color: OpeiBrand.inkTertiary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              if (showAgentNumber) ...[
                const SizedBox(height: 12),
                _ContactCard(
                  title: AppLocalizations.of(context)!.agentContactTitle,
                  number: detailAgentPhone,
                ),
              ],
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottomPad),
          decoration: const BoxDecoration(
            color: OpeiBrand.surface,
            border: Border(
              top: BorderSide(color: OpeiBrand.hairline, width: 0.8),
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onMarkPaid,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OpeiBrand.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
                    ),
                  ),
                  child: const Text(
                    "I've paid — upload proof",
                    style: TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
              if (onCancel != null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton(
                    onPressed: isCancelling ? null : onCancel,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: OpeiBrand.danger),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          OpeiBrand.radiusCard,
                        ),
                      ),
                    ),
                    child: isCancelling
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: OpeiBrand.danger,
                            ),
                          )
                        : const Text(
                            'Cancel order',
                            style: TextStyle(
                              fontFamily: kPrimaryFontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: OpeiBrand.danger,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Verifying ─────────────────────────────────────────────────────────────────

class _VerifyingView extends StatelessWidget {
  final ExpressOrder order;
  final VoidCallback onLeave;
  final VoidCallback? onOpenDispute;
  final bool openingDispute;
  const _VerifyingView({
    required this.order,
    required this.onLeave,
    this.onOpenDispute,
    this.openingDispute = false,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;
    final detailAgentPhone = _detailAgentPhone(order);
    final showAgentNumber = _shouldShowAgentContact(order, detailAgentPhone);
    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            children: [
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF7E8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    size: 36,
                    color: OpeiBrand.warning,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Payment submitted',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: OpeiBrand.ink,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your proof has been sent. Please wait while the agent confirms payment. Once approved, USD will be added to your wallet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 13.5,
                  color: OpeiBrand.inkSecondary,
                  height: 1.45,
                ),
              ),
              if (showAgentNumber) ...[
                const SizedBox(height: 20),
                _ContactCard(
                  title: AppLocalizations.of(context)!.needToFollowUpTitle,
                  number: detailAgentPhone,
                ),
              ],
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottomPad),
          child: Column(
            children: [
              if (onOpenDispute != null) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: openingDispute ? null : onOpenDispute,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OpeiBrand.danger,
                      disabledBackgroundColor: OpeiBrand.hairlineStrong,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          OpeiBrand.radiusCard,
                        ),
                      ),
                    ),
                    child: openingDispute
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Open dispute',
                            style: TextStyle(
                              fontFamily: kPrimaryFontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: onLeave,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: OpeiBrand.hairlineStrong),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
                    ),
                  ),
                  child: const Text(
                    'View my orders',
                    style: TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: OpeiBrand.ink,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DisputedView extends StatelessWidget {
  final ExpressOrder order;
  final VoidCallback onLeave;

  const _DisputedView({required this.order, required this.onLeave});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;
    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            children: [
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFCE8EA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.report_problem_outlined,
                    size: 36,
                    color: OpeiBrand.danger,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Dispute opened',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: OpeiBrand.ink,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Under review by admin. We will notify you when this is resolved.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 13.5,
                  color: OpeiBrand.inkSecondary,
                  height: 1.45,
                ),
              ),
              if ((order.dispute?.message ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: OpeiBrand.surface,
                    borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
                    border: Border.all(color: OpeiBrand.hairline),
                  ),
                  child: Text(
                    order.dispute!.message!,
                    style: const TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 13.5,
                      color: OpeiBrand.inkSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottomPad),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: onLeave,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: OpeiBrand.hairlineStrong),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
                ),
              ),
              child: const Text(
                'View my orders',
                style: TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: OpeiBrand.ink,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Success ───────────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  final ExpressOrder order;
  final VoidCallback onDone;

  const _SuccessView({required this.order, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;
    final detailAgentPhone = _detailAgentPhone(order);
    final showAgentNumber = _shouldShowAgentContact(order, detailAgentPhone);
    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            children: [
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE7F6EC),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 38,
                    color: OpeiBrand.success,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                '${expressUsd(order.amountUsdCents)} added',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: OpeiBrand.ink,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your deposit is complete and the funds are now in your Opei wallet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 13.5,
                  color: OpeiBrand.inkSecondary,
                  height: 1.45,
                ),
              ),
              if (showAgentNumber) ...[
                const SizedBox(height: 20),
                _ContactCard(
                  title: AppLocalizations.of(context)!.agentContactTitle,
                  number: detailAgentPhone,
                ),
              ],
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottomPad),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: OpeiBrand.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Terminal (expired / cancelled) ───────────────────────────────────────────

class _TerminalView extends StatelessWidget {
  final ExpressOrder order;
  const _TerminalView({required this.order});

  @override
  Widget build(BuildContext context) {
    final view = expressCustomerStatusView(
      order.status,
      AppLocalizations.of(context)!,
    );
    final detailAgentPhone = _detailAgentPhone(order);
    final showAgentNumber = _shouldShowAgentContact(order, detailAgentPhone);
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: view.background,
              shape: BoxShape.circle,
            ),
            child: Icon(view.icon, size: 34, color: view.color),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          order.status == ExpressOrderStatus.expired
              ? 'Order expired'
              : 'Order cancelled',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: OpeiBrand.ink,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          order.status == ExpressOrderStatus.expired
              ? (order.agent == null
                    ? 'No agent accepted this order in time. You can start a new deposit.'
                    : 'This order expired before completion. You can start a new deposit.')
              : 'This order was cancelled. You can start a new deposit.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: 13.5,
            color: OpeiBrand.inkSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 28),
        if (showAgentNumber) ...[
          _ContactCard(
            title: AppLocalizations.of(context)!.agentContactTitle,
            number: detailAgentPhone,
          ),
          const SizedBox(height: 16),
        ],
        _OrderSummaryCard(order: order),
      ],
    );
  }
}

// ── Shared bits ───────────────────────────────────────────────────────────────

class _OrderSummaryCard extends StatelessWidget {
  final ExpressOrder order;
  const _OrderSummaryCard({required this.order});

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
        children: [
          _CopyRow(
            label: AppLocalizations.of(context)!.expressYouReceiveRow,
            value: expressUsd(order.amountUsdCents),
          ),
          const _RowDivider(),
          _CopyRow(
            label: AppLocalizations.of(context)!.expressYouPayRow,
            value: expressFiat(order.fiatAmountCents, order.quoteCurrency),
          ),
          if (provider.isNotEmpty) ...[
            const _RowDivider(),
            _CopyRow(
              label: AppLocalizations.of(context)!.providerLabel,
              value: provider,
            ),
          ],
        ],
      ),
    );
  }
}

class _CopyRow extends StatelessWidget {
  final String label;
  final String value;
  final bool copyable;

  const _CopyRow({
    required this.label,
    required this.value,
    this.copyable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: OpeiBrand.inkSecondary,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: OpeiBrand.ink,
                letterSpacing: -0.2,
              ),
            ),
          ),
          if (copyable) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: value));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.copiedLabel),
                      backgroundColor: OpeiBrand.ink,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          OpeiBrand.radiusCard,
                        ),
                      ),
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    ),
                  );
                }
              },
              child: const Icon(
                Icons.copy_rounded,
                size: 15,
                color: OpeiBrand.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final String title;
  final String number;

  const _ContactCard({required this.title, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OpeiBrand.surface,
        borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
        border: Border.all(color: OpeiBrand.hairline),
      ),
      child: Row(
        children: [
          const Icon(Icons.phone_outlined, size: 18, color: OpeiBrand.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: OpeiBrand.inkTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  number,
                  style: const TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: OpeiBrand.ink,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _openDialer(context, number),
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 34),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Call',
              style: TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: OpeiBrand.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _detailAgentPhone(ExpressOrder order) =>
    (order.agent?.phoneNumber ?? '').trim();

bool _shouldShowAgentContact(ExpressOrder order, String number) {
  if (number.isEmpty || order.agent == null) return false;
  return order.status == ExpressOrderStatus.awaitingPayment ||
      order.status == ExpressOrderStatus.paidByUser ||
      order.status == ExpressOrderStatus.completed ||
      order.status == ExpressOrderStatus.expired;
}

Future<void> _openDialer(BuildContext context, String phoneNumber) async {
  final uri = Uri(scheme: 'tel', path: phoneNumber);
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.couldNotOpenDialer),
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

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 0.5, color: OpeiBrand.hairline);
  }
}

class _DisputeDraft {
  final String message;
  final List<PlatformFile> images;

  const _DisputeDraft({required this.message, required this.images});
}

class _DisputeSheet extends StatefulWidget {
  const _DisputeSheet();

  @override
  State<_DisputeSheet> createState() => _DisputeSheetState();
}

class _DisputeSheetState extends State<_DisputeSheet> {
  static const int _maxImages = 5;
  final TextEditingController _messageController = TextEditingController();
  final List<PlatformFile> _images = <PlatformFile>[];
  String? _error;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );
      if (result == null) return;
      final files = result.files.where((f) => f.bytes != null).toList();
      setState(() {
        for (final file in files) {
          if (_images.length >= _maxImages) break;
          _images.add(file);
        }
        _error = _images.length > _maxImages
            ? 'You can attach up to $_maxImages images.'
            : null;
      });
    } catch (_) {
      setState(() => _error = 'Could not pick images.');
    }
  }

  void _submit() {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      setState(() => _error = 'Dispute message is required.');
      return;
    }
    Navigator.of(context).pop(
      _DisputeDraft(message: message, images: List<PlatformFile>.from(_images)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: OpeiBrand.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 14, 20, 16 + bottomPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: OpeiBrand.hairlineStrong,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Open dispute',
              style: TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: OpeiBrand.ink,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tell us what happened. You can add proof screenshots (optional).',
              style: TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 13,
                color: OpeiBrand.inkSecondary,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _messageController,
              maxLength: 500,
              minLines: 3,
              maxLines: 5,
              style: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 14,
                color: OpeiBrand.ink,
              ),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.disputeExplainIssueHint,
                filled: true,
                fillColor: OpeiBrand.surfaceMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _ImagePickerRow(
              images: _images,
              maxImages: _maxImages,
              onAdd: _pickImages,
              onRemove: (i) => setState(() => _images.removeAt(i)),
              disabled: false,
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 12.5,
                  color: OpeiBrand.danger,
                ),
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: OpeiBrand.danger,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
                  ),
                ),
                child: const Text(
                  'Submit dispute',
                  style: TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenteredError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CenteredError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: OpeiBrand.inkSecondary,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 14,
                color: OpeiBrand.inkSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
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
        ),
      ),
    );
  }
}

// ── Mark-paid sheet (pick proof + submit) ────────────────────────────────────

class _MarkPaidSheet extends StatefulWidget {
  final String orderId;
  final WidgetRef ref;

  const _MarkPaidSheet({required this.orderId, required this.ref});

  @override
  State<_MarkPaidSheet> createState() => _MarkPaidSheetState();
}

class _MarkPaidSheetState extends State<_MarkPaidSheet> {
  static const int _maxImages = 3;

  final TextEditingController _noteController = TextEditingController();
  final List<PlatformFile> _images = [];
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    if (_submitting) return;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );
      if (result == null) return;
      final picked = result.files.where((f) => f.bytes != null).toList();
      setState(() {
        for (final f in picked) {
          if (_images.length >= _maxImages) break;
          _images.add(f);
        }
        if (picked.length + _images.length > _maxImages) {
          _error = 'You can upload up to $_maxImages images.';
        } else {
          _error = null;
        }
      });
    } catch (_) {
      setState(() => _error = 'Could not pick images. Please try again.');
    }
  }

  String _mimeFor(PlatformFile file) {
    final ext = (file.extension ?? '').toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  Future<void> _submit() async {
    if (_submitting || _images.isEmpty) return;
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final repo = widget.ref.read(expressOrderRepositoryProvider);
      final uploads = _images
          .where((f) => f.bytes != null)
          .map(
            (f) =>
                ExpressProofUpload(contentType: _mimeFor(f), bytes: f.bytes!),
          )
          .toList();

      final urls = await repo.uploadProofs(uploads);
      await repo.markPaid(
        orderId: widget.orderId,
        proofUrls: urls,
        message: _noteController.text,
      );

      if (mounted) Navigator.of(context).pop(true);
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = ErrorHelper.getErrorMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: OpeiBrand.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 14, 20, 16 + bottomPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: OpeiBrand.hairlineStrong,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Upload payment proof',
              style: TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: OpeiBrand.ink,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Add a screenshot or receipt of your payment (up to 3 images).',
              style: TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 13,
                color: OpeiBrand.inkSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            _ImagePickerRow(
              images: _images,
              maxImages: _maxImages,
              onAdd: _pick,
              onRemove: (i) => setState(() => _images.removeAt(i)),
              disabled: _submitting,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _noteController,
              enabled: !_submitting,
              maxLines: 2,
              maxLength: 200,
              style: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 14,
                color: OpeiBrand.ink,
              ),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.addNoteOptionalHint,
                counterText: '',
                filled: true,
                fillColor: OpeiBrand.surfaceMuted,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 12.5,
                  color: OpeiBrand.danger,
                  height: 1.3,
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (_images.isEmpty || _submitting) ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: OpeiBrand.primary,
                  disabledBackgroundColor: OpeiBrand.primaryTintStrong,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit payment',
                        style: TextStyle(
                          fontFamily: kPrimaryFontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePickerRow extends StatelessWidget {
  final List<PlatformFile> images;
  final int maxImages;
  final VoidCallback onAdd;
  final void Function(int) onRemove;
  final bool disabled;

  const _ImagePickerRow({
    required this.images,
    required this.maxImages,
    required this.onAdd,
    required this.onRemove,
    required this.disabled,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ...images.asMap().entries.map((entry) {
          final i = entry.key;
          final file = entry.value;
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: file.bytes != null
                    ? Image.memory(
                        file.bytes!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 72,
                        height: 72,
                        color: OpeiBrand.surfaceMuted,
                      ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: GestureDetector(
                  onTap: disabled ? null : () => onRemove(i),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
        if (images.length < maxImages)
          GestureDetector(
            onTap: disabled ? null : onAdd,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: OpeiBrand.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: OpeiBrand.hairlineStrong),
              ),
              child: const Icon(
                Icons.add_a_photo_outlined,
                size: 22,
                color: OpeiBrand.inkSecondary,
              ),
            ),
          ),
      ],
    );
  }
}
