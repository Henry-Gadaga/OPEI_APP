import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:opei/features/auth/reset_password/reset_password_controller.dart';
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

  void _showSuccessSheet() {
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
            const Text(
              'PIN updated',
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
            const Text(
              'Your new 6-digit PIN is set. Sign in to continue.',
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
              label: 'Go to sign in',
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
    final state = ref.watch(resetPasswordControllerProvider(widget.email));
    final isLoading = state.isLoading;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: OpeiBrand.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: OpeiBrand.surfaceMuted,
        appBar: OpeiAppBar(
          backgroundColor: OpeiBrand.surfaceMuted,
          onBack: isLoading
              ? null
              : () =>
                  context.canPop() ? context.pop() : context.go('/login'),
          showBack: !isLoading,
        ),
        body: SafeArea(
          top: false,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reset your PIN',
                          style: TextStyle(
                            fontFamily: kPrimaryFontFamily,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            color: OpeiBrand.ink,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text.rich(
                          TextSpan(
                            text: 'Enter the 6-digit code we sent to ',
                            style: const TextStyle(
                              fontFamily: kPrimaryFontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: OpeiBrand.inkSecondary,
                              letterSpacing: -0.2,
                              height: 1.4,
                            ),
                            children: [
                              TextSpan(
                                text: widget.email,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: OpeiBrand.ink,
                                ),
                              ),
                              const TextSpan(
                                text: ' and choose a new 6-digit PIN.',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        if (state.errorMessage != null) ...[
                          _ErrorBanner(message: state.errorMessage!),
                          const SizedBox(height: 14),
                        ],
                        OpeiTextField(
                          controller: _codeController,
                          focusNode: _codeFocusNode,
                          label: 'Verification code',
                          hint: '6-digit code',
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
                          onChanged: (value) {
                            ref
                                .read(resetPasswordControllerProvider(
                                        widget.email)
                                    .notifier)
                                .updateCode(value);
                          },
                          onSubmitted: (_) =>
                              _newPasswordFocusNode.requestFocus(),
                        ),
                        const SizedBox(height: 14),
                        OpeiTextField(
                          controller: _newPasswordController,
                          focusNode: _newPasswordFocusNode,
                          label: 'New 6-digit PIN',
                          hint: '••••••',
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
                              () => _obscureNewPassword = !_obscureNewPassword,
                            ),
                          ),
                          onChanged: (value) {
                            ref
                                .read(resetPasswordControllerProvider(
                                        widget.email)
                                    .notifier)
                                .updateNewPassword(value);
                          },
                          onSubmitted: (_) =>
                              _confirmPasswordFocusNode.requestFocus(),
                        ),
                        const SizedBox(height: 14),
                        OpeiTextField(
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocusNode,
                          label: 'Confirm new PIN',
                          hint: '••••••',
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
                              ? "You'll use this to sign in and authorise payments."
                              : null,
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
                                .read(resetPasswordControllerProvider(
                                        widget.email)
                                    .notifier)
                                .updateConfirmPassword(value);
                          },
                          onSubmitted: (_) => _handleSubmit(),
                        ),
                      ],
                    ),
                  ),
                ),
                _BottomBar(
                  isLoading: isLoading,
                  enabled: _isFormValid && !isLoading,
                  onReset: _handleSubmit,
                  onResend: () =>
                      context.canPop() ? context.pop() : context.go('/login'),
                ),
              ],
            ),
          ),
        ),
      ),
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

class _BottomBar extends StatelessWidget {
  final bool isLoading;
  final bool enabled;
  final VoidCallback onReset;
  final VoidCallback onResend;

  const _BottomBar({
    required this.isLoading,
    required this.enabled,
    required this.onReset,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: OpeiBrand.surface,
        border: Border(top: BorderSide(color: OpeiBrand.hairline, width: 1)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        10 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OpeiPrimaryButton(
            label: 'Reset PIN',
            loading: isLoading,
            onPressed: enabled ? onReset : null,
            trailingIcon: Icons.arrow_forward_rounded,
          ),
          const SizedBox(height: 2),
          OpeiSecondaryLink(
            label: "Didn't get the code?",
            actionLabel: 'Request new',
            onTap: onResend,
          ),
        ],
      ),
    );
  }
}
