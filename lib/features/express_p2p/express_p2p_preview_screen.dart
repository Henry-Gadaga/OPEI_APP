import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/models/express_order_preview.dart';
import 'package:opei/features/express_p2p/express_ui.dart';
import 'package:opei/theme.dart';

/// Arguments carried from the setup screen into the preview screen.
class ExpressPreviewArgs {
  final String paymentMethodTypeId;
  final String providerName;
  final String methodType;
  final String quoteCurrency;
  final int amountUsdCents;

  const ExpressPreviewArgs({
    required this.paymentMethodTypeId,
    required this.providerName,
    required this.methodType,
    required this.quoteCurrency,
    required this.amountUsdCents,
  });
}

/// Step 2: shows a non-binding quote, then creates the order on confirm.
class ExpressP2PPreviewScreen extends ConsumerStatefulWidget {
  final ExpressPreviewArgs args;
  const ExpressP2PPreviewScreen({super.key, required this.args});

  @override
  ConsumerState<ExpressP2PPreviewScreen> createState() =>
      _ExpressP2PPreviewScreenState();
}

class _ExpressP2PPreviewScreenState
    extends ConsumerState<ExpressP2PPreviewScreen> {
  ExpressOrderPreview? _preview;
  bool _loading = true;
  String? _error;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final preview = await ref.read(expressOrderRepositoryProvider).previewOrder(
            paymentMethodTypeId: widget.args.paymentMethodTypeId,
            quoteCurrency: widget.args.quoteCurrency,
            amountUsdCents: widget.args.amountUsdCents,
          );
      if (!mounted) return;
      setState(() {
        _preview = preview;
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
    }
  }

  Future<void> _confirm() async {
    if (_creating) return;
    setState(() => _creating = true);
    try {
      final order = await ref.read(expressOrderRepositoryProvider).createOrder(
            paymentMethodTypeId: widget.args.paymentMethodTypeId,
            quoteCurrency: widget.args.quoteCurrency,
            amountUsdCents: widget.args.amountUsdCents,
          );
      if (!mounted) return;
      // Replace setup+preview with the live order so back returns to the hub.
      context.pushReplacement('/express-p2p/order/${order.id}');
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _creating = false);
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _creating = false);
      _showError(ErrorHelper.getErrorMessage(e));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: OpeiBrand.danger,
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
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Review',
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

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 40, color: OpeiBrand.inkSecondary),
              const SizedBox(height: 14),
              const Text(
                "Couldn't get a quote",
                style: TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: OpeiBrand.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _error!,
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
                onTap: _loadPreview,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

    final preview = _preview!;
    final provider = preview.paymentMethodType.providerName.isEmpty
        ? widget.args.providerName
        : preview.paymentMethodType.providerName;
    final methodLabel = provider.isEmpty
        ? expressMethodTypeLabel(preview.paymentMethodType.methodType)
        : provider;

    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              _AmountCard(
                receiveUsdCents: preview.amountUsdCents,
                payFiatCents: preview.fiatAmountCents,
                quoteCurrency: preview.quoteCurrency,
              ),
              const SizedBox(height: 24),
              _DetailRow(label: 'You receive', value: expressUsd(preview.amountUsdCents), highlight: true),
              _DetailRow(label: 'You pay', value: expressFiat(preview.fiatAmountCents, preview.quoteCurrency)),
              _DetailRow(label: 'Payment method', value: methodLabel),
              _DetailRow(label: 'Exchange rate', value: '1 USD = ${expressFiat(preview.lockedRateCents, preview.quoteCurrency)}'),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: OpeiBrand.primaryTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lock_rounded, size: 14, color: OpeiBrand.primary),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Rate locks on confirm. An agent will be matched to collect your local payment.',
                        style: TextStyle(
                          fontFamily: kPrimaryFontFamily,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: OpeiBrand.primary,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _ConfirmBar(busy: _creating, onTap: _confirm),
      ],
    );
  }
}

class _AmountCard extends StatelessWidget {
  final int receiveUsdCents;
  final int payFiatCents;
  final String quoteCurrency;

  const _AmountCard({
    required this.receiveUsdCents,
    required this.payFiatCents,
    required this.quoteCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E55D8), Color(0xFF3D7BFF)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'YOU RECEIVE',
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.70),
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            expressUsd(receiveUsdCents),
            style: const TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1.5,
              height: 1,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 0.6,
            color: Colors.white.withValues(alpha: 0.20),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'You pay  ',
                style: TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
              Text(
                expressFiat(payFiatCents, quoteCurrency),
                style: const TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _DetailRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
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
          Text(
            value,
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: highlight ? OpeiBrand.primary : OpeiBrand.ink,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmBar extends StatelessWidget {
  final bool busy;
  final VoidCallback onTap;

  const _ConfirmBar({required this.busy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 12 + bottomPad),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: busy ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: OpeiBrand.primary,
            disabledBackgroundColor: OpeiBrand.primary.withValues(alpha: 0.5),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Confirm order',
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
    );
  }
}
