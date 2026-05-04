import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:opei/core/navigation/opei_page_transitions.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/models/beneficiary.dart';
import 'package:opei/data/models/payout_review.dart';
import 'package:opei/features/beneficiaries/send/send_mobile_money_controller.dart';
import 'package:opei/features/beneficiaries/send/send_result_screen.dart';
import 'package:opei/theme.dart';
import 'package:opei/widgets/opei_premium/opei_app_bar.dart';
import 'package:opei/widgets/opei_premium/opei_primary_button.dart';

/// Step 2 — review & confirm. Compact, structured banking layout.
class SendPreviewScreen extends ConsumerWidget {
  final Beneficiary beneficiary;
  final String countryName;
  final String flag;

  const SendPreviewScreen({
    super.key,
    required this.beneficiary,
    required this.countryName,
    required this.flag,
  });

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final ok = await ref
        .read(sendMobileMoneyControllerProvider(beneficiary).notifier)
        .confirmAndSend();
    if (!context.mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacement(OpeiPageRoute(
        builder: (_) => SendResultScreen(
          beneficiary: beneficiary,
          countryName: countryName,
          flag: flag,
        ),
      ));
    } else {
      final s = ref.read(sendMobileMoneyControllerProvider(beneficiary));
      final err = s.initiateError ?? s.finalizeError;
      if (err != null) showError(context, err);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sendMobileMoneyControllerProvider(beneficiary));
    final review = state.review;
    final name = beneficiary.accountName ?? 'Receiver';
    final masked = beneficiary.accountNumberMasked ?? '';

    if (review == null) {
      return Scaffold(
        backgroundColor: OpeiBrand.surface,
        appBar: const OpeiAppBar(),
        body: const Center(
          child: Text(
            'Quote unavailable. Please go back and try again.',
            style: TextStyle(fontSize: 13.5, color: OpeiBrand.inkSecondary),
          ),
        ),
      );
    }

    final canProceed = review.walletCheck?.canProceed ?? true;
    final shortfall = review.walletCheck?.shortfallCents ?? 0;
    final isBusy = state.isInitiating || state.isFinalizing;

    return Scaffold(
      backgroundColor: OpeiBrand.surface,
      appBar: const OpeiAppBar(),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Review',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: OpeiBrand.ink,
                        letterSpacing: -0.4,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Check the details before confirming.',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: OpeiBrand.inkSecondary,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ── Hero amount card ─────────────────────────────
                    _AmountHero(review: review),
                    const SizedBox(height: 14),

                    // ── Section: Receiver ────────────────────────────
                    const _SectionLabel('RECEIVER'),
                    const SizedBox(height: 6),
                    _ReceiverCard(
                      name: name,
                      masked: masked,
                      flag: flag,
                      countryName: countryName,
                    ),
                    const SizedBox(height: 16),

                    // ── Section: Breakdown ───────────────────────────
                    const _SectionLabel('PAYMENT BREAKDOWN'),
                    const SizedBox(height: 6),
                    _BreakdownCard(review: review),

                    if (review.expiresAt != null) ...[
                      const SizedBox(height: 12),
                      _ExpiryHint(expiresAt: review.expiresAt!),
                    ],

                    if (!canProceed) ...[
                      const SizedBox(height: 12),
                      _BalanceWarning(shortfallCents: shortfall),
                    ],

                    if (state.initiateError != null ||
                        state.finalizeError != null) ...[
                      const SizedBox(height: 12),
                      _InlineError(
                        message:
                            (state.initiateError ?? state.finalizeError)!,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── CTA bar ────────────────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).viewPadding.bottom + 14,
              ),
              decoration: const BoxDecoration(
                color: OpeiBrand.surface,
                border: Border(
                  top: BorderSide(color: OpeiBrand.hairline, width: 0.5),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isBusy) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.6,
                            color: OpeiBrand.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          state.isInitiating
                              ? 'Reserving funds…'
                              : 'Sending payment…',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: OpeiBrand.inkSecondary,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                  OpeiPrimaryButton(
                    label: 'Confirm & send',
                    onPressed: (state.isBusy || !canProceed)
                        ? null
                        : () => _confirm(context, ref),
                    loading: isBusy,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: OpeiBrand.inkTertiary,
          letterSpacing: 0.9,
        ),
      ),
    );
  }
}

