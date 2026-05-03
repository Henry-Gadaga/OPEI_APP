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
import 'package:opei/widgets/opei_premium/opei_premium.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailController = TextEditingController();
  final _localPhoneController = TextEditingController();
  final _pinController = TextEditingController();

  final _emailFocus = FocusNode();
  final _pinFocus = FocusNode();

  // Country picked for the phone number; defaults to Nigeria.
  String _phoneIso = kDefaultDialIso;

  bool _obscurePin = true;

  String? _emailError;
  String? _phoneError;
  String? _pinError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onAnyChange);
    _localPhoneController.addListener(_onAnyChange);
    _pinController.addListener(_onAnyChange);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _localPhoneController.dispose();
    _pinController.dispose();
    _emailFocus.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  void _onAnyChange() {
    // Always rebuild so the bottom CTA reflects current form validity in
    // real time (without waiting for the user to dismiss the keyboard).
    if (!mounted) return;
    setState(() {
      if (_emailError != null &&
          _validateEmail(_emailController.text) == null) {
        _emailError = null;
      }
      if (_phoneError != null && _validatePhone() == null) {
        _phoneError = null;
      }
      if (_pinError != null && _validatePin(_pinController.text) == null) {
        _pinError = null;
      }
    });
  }

  bool get _isFormValid =>
      _validateEmail(_emailController.text) == null &&
      _validatePhone() == null &&
      _validatePin(_pinController.text) == null;

  String? _validateEmail(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(v)) return 'Please enter a valid email';
    return null;
  }

  String? _validatePhone() {
    return OpeiPhoneField.validate(_phoneIso, _localPhoneController.text);
  }

  String? _validatePin(String value) {
    if (value.isEmpty) return 'PIN is required';
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'PIN must be exactly 6 digits';
    }
    return null;
  }

  void _handleSignup() {
    setState(() {
      _emailError = _validateEmail(_emailController.text.trim());
      _phoneError = _validatePhone();
      _pinError = _validatePin(_pinController.text);
    });

    if (_emailError != null || _phoneError != null || _pinError != null) {
      return;
    }

    FocusScope.of(context).unfocus();
    final fullPhone =
        OpeiPhoneField.e164(_phoneIso, _localPhoneController.text);
    ref.read(signupControllerProvider.notifier).signup(
          email: _emailController.text.trim(),
          phone: fullPhone,
          pin: _pinController.text,
        );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: OpeiBrand.danger,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupControllerProvider);
    final isLoading = state is SignupLoading;

    ref.listen<SignupState>(signupControllerProvider, (previous, next) {
      if (next is SignupSuccess) {
        Navigator.of(context).push(
          OpeiPageRoute(
            builder: (_) =>
                VerifyEmailScreen(email: _emailController.text.trim()),
          ),
        );
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
        } else {
          _showError(next.message);
        }
      }
    });

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: OpeiBrand.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: OpeiBrand.surface,
        resizeToAvoidBottomInset: false,
        appBar: OpeiAppBar(
          backgroundColor: OpeiBrand.surface,
          onBack: () => context.go('/welcome'),
        ),
        body: SafeArea(
          top: false,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.opaque,
            child: AnimatedPadding(
              duration: OpeiBrand.motionFast,
              curve: OpeiBrand.motionCurve,
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Progress strip ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 2, 24, 0),
                    child: Row(
                      children: List.generate(4, (i) {
                        return Expanded(
                          child: AnimatedContainer(
                            duration: OpeiBrand.motion,
                            curve: OpeiBrand.motionCurve,
                            height: 3,
                            margin: EdgeInsets.only(right: i < 3 ? 5 : 0),
                            decoration: BoxDecoration(
                              color: i == 0
                                  ? OpeiBrand.primary
                                  : OpeiBrand.hairline,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // ── Scrollable content ──────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title block
                          const Text(
                            'Create your\naccount',
                            style: TextStyle(
                              fontFamily: kPrimaryFontFamily,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.0,
                              color: OpeiBrand.ink,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "We'll send a code to verify your email.",
                            style: TextStyle(
                              fontFamily: kPrimaryFontFamily,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w400,
                              color: OpeiBrand.inkSecondary,
                              letterSpacing: -0.1,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Form fields
                          OpeiTextField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            label: 'Email address',
                            hint: 'name@example.com',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            enabled: !isLoading,
                            errorText: _emailError,
                            onSubmitted: (_) =>
                                FocusScope.of(context).nextFocus(),
                          ),
                          const SizedBox(height: 14),
                          OpeiPhoneField(
                            label: 'Phone number',
                            enabled: !isLoading,
                            selectedIso: _phoneIso,
                            localNumber: _localPhoneController.text,
                            errorText: _phoneError,
                            onIsoChanged: (iso) {
                              setState(() {
                                _phoneIso = iso;
                                _phoneError = null;
                              });
                            },
                            onLocalNumberChanged: (v) {
                              if (_localPhoneController.text != v) {
                                _localPhoneController.value =
                                    _localPhoneController.value.copyWith(
                                  text: v,
                                  selection: TextSelection.collapsed(
                                    offset: v.length,
                                  ),
                                );
                              }
                            },
                            onSubmitted: (_) => _pinFocus.requestFocus(),
                          ),
                          const SizedBox(height: 14),
                          OpeiTextField(
                            controller: _pinController,
                            focusNode: _pinFocus,
                            label: '6-digit PIN',
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
                            helperText: _pinError == null
                                ? 'Used to sign in and authorise payments.'
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
                                _obscurePin
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: OpeiBrand.inkTertiary,
                                size: 18,
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePin = !_obscurePin),
                            ),
                            onSubmitted: (_) => _handleSignup(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── CTA area — seamless, no container box ───────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 16, 24, 20 + bottomPad),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OpeiPrimaryButton(
                          label: 'Continue',
                          loading: isLoading,
                          onPressed: _isFormValid && !isLoading
                              ? _handleSignup
                              : null,
                          trailingIcon: Icons.arrow_forward_rounded,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                            const SizedBox(width: 4),
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

