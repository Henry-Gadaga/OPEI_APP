import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:opei/features/auth/forgot_password/forgot_password_controller.dart';
import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/theme.dart';
import 'package:opei/widgets/opei_premium/opei_premium.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onAnyChange);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _onAnyChange() {
    if (!mounted) return;
    setState(() {});
  }

  bool get _isFormValid {
    final email = _emailController.text.trim();
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();

    final success = await ref
        .read(forgotPasswordControllerProvider.notifier)
        .requestPasswordReset();

    if (success && mounted) {
      final email = ref.read(forgotPasswordControllerProvider).email;
      context.push('/reset-password?email=${Uri.encodeComponent(email)}');
    }
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(forgotPasswordControllerProvider);
    final isLoading = state.isLoading;

    final media = MediaQuery.of(context);
    final topPad = media.viewPadding.top;
    final bottomPad = media.viewPadding.bottom;

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
        backgroundColor: OpeiBrand.primary,
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
                                l10n.forgotPinEmailCodeTitle,
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
                              Text(
                                l10n.forgotPinEmailCodeSubtitle,
                                style: TextStyle(
                                  fontFamily: kPrimaryFontFamily,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: OpeiBrand.inkSecondary,
                                  letterSpacing: -0.1,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (state.errorMessage != null) ...[
                                _MessageBanner(
                                  message: state.errorMessage!,
                                  isError: true,
                                ),
                                const SizedBox(height: 16),
                              ],
                              if (state.successMessage != null) ...[
                                _MessageBanner(
                                  message: state.successMessage!,
                                  isError: false,
                                ),
                                const SizedBox(height: 16),
                              ],
                              OpeiTextField(
                                controller: _emailController,
                                focusNode: _emailFocusNode,
                                label: l10n.emailAddressLabel,
                                hint: l10n.emailAddressHint,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                enabled: !isLoading,
                                autofocus: true,
                                errorText: state.emailError,
                                prefix: const Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Icon(
                                    Icons.mail_outline_rounded,
                                    size: 18,
                                    color: OpeiBrand.inkTertiary,
                                  ),
                                ),
                                onChanged: (value) {
                                  ref
                                      .read(
                                        forgotPasswordControllerProvider
                                            .notifier,
                                      )
                                      .updateEmail(value);
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
                          20 + bottomPad,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OpeiPrimaryButton(
                              label: l10n.forgotPinSendCodeCta,
                              loading: isLoading,
                              onPressed: _isFormValid && !isLoading
                                  ? _handleSubmit
                                  : null,
                              trailingIcon: Icons.arrow_forward_rounded,
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              children: [
                                Text(
                                  l10n.forgotPinRememberedCta,
                                  style: TextStyle(
                                    fontFamily: kPrimaryFontFamily,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: OpeiBrand.inkSecondary,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _handleBack,
                                  child: Text(
                                    l10n.welcomeSignIn,
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
                          const _ResetProgress(stage: 0),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.forgotPinTitle,
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
                        l10n.forgotPinSubtitle,
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

/// 2-pill progress indicator for the forgot-PIN flow. Shared between this
/// screen and reset_password_screen.dart so both look identical.
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

class _MessageBanner extends StatelessWidget {
  final String message;
  final bool isError;

  const _MessageBanner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    final color = isError ? OpeiBrand.danger : OpeiBrand.success;
    final icon = isError
        ? Icons.error_outline_rounded
        : Icons.check_circle_outline_rounded;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(OpeiBrand.radiusField),
        border: Border.all(color: color.withValues(alpha: 0.18), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
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
