import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opei/core/navigation/opei_page_transitions.dart';
import 'package:opei/features/auth/signup/signup_controller.dart';
import 'package:opei/features/auth/signup/signup_state.dart';
import 'package:opei/features/auth/verify_email/verify_email_screen.dart';
import 'package:opei/responsive/responsive_tokens.dart';
import 'package:opei/responsive/responsive_widgets.dart';
import 'package:opei/theme.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();

  bool _obscurePin = true;
  String? _emailError;
  String? _phoneError;
  String? _pinError;
  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: OpeiColors.pureWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIcon: Icon(icon, size: 18, color: OpeiColors.grey600),
      prefixIconConstraints: const BoxConstraints(minWidth: 44),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: OpeiColors.grey200, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: OpeiColors.grey200, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: OpeiColors.pureBlack, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: OpeiColors.errorRed, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: OpeiColors.errorRed, width: 1.4),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    setState(() {
      _emailError = null;
      _phoneError = null;
      _pinError = null;
    });

    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      ref
          .read(signupControllerProvider.notifier)
          .signup(
            email: _emailController.text,
            phone: _phoneController.text,
            pin: _pinController.text,
          );
    }
  }

  String? _validateEmail(String? value) {
    if (_emailError != null) return _emailError;
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (_phoneError != null) return _phoneError;
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length > 20) {
      return 'Phone number must be less than 20 characters';
    }
    return null;
  }

  String? _validatePin(String? value) {
    if (_pinError != null) return _pinError;
    if (value == null || value.isEmpty) {
      return 'PIN is required';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'PIN must be exactly 6 digits';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final signupState = ref.watch(signupControllerProvider);

    ref.listen<SignupState>(signupControllerProvider, (previous, next) {
      if (next is SignupSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created! Please verify your email.'),
            backgroundColor: OpeiColors.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );

        Navigator.of(context).push(
          OpeiPageRoute(
            builder: (_) =>
                VerifyEmailScreen(email: _emailController.text.trim()),
          ),
        );
      } else if (next is SignupError) {
        if (next.fieldErrors.isNotEmpty) {
          setState(() {
            _emailError = next.fieldErrors['email'];
            _phoneError = next.fieldErrors['phone'];
            _pinError = next.fieldErrors['pin'] ?? next.fieldErrors['password'];
          });
          _formKey.currentState!.validate();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.message),
              backgroundColor: OpeiColors.errorRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          );
        }
      }
    });

    final theme = Theme.of(context);
    final spacing = context.responsiveSpacingUnit;
    final tokens = context.responsiveTokens;

    Widget buildForm() {
      return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: spacing * 0.5),
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: OpeiColors.pureBlack,
                    size: 20,
                  ),
                  onPressed: () => context.go('/login'),
                  tooltip: 'Back',
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Create account',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing * 2),
            Text(
              'Email',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: OpeiColors.grey700,
              ),
            ),
            SizedBox(height: spacing * 0.75),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              enabled: signupState is! SignupLoading,
              decoration: _buildInputDecoration(
                hint: 'name@example.com',
                icon: Icons.email_outlined,
              ),
              validator: _validateEmail,
              onChanged: (_) {
                if (_emailError != null) {
                  setState(() => _emailError = null);
                  _formKey.currentState!.validate();
                }
              },
            ),
            SizedBox(height: spacing * 1.5),
            Text(
              'Phone number',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: OpeiColors.grey700,
              ),
            ),
            SizedBox(height: spacing * 0.75),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              enabled: signupState is! SignupLoading,
              decoration: _buildInputDecoration(
                hint: '+1 234 567 8900',
                icon: Icons.phone_outlined,
              ),
              validator: _validatePhone,
              onChanged: (_) {
                if (_phoneError != null) {
                  setState(() => _phoneError = null);
                  _formKey.currentState!.validate();
                }
              },
            ),
            SizedBox(height: spacing * 1.5),
            Text(
              'PIN',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: OpeiColors.grey700,
              ),
            ),
            SizedBox(height: spacing * 0.75),
            TextFormField(
              controller: _pinController,
              obscureText: _obscurePin,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              enabled: signupState is! SignupLoading,
              decoration: _buildInputDecoration(
                hint: 'Create 6-digit PIN',
                icon: Icons.pin_outlined,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePin
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: OpeiColors.grey600,
                  ),
                  onPressed: () {
                    setState(() => _obscurePin = !_obscurePin);
                  },
                ),
              ),
              validator: _validatePin,
              onChanged: (_) {
                if (_pinError != null) {
                  setState(() => _pinError = null);
                  _formKey.currentState!.validate();
                }
              },
              onFieldSubmitted: (_) => _handleSignup(),
            ),
            SizedBox(height: spacing),
            Text(
              'Use a 6-digit numeric PIN.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: OpeiColors.iosLabelSecondary,
              ),
            ),
            SizedBox(height: spacing * 2.25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: signupState is SignupLoading ? null : _handleSignup,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(tokens.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Create account'),
              ),
            ),
            SizedBox(height: spacing * 1.5),
            Text(
              'Already have an account?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: OpeiColors.iosLabelSecondary,
              ),
            ),
            SizedBox(height: spacing * 0.5),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.go('/login'),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.fromHeight(tokens.buttonHeight),
                  side: const BorderSide(
                    color: OpeiColors.pureBlack,
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Sign in instead'),
              ),
            ),
            SizedBox(height: spacing * 1.5),
            _buildLegalText(theme),
            SizedBox(height: spacing * 3),
          ],
        ),
      );
    }

    return ResponsiveScaffold(
      backgroundColor: OpeiColors.pureWhite,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: spacing * 2),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
                child: buildForm(),
              ),
            ),
          ),
          if (signupState is SignupLoading)
            const ModalBarrier(color: Colors.transparent, dismissible: false),
          if (signupState is SignupLoading)
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      strokeWidth: 3,
                      color: OpeiColors.pureBlack,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Creating your account...',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegalText(ThemeData theme) {
    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodySmall?.copyWith(
          color: OpeiColors.iosLabelSecondary,
        ),
        children: [
          const TextSpan(text: 'By continuing you agree to Opei\'s '),
          WidgetSpan(
            child: GestureDetector(
              onTap: () => context.push('/terms'),
              child: Text(
                'Terms',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: OpeiColors.pureBlack,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const TextSpan(text: ' & '),
          WidgetSpan(
            child: GestureDetector(
              onTap: () => context.push('/privacy'),
              child: Text(
                'Privacy Policy',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: OpeiColors.pureBlack,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}