class _AmountHero extends StatelessWidget {
  final PayoutReview review;
  const _AmountHero({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            OpeiBrand.primaryGradientStart,
            OpeiBrand.primaryGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: OpeiBrand.primary.withValues(alpha: 0.16),
            offset: const Offset(0, 6),
            blurRadius: 18,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'THEY RECEIVE',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _fmtMinor(
                        review.payoutAmountMinor, review.payoutCurrency),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.6,
                      height: 1.05,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withValues(alpha: 0.25),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'YOU PAY',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white70,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${review.totalDebitAmountUsd}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.4,
                  height: 1.05,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _fmtMinor(int minor, String currency) =>
      '${NumberFormat('#,##0.00').format(minor / 100)} $currency';
}

class _ReceiverCard extends StatelessWidget {
  final String name;
  final String masked;
  final String flag;
  final String countryName;

  const _ReceiverCard({
    required this.name,
    required this.masked,
    required this.flag,
    required this.countryName,
  });

  String _initials(String n) {
    if (n.trim().isEmpty) return '?';
    final parts = n.trim().split(RegExp(r'\s+'));
    final first = parts.first.characters.first;
    final last = parts.length > 1 ? parts.last.characters.first : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: BoxDecoration(
        color: OpeiBrand.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: OpeiBrand.hairline, width: 1),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: OpeiBrand.primaryTint,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Center(
                  child: Text(
                    _initials(name),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: OpeiBrand.primary,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: OpeiBrand.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: OpeiBrand.surfaceMuted, width: 1.5),
                  ),
                  child: Text(flag,
                      style: const TextStyle(fontSize: 10)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: OpeiBrand.ink,
                    letterSpacing: -0.2,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  masked.isNotEmpty
                      ? '$masked · $countryName'
                      : countryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: OpeiBrand.inkSecondary,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final PayoutReview review;
  const _BreakdownCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: OpeiBrand.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: OpeiBrand.hairline, width: 1),
      ),
      child: Column(
        children: [
          _Row(label: 'Send amount', value: '\$${review.requiredAmountUsd}'),
          const _Sep(),
          _Row(label: 'Transfer fee', value: '\$${review.feeAmountUsd}'),
          const _Sep(),
          _Row(
            label: 'Total to pay',
            value: '\$${review.totalDebitAmountUsd}',
            emphasized: true,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;
  const _Row({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
              color: emphasized ? OpeiBrand.ink : OpeiBrand.inkSecondary,
              letterSpacing: -0.1,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: emphasized ? 14.5 : 13,
              fontWeight: emphasized ? FontWeight.w800 : FontWeight.w700,
              color: OpeiBrand.ink,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _Sep extends StatelessWidget {
  const _Sep();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 0.5, color: OpeiBrand.hairline);
}

class _ExpiryHint extends StatelessWidget {
  final DateTime expiresAt;
  const _ExpiryHint({required this.expiresAt});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          const Icon(Icons.schedule_outlined,
              size: 12, color: OpeiBrand.inkTertiary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Quote expires at ${DateFormat.Hm().format(expiresAt.toLocal())}.',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: OpeiBrand.inkTertiary,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceWarning extends StatelessWidget {
  final int shortfallCents;
  const _BalanceWarning({required this.shortfallCents});

  @override
  Widget build(BuildContext context) {
    final usd = (shortfallCents / 100).toStringAsFixed(2);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: OpeiBrand.warning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: OpeiBrand.warning.withValues(alpha: 0.30),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 15, color: OpeiBrand.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your balance is \$$usd short. Top up to continue.',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: OpeiBrand.ink,
                letterSpacing: -0.1,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: OpeiBrand.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: OpeiBrand.danger.withValues(alpha: 0.20),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 15, color: OpeiBrand.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: OpeiBrand.danger,
                letterSpacing: -0.1,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
