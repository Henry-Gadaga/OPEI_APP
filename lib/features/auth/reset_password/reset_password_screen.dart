import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:opei/features/auth/reset_password/reset_password_controller.dart';
import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/theme.dart';
import 'package:opei/widgets/opei_premium/opei_premium.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _codeFocusNode = FocusNode();
  final _newPasswordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_onAnyChange);
    _newPasswordController.addListener(_onAnyChange);
    _confirmPasswordController.addListener(_onAnyChange);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _codeFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _onAnyChange() {
    if (!mounted) return;
    setState(() {});
  }

  bool get _isFormValid {
    final code = _codeController.text;
    final pin = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;
    final pinOk = RegExp(r'^\d{6}$').hasMatch(pin);
    return code.length == 6 && pinOk && confirm == pin;
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();

    final success = await ref
        .read(resetPasswordControllerProvider(widget.email).notifier)
        .resetPassword();

    if (success && mounted) {
      _showSuccessSheet();
    }
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/login');
    }
  }

  void _showSuccessSheet() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: OpeiBrand.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.of(sheetContext).viewPadding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: OpeiBrand.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: OpeiBrand.success,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.resetPinUpdatedTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: OpeiBrand.ink,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.resetPinUpdatedSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: OpeiBrand.inkSecondary,
                letterSpacing: -0.1,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            OpeiPrimaryButton(
              label: l10n.resetPinGoToSignInCta,
              onPressed: () {
                Navigator.of(sheetContext).pop();
                context.go('/login');
              },
              trailingIcon: Icons.arrow_forward_rounded,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(resetPasswordControllerProvider(widget.email));
    final isLoading = state.isLoading;

    final media = MediaQuery.of(context);
    final topPad = media.viewPadding.top;
    final bottomPad = media.viewPadding.bottom;
    final keyboardInset = media.viewInsets.bottom;

    const headerContentHeight = 190.0;
    final headerHeight = headerContentHeight + topPad;
    const panelOverlap = 32.0;

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
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              // ── Gradient header ────────────────────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: headerHeight,
                child: ClipRect(
                  child: Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF1E55D8),
                              Color(0xFF3D7BFF),
                              Color(0xFF6E9DFF),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: -60,
                        right: -50,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.09),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -40,
                        left: -30,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.07),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── White form card ────────────────────────────────────────
              Positioned(
                top: headerHeight - panelOverlap,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: OpeiBrand.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 24,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                          physics: const ClampingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.resetPinCodeAndNewPinTitle,
                                style: TextStyle(
                                  fontFamily: kPrimaryFontFamily,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                  color: OpeiBrand.ink,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text.rich(
                                TextSpan(
                                  text: l10n.resetPinCodePrefix,
                                  style: const TextStyle(
                                    fontFamily: kPrimaryFontFamily,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: OpeiBrand.inkSecondary,
                                    letterSpacing: -0.1,
                                    height: 1.45,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: widget.email,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: OpeiBrand.ink,
                                      ),
                                    ),
                                    TextSpan(text: l10n.resetPinCodeSuffix),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (state.errorMessage != null) ...[
                                _ErrorBanner(message: state.errorMessage!),
                                const SizedBox(height: 16),
                              ],
                              OpeiTextField(
                                controller: _codeController,
                                focusNode: _codeFocusNode,
                                label: l10n.resetPinVerificationCodeLabel,
                                hint: l10n.resetPinVerificationCodeHint,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                enabled: !isLoading,
                                autofocus: true,
                                maxLength: 6,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6),
                                ],
                                errorText: state.codeError,
                                prefix: const Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Icon(
                                    Icons.numbers_rounded,
                                    size: 18,
                                    color: OpeiBrand.inkTertiary,
                                  ),
                                ),
                                onChanged: (value) {
                                  ref
                                      .read(
                                        resetPasswordControllerProvider(
                                          widget.email,
                                        ).notifier,
                                      )
                                      .updateCode(value);
                                },
                                onSubmitted: (_) =>
                                    _newPasswordFocusNode.requestFocus(),
                              ),
                              const SizedBox(height: 14),
                              OpeiTextField(
                                controller: _newPasswordController,
                                focusNode: _newPasswordFocusNode,
                                label: l10n.resetPinNewPinLabel,
                                hint: l10n.pinHint,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                enabled: !isLoading,
                                obscureText: _obscureNewPassword,
                                maxLength: 6,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6),
                                ],
                                errorText: state.passwordError,
                                prefix: const Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Icon(
                                    Icons.lock_outline_rounded,
                                    size: 18,
                                    color: OpeiBrand.inkTertiary,
                                  ),
                                ),
                                suffix: IconButton(
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  splashRadius: 16,
                                  icon: Icon(
                                    _obscureNewPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: OpeiBrand.inkTertiary,
                                    size: 18,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscureNewPassword =
                                        !_obscureNewPassword,
                                  ),
                                ),
                                onChanged: (value) {
                                  ref
                                      .read(
                                        resetPasswordControllerProvider(
                                          widget.email,
                                        ).notifier,
                                      )
                                      .updateNewPassword(value);
                                },
                                onSubmitted: (_) =>
                                    _confirmPasswordFocusNode.requestFocus(),
                              ),
                              const SizedBox(height: 14),
                              OpeiTextField(
                                controller: _confirmPasswordController,
                                focusNode: _confirmPasswordFocusNode,
                                label: l10n.resetPinConfirmPinLabel,
                                hint: l10n.pinHint,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                enabled: !isLoading,
                                obscureText: _obscureConfirmPassword,
                                maxLength: 6,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6),
                                ],
                                errorText: state.confirmPasswordError,
                                helperText: state.confirmPasswordError == null
                                    ? l10n.resetPinHelperText
                                    : null,
                                prefix: const Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Icon(
                                    Icons.lock_outline_rounded,
                                    size: 18,
                                    color: OpeiBrand.inkTertiary,
                                  ),
                                ),
                                suffix: IconButton(
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  splashRadius: 16,
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: OpeiBrand.inkTertiary,
                                    size: 18,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscureConfirmPassword =
                                        !_obscureConfirmPassword,
                                  ),
                                ),
                                onChanged: (value) {
                                  ref
                                      .read(
                                        resetPasswordControllerProvider(
                                          widget.email,
                                        ).notifier,
                                      )
                                      .updateConfirmPassword(value);
                                },
                                onSubmitted: (_) => _handleSubmit(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          20,
                          24,
                          20 + bottomPad + keyboardInset,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OpeiPrimaryButton(
                              label: l10n.resetPinCta,
                              loading: isLoading,
                              onPressed: _isFormValid && !isLoading
                                  ? _handleSubmit
                                  : null,
                              trailingIcon: Icons.check_rounded,
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              children: [
                                Text(
                                  l10n.resetPinDidntGetCode,
                                  style: TextStyle(
                                    fontFamily: kPrimaryFontFamily,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: OpeiBrand.inkSecondary,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: isLoading ? null : _handleBack,
                                  child: Text(
                                    l10n.resetPinRequestNewCta,
                                    style: TextStyle(
                                      fontFamily: kPrimaryFontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: OpeiBrand.primary,
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Header content ─────────────────────────────────────────
              Positioned(
                top: topPad,
                left: 0,
                right: 0,
                height: headerContentHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: isLoading ? null : _handleBack,
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
                          const Spacer(),
                          const _ResetProgress(stage: 1),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.resetPinTitle,
                        style: TextStyle(
                          fontFamily: kPrimaryFontFamily,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.6,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.resetPinSubtitle,
                        style: TextStyle(
                          fontFamily: kPrimaryFontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.85),
                          letterSpacing: -0.1,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 2-pill progress indicator for the forgot-PIN flow. Identical to the one
/// used in forgot_password_screen.dart so the two screens feel like one flow.
class _ResetProgress extends StatelessWidget {
  final int stage; // 0 = request, 1 = reset
  const _ResetProgress({required this.stage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(2, (i) {
        final completed = i < stage;
        final active = i == stage;
        return AnimatedContainer(
          duration: OpeiBrand.motion,
          curve: OpeiBrand.motionCurve,
          width: active ? 24 : 8,
          height: 6,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: completed || active
                ? Colors.white
                : Colors.white.withValues(alpha: 0.30),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: OpeiBrand.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(OpeiBrand.radiusField),
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
            color: OpeiBrand.danger,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w500,
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
