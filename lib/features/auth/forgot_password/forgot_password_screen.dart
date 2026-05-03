import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:opei/features/auth/forgot_password/forgot_password_controller.dart';
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordControllerProvider);
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
          onBack: () =>
              context.canPop() ? context.pop() : context.go('/login'),
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
                          'Forgot your PIN?',
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
                        const Text(
                          "Enter your email and we'll send you a code to reset it.",
                          style: TextStyle(
                            fontFamily: kPrimaryFontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: OpeiBrand.inkSecondary,
                            letterSpacing: -0.2,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 22),
                        if (state.errorMessage != null) ...[
                          _MessageBanner(
                            message: state.errorMessage!,
                            isError: true,
                          ),
                          const SizedBox(height: 14),
                        ],
                        if (state.successMessage != null) ...[
                          _MessageBanner(
                            message: state.successMessage!,
                            isError: false,
                          ),
                          const SizedBox(height: 14),
                        ],
                        OpeiTextField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          label: 'Email address',
                          hint: 'name@example.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          enabled: !isLoading,
                          autofocus: true,
                          errorText: state.emailError,
                          onChanged: (value) {
                            ref
                                .read(forgotPasswordControllerProvider.notifier)
                                .updateEmail(value);
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
                  onSendCode: _handleSubmit,
                  onSignIn: () =>
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

class _MessageBanner extends StatelessWidget {
  final String message;
  final bool isError;

  const _MessageBanner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    final color = isError ? OpeiBrand.danger : OpeiBrand.success;
    final icon = isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded;
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

class _BottomBar extends StatelessWidget {
  final bool isLoading;
  final bool enabled;
  final VoidCallback onSendCode;
  final VoidCallback onSignIn;

  const _BottomBar({
    required this.isLoading,
    required this.enabled,
    required this.onSendCode,
    required this.onSignIn,
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
            label: 'Send code',
            loading: isLoading,
            onPressed: enabled ? onSendCode : null,
            trailingIcon: Icons.arrow_forward_rounded,
          ),
          const SizedBox(height: 2),
          OpeiSecondaryLink(
            label: 'Remembered it?',
            actionLabel: 'Sign in',
            onTap: onSignIn,
          ),
        ],
      ),
    );
  }
}
