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
    final media = MediaQuery.of(context);
    final topPad = media.viewPadding.top;
    final bottomPad = media.viewPadding.bottom;

    const headerContentHeight = 200.0;
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
              // ── Gradient header with decorative blobs ───────────
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
                      // Decorative top-right glow
                      Positioned(
                        top: -60,
                        right: -50,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.10),
                          ),
                        ),
                      ),
                      // Decorative bottom-left glow
                      Positioned(
                        bottom: -40,
                        left: -30,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Form card panel (elevated) ──────────────────────
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
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(24, 28, 24, 24 + bottomPad),
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Welcome line inside card
                        const Text(
                          'Welcome back',
                          style: TextStyle(
                            fontFamily: kPrimaryFontFamily,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: OpeiBrand.ink,
                            letterSpacing: -0.4,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Sign in to continue to your account',
                          style: TextStyle(
                            fontFamily: kPrimaryFontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: OpeiBrand.inkSecondary,
                            letterSpacing: -0.1,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 24),

                        if (state.errorMessage != null) ...[
                          _ErrorBanner(message: state.errorMessage!),
                          const SizedBox(height: 20),
                        ],

                        // Email field
                        const _FieldLabel(text: 'Email address'),
                        const SizedBox(height: 8),
                        OpeiTextField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          label: '',
                          hint: 'name@example.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          enabled: !isLoading,
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
                                .read(loginControllerProvider.notifier)
                                .updateEmail(value);
                          },
                          onSubmitted: (_) => _pinFocusNode.requestFocus(),
                        ),

                        const SizedBox(height: 18),

                        // PIN field
                        Row(
                          children: [
                            const Expanded(
                              child: _FieldLabel(text: '6-digit PIN'),
                            ),
                            GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () => context.push('/forgot-password'),
                              child: const Text(
                                'Forgot PIN?',
                                style: TextStyle(
                                  fontFamily: kPrimaryFontFamily,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: OpeiBrand.primary,
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        OpeiTextField(
                          controller: _pinController,
                          focusNode: _pinFocusNode,
                          label: '',
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

                        const SizedBox(height: 28),
                        OpeiPrimaryButton(
                          label: 'Sign in',
                          loading: isLoading,
                          onPressed:
                              _isFormValid && !isLoading ? _handleLogin : null,
                          trailingIcon: Icons.arrow_forward_rounded,
                        ),

                        const SizedBox(height: 22),
                        // Divider with "or"
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: OpeiBrand.hairline,
                                thickness: 1,
                                height: 1,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'or',
                                style: TextStyle(
                                  fontFamily: kPrimaryFontFamily,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: OpeiBrand.inkTertiary,
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                color: OpeiBrand.hairline,
                                thickness: 1,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Create account secondary CTA
                        SizedBox(
                          height: 54,
                          child: OutlinedButton(
                            onPressed: isLoading
                                ? null
                                : () => context.go('/signup'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: OpeiBrand.ink,
                              side: const BorderSide(
                                color: OpeiBrand.hairlineStrong,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  OpeiBrand.radiusCta,
                                ),
                              ),
                            ),
                            child: const Text(
                              'Create new account',
                              style: TextStyle(
                                fontFamily: kPrimaryFontFamily,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Brand header content ────────────────────────────
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
                      const SizedBox(height: 32),
                      const Text(
                        'Sign in',
                        style: TextStyle(
                          fontFamily: kPrimaryFontFamily,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.6,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Access your Opei account securely.',
                        style: TextStyle(
                          fontFamily: kPrimaryFontFamily,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.82),
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

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: kPrimaryFontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: OpeiBrand.ink,
        letterSpacing: -0.1,
      ),
    );
  }
}

class _SecurityBadge extends StatelessWidget {
  const _SecurityBadge();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.shield_outlined,
          size: 13,
          color: OpeiBrand.inkTertiary,
        ),
        SizedBox(width: 6),
        Text(
          '256-bit encryption · Bank-level security',
          style: TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: OpeiBrand.inkTertiary,
            letterSpacing: 0.0,
          ),
        ),
      ],
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

