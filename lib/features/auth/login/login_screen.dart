import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:opei/core/providers/providers.dart';
import 'package:opei/features/auth/login/login_controller.dart';
import 'package:opei/theme.dart';
import 'package:opei/widgets/opei_premium/opei_premium.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _pinFocusNode = FocusNode();
  bool _obscurePin = true;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onAnyChange);
    _pinController.addListener(_onAnyChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(loginControllerProvider);
      _emailController.clear();
      _pinController.clear();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pinController.dispose();
    _emailFocusNode.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  void _onAnyChange() {
    if (!mounted) return;
    setState(() {});
  }

  bool get _isFormValid {
    final email = _emailController.text.trim();
    final pin = _pinController.text;
    final emailOk = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    final pinOk = RegExp(r'^\d{6}$').hasMatch(pin);
    return emailOk && pinOk;
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    final result = await ref.read(loginControllerProvider.notifier).login();

    if (!mounted) return;

    if (result == null) {
      final loginState = ref.read(loginControllerProvider);
      if (loginState.errorMessage ==
          'Invalid email or PIN. Please try again.') {
        _pinController.clear();
        ref.read(loginControllerProvider.notifier).resetPasswordField();
        _pinFocusNode.requestFocus();
      }
      return;
    }

    if (result['success'] == true) {
      final userStage = result['userStage'] as String?;

      switch (userStage) {
        case 'PENDING_EMAIL':
          context.go('/verify-email?autoSend=true');
          return;
        case 'PENDING_ADDRESS':
          context.go('/address');
          return;
        case 'PENDING_KYC':
          context.go('/kyc');
          return;
        case 'VERIFIED':
          await _handleVerifiedUserNavigation();
          return;
        default:
          context.go('/verify-email?autoSend=true');
          return;
      }
    }
  }

  Future<void> _handleVerifiedUserNavigation() async {
    final quickAuthService = ref.read(quickAuthServiceProvider);
    final storage = ref.read(secureStorageServiceProvider);
    final quickAuthStatusNotifier = ref.read(quickAuthStatusProvider.notifier);

    final user = await storage.getUser();
    var userIdentifier = user?.id;
    userIdentifier ??= await quickAuthService.getRegisteredUserId();

    if (userIdentifier == null) {
      debugPrint('⚠️ No user identifier found for quick auth setup check');
      if (!mounted) return;
      quickAuthStatusNotifier.setStatus(QuickAuthStatus.satisfied);
      context.go('/dashboard');
      return;
    }

    try {
      final hasPin = await quickAuthService.hasPinSetup(userIdentifier);
      if (hasPin) {
        await quickAuthService.markSetupCompleted(userIdentifier);
      }
    } catch (e) {
      debugPrint('⚠️ Failed to sync quick auth completion state: $e');
    }

    quickAuthStatusNotifier.setStatus(QuickAuthStatus.satisfied);
    if (!mounted) return;
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
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
          onBack: () => context.go('/welcome'),
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
                          'Welcome back',
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
                          'Sign in with your email and 6-digit PIN.',
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
                          _ErrorBanner(message: state.errorMessage!),
                          const SizedBox(height: 14),
                        ],
                        OpeiTextField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          label: 'Email address',
                          hint: 'name@example.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          enabled: !isLoading,
                          errorText: state.emailError,
                          onChanged: (value) {
                            ref
                                .read(loginControllerProvider.notifier)
                                .updateEmail(value);
                          },
                          onSubmitted: (_) => _pinFocusNode.requestFocus(),
                        ),
                        const SizedBox(height: 14),
                        OpeiTextField(
                          controller: _pinController,
                          focusNode: _pinFocusNode,
                          label: '6-digit PIN',
                          hint: '••••••',
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          enabled: !isLoading,
                          errorText: state.passwordError,
                          obscureText: _obscurePin,
                          maxLength: 6,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          suffix: IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            splashRadius: 16,
                            icon: Icon(
                              _obscurePin
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: OpeiBrand.inkTertiary,
                              size: 18,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePin = !_obscurePin),
                          ),
                          onChanged: (value) {
                            ref
                                .read(loginControllerProvider.notifier)
                                .updatePassword(value);
                          },
                          onSubmitted: (_) => _handleLogin(),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: isLoading
                                ? null
                                : () => context.push('/forgot-password'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: OpeiBrand.primary,
                            ),
                            child: const Text(
                              'Forgot PIN?',
                              style: TextStyle(
                                fontFamily: kPrimaryFontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: OpeiBrand.primary,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _BottomBar(
                  isLoading: isLoading,
                  enabled: _isFormValid && !isLoading,
                  onSignIn: _handleLogin,
                  onCreateAccount: () => context.go('/signup'),
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
  final VoidCallback onSignIn;
  final VoidCallback onCreateAccount;

  const _BottomBar({
    required this.isLoading,
    required this.enabled,
    required this.onSignIn,
    required this.onCreateAccount,
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
            label: 'Sign in',
            loading: isLoading,
            onPressed: enabled ? onSignIn : null,
            trailingIcon: Icons.arrow_forward_rounded,
          ),
          const SizedBox(height: 2),
          OpeiSecondaryLink(
            label: 'New to Opei?',
            actionLabel: 'Create account',
            onTap: onCreateAccount,
          ),
        ],
      ),
    );
  }
}
