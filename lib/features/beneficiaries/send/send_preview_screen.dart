import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:opei/core/navigation/opei_page_transitions.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/models/beneficiary.dart';
import 'package:opei/data/models/payout_review.dart';
import 'package:opei/features/beneficiaries/send/send_mobile_money_controller.dart';
import 'package:opei/features/beneficiaries/send/send_result_screen.dart';
import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/theme.dart';
import 'package:opei/widgets/opei_premium/opei_app_bar.dart';
import 'package:opei/widgets/opei_premium/opei_primary_button.dart';

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
      Navigator.of(context).pushReplacement(
        OpeiPageRoute(
          builder: (_) => SendResultScreen(
            beneficiary: beneficiary,
            countryName: countryName,
            flag: flag,
          ),
        ),
      );
    } else {
      final s = ref.read(sendMobileMoneyControllerProvider(beneficiary));
      final err = s.initiateError ?? s.finalizeError;
      if (err != null) showError(context, err);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(sendMobileMoneyControllerProvider(beneficiary));
    final review = state.review;
    final name = beneficiary.accountName ?? l10n.sendReceiverFallback;
    final masked = beneficiary.accountNumberMasked ?? '';

    if (review == null) {
      return Scaffold(
        backgroundColor: OpeiBrand.surface,
        appBar: const OpeiAppBar(),
        body: Center(
          child: Text(
            l10n.sendPreviewQuoteUnavailable,
            style: const TextStyle(
              fontSize: 13.5,
              color: OpeiBrand.inkSecondary,
            ),
          ),
        ),
      );
    }

    final canProceed = review.walletCheck?.canProceed ?? true;
    final shortfall = review.walletCheck?.shortfallCents ?? 0;
    final isBusy = state.isInitiating || state.isFinalizing;
    final walletAfterCents = review.walletCheck?.remainingAvailableBalanceCents;
    final hasDescription = state.paymentDescription.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: OpeiBrand.surface,
      appBar: const OpeiAppBar(),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Page title ─────────────────────────────────────
                    Text(
                      l10n.sendPreviewTitle,
                      style: TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: OpeiBrand.ink,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.sendPreviewSubtitle,
                      style: TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        color: OpeiBrand.inkSecondary,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Hero amount ────────────────────────────────────
                    _AmountHero(review: review),
                    const SizedBox(height: 16),

                    // ── Unified details card ───────────────────────────
                    _DetailsCard(
                      review: review,
                      name: name,
                      masked: masked,
                      flag: flag,
                      countryName: countryName,
                      walletAfterCents: walletAfterCents,
                      description: hasDescription
                          ? state.paymentDescription.trim()
                          : null,
                    ),

                    // ── Status banners ─────────────────────────────────
                    if (review.expiresAt != null) ...[
                      const SizedBox(height: 10),
                      _ExpiryHint(expiresAt: review.expiresAt!),
                    ],
                    if (!canProceed) ...[
                      const SizedBox(height: 10),
                      _StatusBanner(
                        icon: Icons.warning_amber_rounded,
                        iconColor: OpeiBrand.warning,
                        bgColor: OpeiBrand.warning.withValues(alpha: 0.08),
                        borderColor: OpeiBrand.warning.withValues(alpha: 0.22),
                        message: l10n.sendPreviewBalanceShortfall(
                          (shortfall / 100).toStringAsFixed(2),
                        ),
                      ),
                    ],
                    if (state.initiateError != null ||
                        state.finalizeError != null) ...[
                      const SizedBox(height: 10),
                      _StatusBanner(
                        icon: Icons.error_outline_rounded,
                        iconColor: OpeiBrand.danger,
                        bgColor: OpeiBrand.danger.withValues(alpha: 0.07),
                        borderColor: OpeiBrand.danger.withValues(alpha: 0.18),
                        message: (state.initiateError ?? state.finalizeError)!,
                        messageColor: OpeiBrand.danger,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── CTA ────────────────────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).viewPadding.bottom + 16,
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
                    Text(
                      state.isInitiating
                          ? l10n.sendPreviewReservingFunds
                          : l10n.sendPreviewSendingPayment,
                      style: const TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: OpeiBrand.inkSecondary,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  OpeiPrimaryButton(
                    label: l10n.sendPreviewConfirmCta,
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

class _AmountHero extends StatelessWidget {
  final PayoutReview review;
  const _AmountHero({required this.review});

  static String _fmt(int minor, String currency) =>
      '${NumberFormat('#,##0.00').format(minor / 100)} $currency';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            OpeiBrand.primaryGradientStart,
            OpeiBrand.primaryGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: OpeiBrand.primary.withValues(alpha: 0.20),
            offset: const Offset(0, 8),
            blurRadius: 20,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: you pay / they receive stack
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.sendPreviewYouPayLabel,
                  style: TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white60,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '\$${review.totalDebitAmountUsd}',
                    style: const TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.8,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.18),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.sendPreviewTheyReceiveLabel,
                  style: TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white60,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _fmt(review.payoutAmountMinor, review.payoutCurrency),
                    style: const TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.4,
                      height: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right: icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

// Single unified details card — receiver + breakdown + wallet after + note
class _DetailsCard extends StatelessWidget {
  final PayoutReview review;
  final String name;
  final String masked;
  final String flag;
  final String countryName;
  final int? walletAfterCents;
  final String? description;

  const _DetailsCard({
    required this.review,
    required this.name,
    required this.masked,
    required this.flag,
    required this.countryName,
    required this.walletAfterCents,
    required this.description,
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
    final l10n = AppLocalizations.of(context)!;
    final showWalletAfter = walletAfterCents != null;
    final walletUsd = showWalletAfter
        ? '\$${(walletAfterCents! / 100).toStringAsFixed(2)}'
        : null;

    return Container(
      decoration: BoxDecoration(
        color: OpeiBrand.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OpeiBrand.hairline, width: 1),
      ),
      child: Column(
        children: [
          // ── Receiver row ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: OpeiBrand.primaryTint,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _initials(name),
                          style: const TextStyle(
                            fontFamily: kPrimaryFontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: OpeiBrand.primary,
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
                            color: OpeiBrand.surfaceMuted,
                            width: 1.5,
                          ),
                        ),
                        child: Text(flag, style: const TextStyle(fontSize: 10)),
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
                          fontFamily: kPrimaryFontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: OpeiBrand.ink,
                          letterSpacing: -0.2,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        masked.isNotEmpty
                            ? '$masked · $countryName'
                            : countryName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: kPrimaryFontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: OpeiBrand.inkSecondary,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: OpeiBrand.success.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    l10n.sendPreviewRecipientBadge,
                    style: TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: OpeiBrand.success,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _Divider(),

          // ── Breakdown rows ────────────────────────────────────────
          _DetailRow(
            label: l10n.sendPreviewSendAmountRow,
            value: '\$${review.requiredAmountUsd}',
          ),
          _Divider(),
          _DetailRow(
            label: l10n.sendPreviewTransferFeeRow,
            value: '\$${review.feeAmountUsd}',
          ),
          _Divider(),
          _DetailRow(
            label: l10n.sendPreviewTotalChargedRow,
            value: '\$${review.totalDebitAmountUsd}',
            valueWeight: FontWeight.w800,
            valueSize: 15,
          ),

          if (showWalletAfter) ...[
            _Divider(),
            _DetailRow(
              label: l10n.sendPreviewWalletAfterRow,
              value: walletUsd!,
              icon: Icons.account_balance_wallet_outlined,
            ),
          ],

          if (description != null) ...[
            _Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      l10n.sendPreviewNoteRow,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: OpeiBrand.inkSecondary,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: OpeiBrand.ink,
                        letterSpacing: -0.1,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final FontWeight valueWeight;
  final double valueSize;

  const _DetailRow({
    required this.label,
    required this.value,
    this.icon,
    this.valueWeight = FontWeight.w700,
    this.valueSize = 13.5,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: OpeiBrand.inkTertiary),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: OpeiBrand.inkSecondary,
                letterSpacing: -0.1,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: valueSize,
                fontWeight: valueWeight,
                color: OpeiBrand.ink,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Divider(
    height: 1,
    thickness: 0.5,
    color: OpeiBrand.hairline,
    indent: 14,
    endIndent: 14,
  );
}

class _ExpiryHint extends StatelessWidget {
  final DateTime expiresAt;
  const _ExpiryHint({required this.expiresAt});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        const Icon(
          Icons.schedule_outlined,
          size: 12,
          color: OpeiBrand.inkTertiary,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            l10n.sendPreviewQuoteExpiresAt(
              DateFormat.Hm().format(expiresAt.toLocal()),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: OpeiBrand.inkTertiary,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;
  final String message;
  final Color messageColor;

  const _StatusBanner({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
    required this.message,
    this.messageColor = OpeiBrand.ink,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: messageColor,
                letterSpacing: -0.1,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
