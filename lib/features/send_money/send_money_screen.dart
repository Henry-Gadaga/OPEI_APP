import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/money/money.dart';
import 'package:opei/features/send_money/send_money_controller.dart';
import 'package:opei/features/send_money/send_money_state.dart';
import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/theme.dart';
import 'package:opei/widgets/success_hero.dart';

class SendMoneyScreen extends ConsumerStatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  ConsumerState<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends ConsumerState<SendMoneyScreen> {
  final _emailController = TextEditingController();
  final _amountController = TextEditingController();
  final _emailFormKey = GlobalKey<FormState>();
  final _amountFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Reset state when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sendMoneyControllerProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sendMoneyControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: OpeiColors.pureWhite,
      appBar: AppBar(
        backgroundColor: OpeiColors.pureWhite,
        elevation: 0,
        leading: state.currentStep == SendMoneyStep.result
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: OpeiColors.pureBlack),
                onPressed: () {
                  if (state.currentStep == SendMoneyStep.emailLookup) {
                    context.pop();
                  } else {
                    ref.read(sendMoneyControllerProvider.notifier).goBack();
                  }
                },
              ),
        title: Text(
          l10n.sendMoneyTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _buildStepContent(context, state, l10n),
        ),
      ),
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    SendMoneyState state,
    AppLocalizations l10n,
  ) {
    switch (state.currentStep) {
      case SendMoneyStep.emailLookup:
        return _buildEmailLookupStep(context, state, l10n);
      case SendMoneyStep.amountEntry:
        return _buildAmountEntryStep(context, state, l10n);
      case SendMoneyStep.preview:
        return _buildPreviewStep(context, state, l10n);
      case SendMoneyStep.result:
        return _ResultStep(state: state);
    }
  }

  Widget _buildEmailLookupStep(
    BuildContext context,
    SendMoneyState state,
    AppLocalizations l10n,
  ) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          Text(
            l10n.sendMoneyRecipientEmailLabel,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            enabled: !state.isLoading,
            decoration: InputDecoration(
              hintText: l10n.emailAddressHint,
              prefixIcon: const Icon(Icons.email_outlined, size: 18),
              prefixIconConstraints: const BoxConstraints(minWidth: 36),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              errorText: state.errorMessage?.isNotEmpty == true
                  ? state.errorMessage
                  : null,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.sendMoneyEnterEmailError;
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return l10n.sendMoneyValidEmailError;
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleLookup(),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: state.isLoading ? null : _handleLookup,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: state.isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        OpeiColors.pureWhite,
                      ),
                    ),
                  )
                : Text(l10n.continueCta),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountEntryStep(
    BuildContext context,
    SendMoneyState state,
    AppLocalizations l10n,
  ) {
    return Form(
      key: _amountFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: OpeiColors.grey100,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: OpeiBrand.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      state.lookupResult!.bestDisplayName[0].toUpperCase(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: OpeiColors.pureWhite,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.sendMoneySendingToLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: OpeiColors.grey600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.lookupResult!.bestDisplayName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.amountLabel,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            enabled: !state.isLoading,
            decoration: InputDecoration(
              hintText: l10n.sendMoneyAmountHint,
              prefixIcon: const Icon(Icons.attach_money, size: 18),
              prefixIconConstraints: const BoxConstraints(minWidth: 36),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              errorText: state.errorMessage?.isNotEmpty == true
                  ? state.errorMessage
                  : null,
            ),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.sendMoneyEnterAmountError;
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return l10n.sendMoneyValidAmountError;
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleAmountContinue(),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: state.isLoading ? null : _handleAmountContinue,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: state.isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        OpeiColors.pureWhite,
                      ),
                    ),
                  )
                : Text(l10n.continueCta),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewStep(
    BuildContext context,
    SendMoneyState state,
    AppLocalizations l10n,
  ) {
    final preview = state.previewResult;
    if (preview == null) {
      return Center(child: Text(l10n.sendMoneyNoPreview));
    }

    final receiver = state.lookupResult!;
    final initial = receiver.bestDisplayName.trim().isEmpty
        ? '?'
        : receiver.bestDisplayName.trim()[0].toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Hero — what the recipient will receive ─────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                OpeiBrand.primaryGradientStart,
                OpeiBrand.primaryGradientEnd,
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: OpeiBrand.primary.withValues(alpha: 0.18),
                offset: const Offset(0, 8),
                blurRadius: 22,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'RECIPIENT GETS',
                      style: TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white70,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        preview.receiverCreditAmountMoney.format(
                          includeCurrencySymbol: true,
                        ),
                        style: const TextStyle(
                          fontFamily: kPrimaryFontFamily,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.8,
                          height: 1.05,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ── Section: Recipient ──────────────────────────────────────────
        _SendSectionLabel(l10n.sendMoneyRecipientSection),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: OpeiBrand.surfaceMuted,
            borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
            border: Border.all(color: OpeiBrand.hairline, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: OpeiBrand.primaryTint,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: OpeiBrand.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      receiver.bestDisplayName,
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
                      receiver.email,
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
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ── Section: Breakdown ──────────────────────────────────────────
        _SendSectionLabel(l10n.paymentBreakdown),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: OpeiBrand.surfaceMuted,
            borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
            border: Border.all(color: OpeiBrand.hairline, width: 1),
          ),
          child: Column(
            children: [
              _SendPreviewRow(
                label: l10n.sendMoneyTransferAmountRow,
                value: preview.transferAmountMoney.format(
                  includeCurrencySymbol: true,
                ),
              ),
              const _SendPreviewDivider(),
              _SendPreviewRow(
                label: l10n.feeRow,
                value: preview.estimatedFeeMoney.format(
                  includeCurrencySymbol: true,
                ),
              ),
              const _SendPreviewDivider(),
              _SendPreviewRow(
                label: l10n.sendMoneyTotalToChargeRow,
                value: preview.totalDebitMoney.format(
                  includeCurrencySymbol: true,
                ),
                emphasize: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ── Section: Wallet impact ──────────────────────────────────────
        _SendSectionLabel(l10n.afterThisPayment),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: OpeiBrand.surfaceMuted,
            borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
            border: Border.all(color: OpeiBrand.hairline, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: OpeiBrand.primaryTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 18,
                  color: OpeiBrand.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.walletBalanceRow,
                  style: TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: OpeiBrand.inkSecondary,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              Text(
                preview.senderBalanceAfterMoney.format(
                  includeCurrencySymbol: true,
                ),
                style: const TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: OpeiBrand.ink,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),

        if (state.errorMessage?.isNotEmpty == true) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: OpeiBrand.danger.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: OpeiBrand.danger.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 14,
                  color: OpeiBrand.danger,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.errorMessage!,
                    style: const TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: OpeiBrand.danger,
                      letterSpacing: -0.1,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 28),

        FilledButton(
          onPressed: state.isLoading ? null : _handleConfirmTransfer,
          style: FilledButton.styleFrom(
            backgroundColor: OpeiBrand.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: OpeiBrand.primaryTintStrong,
            disabledForegroundColor: OpeiBrand.primary.withValues(alpha: 0.6),
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(OpeiBrand.radiusCta),
            ),
          ),
          child: state.isLoading
              ? const CupertinoActivityIndicator(
                  radius: 11,
                  color: Colors.white,
                )
              : Text(
                  l10n.sendMoneySendNowCta,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: state.isLoading
              ? null
              : () => ref.read(sendMoneyControllerProvider.notifier).goBack(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10),
            foregroundColor: OpeiBrand.primary,
          ),
          child: Text(
            l10n.editAmountCta,
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Future<void> _handleLookup() async {
    if (_emailFormKey.currentState?.validate() ?? false) {
      await ref
          .read(sendMoneyControllerProvider.notifier)
          .lookupWallet(_emailController.text.trim().toLowerCase());
    }
  }

  Future<void> _handleAmountContinue() async {
    if (_amountFormKey.currentState?.validate() ?? false) {
      final money = Money.parse(_amountController.text.trim());
      await ref
          .read(sendMoneyControllerProvider.notifier)
          .previewTransfer(money);
    }
  }

  Future<void> _handleConfirmTransfer() async {
    await ref.read(sendMoneyControllerProvider.notifier).confirmTransfer();
  }
}

class _ResultStep extends ConsumerWidget {
  final SendMoneyState state;

  const _ResultStep({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSuccess = state.transferSuccess;
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 36),
          if (isSuccess) ...[
            const SuccessHero(iconHeight: 64, gap: 2),
            const SizedBox(height: 16),
            Text(
              l10n.sendMoneyTransferCompleteTitle,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            if (state.transferResult != null) ...[
              Text(
                l10n.sendMoneyTransferCompleteSubtitle(
                  state.transferResult!.amountMoney.format(
                    includeCurrencySymbol: true,
                  ),
                  state.lookupResult!.bestDisplayName,
                ),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: OpeiColors.grey600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: OpeiColors.grey100,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      context,
                      l10n.sendMoneyAmountSentRow,
                      state.transferResult!.amountMoney.format(
                        includeCurrencySymbol: true,
                      ),
                      isHighlight: true,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      l10n.sendMoneyNewBalanceRow,
                      state.transferResult!.fromBalanceMoney.format(
                        includeCurrencySymbol: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ] else ...[
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: OpeiColors.errorRed.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_rounded,
                size: 46,
                color: OpeiColors.errorRed,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              l10n.sendMoneyTransferFailedTitle,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              state.errorMessage ?? l10n.sendMoneyTransferFailedSubtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: OpeiColors.grey600),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (isSuccess) {
                  context.pop();
                } else {
                  ref.read(sendMoneyControllerProvider.notifier).reset();
                }
              },
              child: Text(isSuccess ? l10n.doneCta : l10n.tryAgainCta),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isHighlight = false,
    bool isSmall = false,
  }) {
    if (isSmall) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: OpeiColors.grey600,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 11,
              fontFamily: 'monospace',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isHighlight ? OpeiColors.pureBlack : OpeiColors.grey600,
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
              fontSize: isHighlight ? 18 : null,
              color: isHighlight ? OpeiColors.pureBlack : null,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Preview helpers — mirror the create-card flow's structure & spacing.

class _SendSectionLabel extends StatelessWidget {
  final String label;
  const _SendSectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: kPrimaryFontFamily,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: OpeiBrand.inkTertiary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _SendPreviewRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _SendPreviewRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 13,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
              color: emphasize ? OpeiBrand.ink : OpeiBrand.inkSecondary,
              letterSpacing: -0.1,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: emphasize ? 16 : 14,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
              color: OpeiBrand.ink,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SendPreviewDivider extends StatelessWidget {
  const _SendPreviewDivider();

  @override
  Widget build(BuildContext context) => const Divider(
    height: 1,
    thickness: 0.5,
    color: OpeiBrand.hairline,
    indent: 14,
    endIndent: 14,
  );
}
