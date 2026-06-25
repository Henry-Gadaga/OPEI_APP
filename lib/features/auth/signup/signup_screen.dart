import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:opei/core/constants/country_dial_codes.dart';
import 'package:opei/core/navigation/opei_page_transitions.dart';
import 'package:opei/features/auth/signup/signup_controller.dart';
import 'package:opei/features/auth/signup/signup_state.dart';
import 'package:opei/features/auth/verify_email/verify_email_screen.dart';
import 'package:opei/theme.dart';
import 'package:opei/widgets/onboarding/onboarding_progress.dart';
import 'package:opei/widgets/opei_premium/opei_premium.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen>
    with SingleTickerProviderStateMixin {
  // ── Step tracking ─────────────────────────────────────────────────────
  int _step = 0; // 0 = email, 1 = phone, 2 = PIN

  // ── Controllers ───────────────────────────────────────────────────────
  final _emailController = TextEditingController();
  final _localPhoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _pinFocus = FocusNode();

  String _phoneIso = kDefaultDialIso;
  bool _obscurePin = true;

  String? _emailError;
  String? _phoneError;
  String? _pinError;

  // ── Step metadata ─────────────────────────────────────────────────────
  // Title stays constant across all sub-steps so the flow feels like ONE
  // continuous stage. The subtitle gives gentle context.
  static const _subtitles = [
    "Let's start with your email.",
    "Now your phone number.",
    "Choose a 6-digit PIN.",
  ];

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_rebuild);
    _localPhoneController.addListener(_rebuild);
    _pinController.addListener(_rebuild);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _localPhoneController.dispose();
    _pinController.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  // ── Validation ────────────────────────────────────────────────────────
  String? _validateEmail(String v) {
    final t = v.trim();
    if (t.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(t)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePhone() =>
      OpeiPhoneField.validate(_phoneIso, _localPhoneController.text);

  String? _validatePin(String v) {
    if (v.isEmpty) return 'PIN is required';
    if (!RegExp(r'^\d{6}$').hasMatch(v)) return 'PIN must be exactly 6 digits';
    return null;
  }

  bool get _currentStepValid {
    if (_step == 0) return _validateEmail(_emailController.text) == null;
    if (_step == 1) return _validatePhone() == null;
    return _validatePin(_pinController.text) == null;
  }

  // ── Navigation ────────────────────────────────────────────────────────
  void _back() {
    FocusScope.of(context).unfocus();
    if (_step == 0) {
      context.go('/welcome');
    } else {
      setState(() => _step--);
    }
  }

  void _next(bool isLoading) {
    if (isLoading) return;
    FocusScope.of(context).unfocus();

    if (_step == 0) {
      final err = _validateEmail(_emailController.text);
      if (err != null) { setState(() => _emailError = err); return; }
      setState(() { _emailError = null; _step = 1; });
      Future.delayed(const Duration(milliseconds: 120),
          () => _phoneFocus.requestFocus());
    } else if (_step == 1) {
      final err = _validatePhone();
      if (err != null) { setState(() => _phoneError = err); return; }
      setState(() { _phoneError = null; _step = 2; });
      Future.delayed(const Duration(milliseconds: 120),
          () => _pinFocus.requestFocus());
    } else {
      final err = _validatePin(_pinController.text);
      if (err != null) { setState(() => _pinError = err); return; }
      setState(() => _pinError = null);
      final fullPhone =
          OpeiPhoneField.e164(_phoneIso, _localPhoneController.text);
      ref.read(signupControllerProvider.notifier).signup(
            email: _emailController.text.trim(),
            phone: fullPhone,
            pin: _pinController.text,
          );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, maxLines: 4, overflow: TextOverflow.ellipsis),
        backgroundColor: OpeiBrand.danger,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OpeiBrand.radiusCard)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupControllerProvider);
    final isLoading = state is SignupLoading;

    ref.listen<SignupState>(signupControllerProvider, (_, next) {
      if (next is SignupSuccess) {
        Navigator.of(context).push(OpeiPageRoute(
          builder: (_) =>
              VerifyEmailScreen(email: _emailController.text.trim()),
        ));
      } else if (next is SignupError) {
        if (next.fieldErrors.isNotEmpty) {
          setState(() {
            _emailError = next.fieldErrors['email'] ?? _emailError;
            _phoneError = next.fieldErrors['phone'] ??
                next.fieldErrors['phoneNumber'] ??
                _phoneError;
            _pinError = next.fieldErrors['pin'] ??
                next.fieldErrors['password'] ??
                _pinError;
          });
          // Jump back to the step that has an error
          if (next.fieldErrors.containsKey('email')) {
            setState(() => _step = 0);
          } else if (next.fieldErrors.containsKey('phone') ||
              next.fieldErrors.containsKey('phoneNumber')) {
            setState(() => _step = 1);
          }
        } else {
          _showError(next.message);
        }
      }
    });

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
              // ── Gradient header ────────────────────────────────────
              Positioned(
                top: 0, left: 0, right: 0,
                height: headerHeight,
                child: ClipRect(
                  child: Stack(children: [
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
                      top: -60, right: -50,
                      child: Container(
                        width: 200, height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.09),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -40, left: -30,
                      child: Container(
                        width: 140, height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),

              // ── White form panel ───────────────────────────────────
              Positioned(
                top: headerHeight - panelOverlap,
                left: 0, right: 0, bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: OpeiBrand.surface,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
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
                    child: AnimatedSwitcher(
                      duration: kOpeiForwardTransitionDuration,
                      reverseDuration: kOpeiReverseTransitionDuration,
                      switchInCurve: kOpeiTransitionCurve,
                      switchOutCurve: kOpeiTransitionCurve,
                      layoutBuilder: (current, previous) => Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          ...previous,
                          if (current != null) current,
                        ],
                      ),
                      transitionBuilder: (child, anim) =>
                          buildOpeiPageTransition(
                        context,
                        anim,
                        const AlwaysStoppedAnimation(0),
                        child,
                      ),
                      child: KeyedSubtree(
                        key: ValueKey(_step),
                        child: _buildStepContent(isLoading, bottomPad),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Header content ─────────────────────────────────────
              Positioned(
                top: topPad, left: 0, right: 0,
                height: headerContentHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Back + step counter row
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _back,
                            child: Container(
                              width: 36, height: 36,
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
                          const OnboardingProgress(
                            stage: OnboardingStage.account,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Create account',
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
                      AnimatedSwitcher(
                        duration: kOpeiForwardTransitionDuration,
                        reverseDuration: kOpeiReverseTransitionDuration,
                        switchInCurve: kOpeiTransitionCurve,
                        switchOutCurve: kOpeiTransitionCurve,
                        transitionBuilder: (child, anim) =>
                            buildOpeiPageTransition(
                          context,
                          anim,
                          const AlwaysStoppedAnimation(0),
                          child,
                        ),
                        child: Text(
                          _subtitles[_step],
                          key: ValueKey(_step),
                          style: TextStyle(
                            fontFamily: kPrimaryFontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
                            letterSpacing: -0.1,
                            height: 1.35,
                          ),
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

  Widget _buildStepContent(bool isLoading, double bottomPad) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Field ──────────────────────────────────────────────────────
        if (_step == 0) ...[
          const _FieldLabel(text: 'Email address'),
          const SizedBox(height: 8),
          OpeiTextField(
            controller: _emailController,
            focusNode: _emailFocus,
            label: '',
            hint: 'name@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            enabled: !isLoading,
            errorText: _emailError,
            prefix: const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.mail_outline_rounded,
                  size: 18, color: OpeiBrand.inkTertiary),
            ),
            onChanged: (_) {
              if (_emailError != null) setState(() => _emailError = null);
            },
            onSubmitted: (_) => _next(isLoading),
          ),
        ] else if (_step == 1) ...[
          const _FieldLabel(text: 'Phone number'),
          const SizedBox(height: 8),
          OpeiPhoneField(
            label: '',
            enabled: !isLoading,
            selectedIso: _phoneIso,
            localNumber: _localPhoneController.text,
            errorText: _phoneError,
            onIsoChanged: (iso) =>
                setState(() { _phoneIso = iso; _phoneError = null; }),
            onLocalNumberChanged: (v) {
              if (_localPhoneController.text != v) {
                _localPhoneController.value =
                    _localPhoneController.value.copyWith(
                  text: v,
                  selection: TextSelection.collapsed(offset: v.length),
                );
              }
              if (_phoneError != null) setState(() => _phoneError = null);
            },
            onSubmitted: (_) => _next(isLoading),
          ),
        ] else ...[
          const _FieldLabel(text: '6-digit PIN'),
          const SizedBox(height: 8),
          OpeiTextField(
            controller: _pinController,
            focusNode: _pinFocus,
            label: '',
            hint: '••••••',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            enabled: !isLoading,
            errorText: _pinError,
            obscureText: _obscurePin,
            maxLength: 6,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            prefix: const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.lock_outline_rounded,
                  size: 18, color: OpeiBrand.inkTertiary),
            ),
            suffix: IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints:
                  const BoxConstraints(minWidth: 32, minHeight: 32),
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
            onChanged: (_) {
              if (_pinError != null) setState(() => _pinError = null);
            },
            onSubmitted: (_) => _next(isLoading),
          ),
          const SizedBox(height: 8),
          const Text(
            'Keep this safe — it authorises all your payments.',
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: OpeiBrand.inkTertiary,
              letterSpacing: -0.1,
              height: 1.4,
            ),
          ),
        ],

        const SizedBox(height: 32),

        // ── Primary CTA ────────────────────────────────────────────────
        OpeiPrimaryButton(
          label: _step < 2 ? 'Continue' : 'Create account',
          loading: isLoading,
          onPressed: _currentStepValid && !isLoading
              ? () => _next(isLoading)
              : null,
          trailingIcon: _step < 2
              ? Icons.arrow_forward_rounded
              : Icons.check_rounded,
        ),

        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: [
            const Text(
              'Already have an account?',
              style: TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: OpeiBrand.inkSecondary,
                letterSpacing: -0.1,
              ),
            ),
            GestureDetector(
              onTap: () => context.go('/login'),
              child: const Text(
                'Sign in',
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

