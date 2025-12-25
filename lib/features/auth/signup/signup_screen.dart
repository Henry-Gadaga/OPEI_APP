import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tt1/core/navigation/opei_page_transitions.dart';
import 'package:tt1/features/auth/signup/signup_controller.dart';
import 'package:tt1/features/auth/signup/signup_state.dart';
import 'package:tt1/features/auth/verify_email/verify_email_screen.dart';
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
            builder: (_) => VerifyEmailScreen(email: _emailController.text.trim()),
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

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 36),
                    
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.displayLarge,
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Join Opei to start managing your finances',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: OpeiColors.grey600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Text(
                      'Email',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: OpeiColors.grey700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: signupState is! SignupLoading,
                      decoration: const InputDecoration(
                        hintText: 'name@example.com',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      validator: _validateEmail,
                      onChanged: (_) {
                        if (_emailError != null) {
                          setState(() => _emailError = null);
                          _formKey.currentState!.validate();
                        }
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Text(
                      'Phone Number',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: OpeiColors.grey700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      enabled: signupState is! SignupLoading,
                      decoration: const InputDecoration(
                        hintText: '+1 234 567 8900',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      validator: _validatePhone,
                      onChanged: (_) {
                        if (_phoneError != null) {
                          setState(() => _phoneError = null);
                          _formKey.currentState!.validate();
                        }
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Text(
                      'Password',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: OpeiColors.grey700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      enabled: signupState is! SignupLoading,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: OpeiColors.grey600,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
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
                    
                    const SizedBox(height: 10),
                    
                    Text(
                      'Must be at least 8 characters with uppercase, lowercase, number, and special character',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: OpeiColors.grey600,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: signupState is SignupLoading
                            ? null
                            : _handleSignup,
                        child: const Text('Continue'),
                      ),
                    ),
                    
                    const SizedBox(height: 26),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: OpeiColors.grey600,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Login',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: OpeiColors.pureBlack,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
            if (signupState is SignupLoading)
              Container(
                color: OpeiColors.pureBlack.withValues(alpha: 0.3),
                child: Center(
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
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
