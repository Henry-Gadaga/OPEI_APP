import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/data/models/promo_card_create_result.dart';
import 'package:opei/features/cards/promo_card_creation_controller.dart';
import 'package:opei/features/cards/promo_card_creation_state.dart';
import 'package:opei/features/deposit/deposit_screen.dart';
import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/responsive/responsive_widgets.dart';
import 'package:opei/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class CreateVirtualCardFlow extends ConsumerStatefulWidget {
  const CreateVirtualCardFlow({super.key});

  @override
  ConsumerState<CreateVirtualCardFlow> createState() =>
      _CreateVirtualCardFlowState();
}

class _CreateVirtualCardFlowState extends ConsumerState<CreateVirtualCardFlow> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(promoCardCreationControllerProvider.notifier);
      controller.reset();
      controller.prepare();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(promoCardCreationControllerProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _buildStage(state),
        ),
      ),
    );
  }

  Widget _buildStage(PromoCardCreationState state) {
    switch (state.stage) {
      case PromoCardStage.preparing:
        return _PreparingScreen(
          key: const ValueKey('preparing'),
          errorMessage: state.errorMessage,
          onRetry: () =>
              ref.read(promoCardCreationControllerProvider.notifier).prepare(),
          onClose: () => Navigator.of(context).pop(),
        );

      case PromoCardStage.confirm:
        return _ConfirmScreen(
          key: const ValueKey('confirm'),
          state: state,
          onConfirm: () => ref
              .read(promoCardCreationControllerProvider.notifier)
              .createCard(),
          onClose: () => Navigator.of(context).pop(),
        );

      case PromoCardStage.creating:
        return const _CreatingScreen(key: ValueKey('creating'));

      case PromoCardStage.success:
        return _SuccessScreen(
          key: const ValueKey('success'),
          result: state.result!,
          onDone: () => Navigator.of(context).pop(state.result),
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stage 1 — Preparing
// ─────────────────────────────────────────────────────────────────────────────

class _PreparingScreen extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  const _PreparingScreen({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).viewPadding.top;
    final hasError = errorMessage != null;

    return _Shell(
      topPad: topPad,
      onClose: hasError ? onClose : null,
      child: hasError
          ? _ErrorBody(message: errorMessage!, onRetry: onRetry)
          : _LoadingBody(
              label: AppLocalizations.of(context)!.cardsSettingUpCardLoading,
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stage 2 — Confirm
// ─────────────────────────────────────────────────────────────────────────────

class _ConfirmScreen extends ConsumerWidget {
  final PromoCardCreationState state;
  final VoidCallback onConfirm;
  final VoidCallback onClose;

  const _ConfirmScreen({
    super.key,
    required this.state,
    required this.onConfirm,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPad = MediaQuery.of(context).viewPadding.top;
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;
    final prepare = state.prepare!;
    final canCreate = prepare.canCreate;

    return _Shell(
      topPad: topPad,
      onClose: onClose,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: OpeiBrand.primaryTint,
                      borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: OpeiBrand.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.card_membership_rounded,
                            size: 18,
                            color: OpeiBrand.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            canCreate
                                ? AppLocalizations.of(
                                    context,
                                  )!.cardsReadyToCreate
                                : AppLocalizations.of(
                                    context,
                                  )!.cardsTopupToCreate,
                            style: const TextStyle(
                              fontFamily: kPrimaryFontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: OpeiBrand.ink,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    canCreate
                        ? AppLocalizations.of(context)!.cardsPaymentSummaryLabel
                        : AppLocalizations.of(context)!.cardsTopupRequiredLabel,
                    style: const TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: OpeiBrand.inkTertiary,
                      letterSpacing: 0.9,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (canCreate)
                    _CanCreateBody(prepare: prepare)
                  else
                    _InsufficientBody(prepare: prepare),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 14),
                    _InlineError(message: state.errorMessage!),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomPad),
            child: canCreate
                ? SizedBox(
                    width: double.infinity,
                    child: _PrimaryButton(
                      label: AppLocalizations.of(context)!.cardsCreateMyCardCta,
                      loading: state.isBusy,
                      onTap: onConfirm,
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    child: _PrimaryButton(
                      label: AppLocalizations.of(context)!.cardsAddFundsCta,
                      onTap: () => showResponsiveBottomSheet(
                        context: context,
                        dismissOnBarrierTap: true,
                        builder: (_) => const DepositOptionsSheet(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Confirm — can create breakdown
// ─────────────────────────────────────────────────────────────────────────────

class _CanCreateBody extends StatelessWidget {
  final dynamic prepare; // PromoCardPrepare

  const _CanCreateBody({required this.prepare});

  @override
  Widget build(BuildContext context) {
    final balanceAfterPositive = prepare.walletBalanceAfterCents >= 0;

    return Column(
      children: [
        // ── Fee breakdown ───────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: OpeiBrand.surface,
            borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
            border: Border.all(color: OpeiBrand.hairline),
          ),
          child: Column(
            children: [
              _Row(
                icon: Icons.payments_outlined,
                label: AppLocalizations.of(context)!.cardsCreationFeeRow,
                value: _usd(prepare.creationFeeCents),
              ),
              const _Divider(),
              _Row(
                icon: Icons.bolt_outlined,
                label: AppLocalizations.of(context)!.cardsActivationFeeRow,
                value: _usd(prepare.sweepCents),
              ),
              const _Divider(),
              _Row(
                icon: Icons.credit_card_outlined,
                label: AppLocalizations.of(context)!.cardsOnYourCardRow,
                value: _usd(prepare.cardWillReceiveCents),
                valueColor: OpeiBrand.success,
                valueWeight: FontWeight.w700,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // ── Total highlight ─────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: OpeiBrand.primaryTint,
            borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: OpeiBrand.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 16,
                  color: OpeiBrand.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.sendPreviewTotalChargedRow,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: OpeiBrand.ink,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    _usd(prepare.totalToChargeCents),
                    style: const TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: OpeiBrand.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // ── Wallet impact ───────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: OpeiBrand.surface,
            borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
            border: Border.all(color: OpeiBrand.hairline),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.walletBalanceRow,
                        style: TextStyle(
                          fontFamily: kPrimaryFontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: OpeiBrand.inkTertiary,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _usd(prepare.walletBalanceCents),
                        style: const TextStyle(
                          fontFamily: kPrimaryFontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: OpeiBrand.ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(width: 1, height: 36, color: OpeiBrand.hairline),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.cardsAfterCreationRow,
                        style: const TextStyle(
                          fontFamily: kPrimaryFontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: OpeiBrand.inkTertiary,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _usd(prepare.walletBalanceAfterCents),
                        style: TextStyle(
                          fontFamily: kPrimaryFontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: balanceAfterPositive
                              ? OpeiBrand.success
                              : OpeiBrand.danger,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
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

// ─────────────────────────────────────────────────────────────────────────────
// Confirm — insufficient funds
// ─────────────────────────────────────────────────────────────────────────────

class _InsufficientBody extends StatelessWidget {
  final dynamic prepare;

  const _InsufficientBody({required this.prepare});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: OpeiBrand.surface,
            borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
            border: Border.all(color: OpeiBrand.hairline),
          ),
          child: Column(
            children: [
              _Row(
                label: AppLocalizations.of(context)!.cardsAmountNeededRow,
                value: _usd(prepare.totalToChargeCents),
              ),
              _Divider(),
              _Row(
                label: AppLocalizations.of(context)!.walletBalanceRow,
                value: _usd(prepare.walletBalanceCents),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ── Shortfall highlight ─────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4E5),
            borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
            border: Border.all(color: const Color(0xFFFFD9A0)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 17,
                color: Color(0xFFB36B00),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.cardsAddToContinueLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8A5200),
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    _usd(prepare.shortfallCents),
                    style: const TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFB36B00),
                      letterSpacing: -0.4,
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

// ─────────────────────────────────────────────────────────────────────────────
// Stage 3 — Creating
// ─────────────────────────────────────────────────────────────────────────────

class _CreatingScreen extends StatelessWidget {
  const _CreatingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).viewPadding.top;
    return _Shell(
      topPad: topPad,
      onClose: null,
      child: _LoadingBody(
        label: AppLocalizations.of(context)!.cardsCreatingCardLoading,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stage 4 — Success
// ─────────────────────────────────────────────────────────────────────────────

class _SuccessScreen extends StatelessWidget {
  final PromoCardCreateResult result;
  final VoidCallback onDone;

  const _SuccessScreen({super.key, required this.result, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).viewPadding.top;
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;

    return _Shell(
      topPad: topPad,
      onClose: null,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + bottomPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            // ── Success icon ──────────────────────────────────────
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: OpeiBrand.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: OpeiBrand.success,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.cardsOnItsWayTitle,
              style: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: OpeiBrand.ink,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.cardsOnItsWayMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: OpeiBrand.inkSecondary,
                height: 1.5,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 28),
            // ── Reference chip ────────────────────────────────────
            if (result.reference.isNotEmpty)
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 80,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: OpeiBrand.surfaceMuted,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.tag_rounded,
                      size: 13,
                      color: OpeiBrand.inkSecondary,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        result.reference,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: kPrimaryFontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: OpeiBrand.inkSecondary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            // ── Done button ───────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: _PrimaryButton(
                label: AppLocalizations.of(context)!.doneCta,
                onTap: onDone,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Full-screen shell with gradient header strip + close button.
class _Shell extends StatelessWidget {
  final double topPad;
  final VoidCallback? onClose;
  final Widget child;

  const _Shell({required this.topPad, required this.child, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Gradient header strip
        Container(
          height: topPad + 56,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E55D8), Color(0xFF3D7BFF), Color(0xFF6E9DFF)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (onClose != null)
                    GestureDetector(
                      onTap: onClose,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 36),
                  const Spacer(),
                  Text(
                    AppLocalizations.of(context)!.cardsCreateCardCta,
                    style: const TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 36),
                ],
              ),
            ),
          ),
        ),
        // Body
        Expanded(child: child),
      ],
    );
  }
}

class _LoadingBody extends StatelessWidget {
  final String label;
  const _LoadingBody({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: OpeiBrand.primary,
            strokeWidth: 2.5,
          ),
          const SizedBox(height: 20),
          Text(
            label,
            style: const TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: OpeiBrand.inkSecondary,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
              size: 26,
              color: OpeiBrand.inkSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.cardsLoadDetailsError,
            style: const TextStyle(
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
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: OpeiBrand.primaryTint,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                AppLocalizations.of(context)!.tryAgainCta,
                style: const TextStyle(
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
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(OpeiBrand.radiusField),
        border: Border.all(color: OpeiBrand.danger.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 15,
            color: OpeiBrand.danger,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: OpeiBrand.danger,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;

  const _PrimaryButton({required this.label, this.onTap, this.loading = false});

  @override
  Widget build(BuildContext context) {
    final disabled = loading || onTap == null;
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 54,
        decoration: BoxDecoration(
          gradient: disabled
              ? null
              : const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF1A4BC4), Color(0xFF3D7BFF)],
                ),
          color: disabled ? const Color(0xFFB0C4F0) : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF1A4BC4).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.2,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.1,
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Breakdown table helpers ───────────────────────────────────────────────────

class _Row extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String value;
  final Color? valueColor;
  final FontWeight? valueWeight;

  const _Row({
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
    this.valueWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: OpeiBrand.inkTertiary),
            const SizedBox(width: 10),
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
                fontSize: 13.5,
                fontWeight: valueWeight ?? FontWeight.w600,
                color: valueColor ?? OpeiBrand.ink,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 0.8, color: OpeiBrand.hairline);
  }
}

// ── Formatting helper ─────────────────────────────────────────────────────────

String _usd(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';
