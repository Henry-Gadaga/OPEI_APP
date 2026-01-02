import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tt1/core/navigation/opei_page_transitions.dart';
import 'package:tt1/features/auth/signup/signup_controller.dart';
import 'package:tt1/features/auth/signup/signup_state.dart';
import 'package:tt1/features/auth/verify_email/verify_email_screen.dart';
import 'package:tt1/responsive/responsive_tokens.dart';
import 'package:tt1/responsive/responsive_widgets.dart';
import 'package:tt1/theme.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
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
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    setState(() {
      _emailError = null;
      _phoneError = null;
      _passwordError = null;
    });

    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      ref.read(signupControllerProvider.notifier).signup(
            email: _emailController.text,
            phone: _phoneController.text,
            password: _passwordController.text,
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

  String? _validatePassword(String? value) {
    if (_passwordError != null) return _passwordError;
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
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
            _passwordError = next.fieldErrors['password'];
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
            SizedBox(height: spacing * 3),
            Text(
              'Create account',
              style: theme.textTheme.displayLarge,
            ),
            SizedBox(height: spacing),
            Text(
              'Create your Opei profile to unlock seamless USD tools.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: OpeiColors.iosLabelSecondary,
              ),
            ),
            SizedBox(height: spacing * 3.5),
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
            SizedBox(height: spacing * 2.25),
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
            SizedBox(height: spacing * 2.25),
            Text(
              'Password',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: OpeiColors.grey700,
              ),
            ),
            SizedBox(height: spacing * 0.75),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              enabled: signupState is! SignupLoading,
              decoration: _buildInputDecoration(
                hint: 'Create a password',
                icon: Icons.lock_outline,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: OpeiColors.grey600,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              validator: _validatePassword,
              onChanged: (_) {
                if (_passwordError != null) {
                  setState(() => _passwordError = null);
                  _formKey.currentState!.validate();
                }
              },
              onFieldSubmitted: (_) => _handleSignup(),
            ),
            SizedBox(height: spacing * 1.25),
            Text(
              'Min. 8 characters with upper/lowercase, number and symbol.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: OpeiColors.iosLabelSecondary,
              ),
            ),
            SizedBox(height: spacing * 3.5),
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
            SizedBox(height: spacing * 2),
            Text(
              'Already have an account?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: OpeiColors.iosLabelSecondary,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/login'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                alignment: Alignment.centerLeft,
              ),
              child: Text(
                'Sign in instead',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: OpeiColors.pureBlack,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: spacing * 1.5),
            Text(
              'By continuing you agree to Opei’s Terms & Privacy Policy.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: OpeiColors.iosLabelSecondary,
              ),
            ),
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
            padding: EdgeInsets.symmetric(vertical: spacing * 4),
            child: buildForm(),
          ),
          if (signupState is SignupLoading)
            const ModalBarrier(
              color: Colors.transparent,
              dismissible: false,
            ),
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
}
