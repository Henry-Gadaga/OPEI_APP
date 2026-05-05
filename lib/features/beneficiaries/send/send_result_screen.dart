import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:opei/data/models/beneficiary.dart';
import 'package:opei/data/models/payout_result.dart';
import 'package:opei/features/beneficiaries/send/send_mobile_money_controller.dart';
import 'package:opei/theme.dart';
import 'package:opei/widgets/opei_premium/opei_primary_button.dart';

/// Step 3 — terminal result screen. Compact, bank-confirmation style.
class SendResultScreen extends ConsumerWidget {
  final Beneficiary beneficiary;
  final String countryName;
  final String flag;

  const SendResultScreen({
    super.key,
    required this.beneficiary,
    required this.countryName,
    required this.flag,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sendMobileMoneyControllerProvider(beneficiary));
    final finalization = state.finalization;
    final initiation = state.initiation;
    final review = state.review;
    final receiverName = beneficiary.accountName ?? 'Receiver';

    final stage = finalization?.stage ??
        initiation?.stage ??
        PayoutStage.unknown;

    final isSuccess = stage == PayoutStage.success;
    final isPending = stage == PayoutStage.pendingWebhook ||
        stage == PayoutStage.initiated;
    final isFailed = stage == PayoutStage.failed;

    late final Color iconBg;
    late final Color iconFg;
    late final IconData icon;
    late final String title;
    late final String subtitle;
    late final String statusLabel;

    if (isSuccess) {
      iconBg = const Color(0xFFE8F9EE);
      iconFg = OpeiBrand.success;
      icon = Icons.check_rounded;
      title = 'Money sent';
      subtitle = 'Your payment to $receiverName has been delivered.';
      statusLabel = 'COMPLETED';
    } else if (isFailed) {
      iconBg = OpeiBrand.danger.withValues(alpha: 0.10);
      iconFg = OpeiBrand.danger;
      icon = Icons.close_rounded;
      title = 'Payment failed';
      subtitle =
          'The provider couldn\'t process this payment. No funds were taken.';
      statusLabel = 'FAILED';
    } else if (isPending) {
      iconBg = OpeiBrand.primaryTint;
      iconFg = OpeiBrand.primary;
      icon = Icons.schedule_rounded;
      title = 'Sending in progress';
      subtitle =
          'Your payment is on its way to $receiverName. We\'ll notify you once it\'s confirmed.';
      statusLabel = 'PROCESSING';
    } else {
      iconBg = OpeiBrand.surfaceMuted;
      iconFg = OpeiBrand.inkTertiary;
      icon = Icons.help_outline_rounded;
      title = 'Status unknown';
      subtitle = 'Check Activity in a few moments to see the outcome.';
      statusLabel = 'UNKNOWN';
    }

    final reference =
        finalization?.reference ?? initiation?.reference ?? '';
    final dateText = DateFormat.yMMMd().add_jm().format(DateTime.now());

    return Scaffold(
      backgroundColor: OpeiBrand.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with close
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => _exit(context),
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 22,
                    color: OpeiBrand.inkSecondary,
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // ── Status icon ─────────────────────────────────────
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(icon, color: iconFg, size: 34),
                    ),
                    const SizedBox(height: 14),

                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: OpeiBrand.ink,
                        letterSpacing: -0.4,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: OpeiBrand.inkSecondary,
                          letterSpacing: -0.1,
                          height: 1.45,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Status pill ──────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: iconFg,
                          letterSpacing: 1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ── Receipt card ─────────────────────────────────────
                    if (review != null)
                      _ReceiptCard(
                        flag: flag,
                        countryName: countryName,
                        receiverName: receiverName,
                        amountUsd: review.requiredAmountUsd,
                        feeUsd: review.feeAmountUsd,
                        totalUsd: review.totalDebitAmountUsd,
                        payoutCurrency: review.payoutCurrency,
                        payoutMinor: review.payoutAmountMinor,
                        reference: reference,
                        dateText: dateText,
                      ),
                  ],
                ),
              ),
            ),

            // Done button
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                MediaQuery.of(context).viewPadding.bottom + 14,
              ),
              child: OpeiPrimaryButton(
                label: 'Done',
                onPressed: () => _exit(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exit(BuildContext context) =>
      Navigator.of(context).popUntil((r) => r.isFirst);
}

// ─────────────────────────────────────────────────────────────────────────────

class _ReceiptCard extends StatelessWidget {
  final String flag;
  final String countryName;
  final String receiverName;
  final String amountUsd;
  final String feeUsd;
  final String totalUsd;
  final String payoutCurrency;
  final int payoutMinor;
  final String reference;
  final String dateText;

  const _ReceiptCard({
    required this.flag,
    required this.countryName,
    required this.receiverName,
    required this.amountUsd,
    required this.feeUsd,
    required this.totalUsd,
    required this.payoutCurrency,
    required this.payoutMinor,
    required this.reference,
    required this.dateText,
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
    final receiverFormatted =
        '${NumberFormat('#,##0.00').format(payoutMinor / 100)} $payoutCurrency';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: OpeiBrand.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OpeiBrand.hairline, width: 1),
      ),
      child: Column(
        children: [
          // ── Receiver header ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
                          _initials(receiverName),
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
                        receiverName,
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
                        countryName,
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
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'RECEIVED',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: OpeiBrand.inkTertiary,
                          letterSpacing: 0.9,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          receiverFormatted,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: OpeiBrand.ink,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5, color: OpeiBrand.hairline),
          _Row(label: 'Amount', value: '\$$amountUsd'),
          const _Sep(),
          _Row(label: 'Fee', value: '\$$feeUsd'),
          const _Sep(),
          _Row(
            label: 'Total paid',
            value: '\$$totalUsd',
            emphasized: true,
          ),
          const _Sep(),
          _Row(label: 'Date', value: dateText),
          if (reference.isNotEmpty) ...[
            const _Sep(),
            _Row(label: 'Reference', value: reference, mono: true),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;
  final bool mono;

  const _Row({
    required this.label,
    required this.value,
    this.emphasized = false,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: emphasized ? 14 : 12.5,
                fontWeight: emphasized ? FontWeight.w800 : FontWeight.w700,
                color: OpeiBrand.ink,
                letterSpacing: mono ? 0.4 : -0.2,
              ),
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
