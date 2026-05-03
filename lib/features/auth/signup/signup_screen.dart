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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: OpeiBrand.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        // Subtle off-white scaffold creates depth against pure-white fields —
        // standard "bank app" feel (Revolut / Monzo / N26).
        backgroundColor: OpeiBrand.surfaceMuted,
        appBar: OpeiAppBar(
          backgroundColor: OpeiBrand.surfaceMuted,
          currentStep: 1,
          totalSteps: 4,
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
                          'Create your account',
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
                          "It takes less than a minute. We'll send a code to verify your email.",
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
                                selection:
                                    TextSelection.collapsed(offset: v.length),
                              );
                            }
                          },
                          onSubmitted: (_) => _pinFocus.requestFocus(),
                        ),
                        const SizedBox(height: 14),
                        OpeiTextField(
                          controller: _pinController,
                          focusNode: _pinFocus,
                          label: 'Create 6-digit PIN',
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
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                _BottomBar(
                  isLoading: isLoading,
                  enabled: _isFormValid && !isLoading,
                  onContinue: _handleSignup,
                  onSignIn: () => context.go('/login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final bool isLoading;
  final bool enabled;
  final VoidCallback onContinue;
  final VoidCallback onSignIn;

  const _BottomBar({
    required this.isLoading,
    required this.enabled,
    required this.onContinue,
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
            label: 'Continue',
            loading: isLoading,
            onPressed: enabled ? onContinue : null,
            trailingIcon: Icons.arrow_forward_rounded,
          ),
          const SizedBox(height: 2),
          OpeiSecondaryLink(
            label: 'Already have an account?',
            actionLabel: 'Sign in',
            onTap: onSignIn,
          ),
        ],
      ),
    );
  }
}
