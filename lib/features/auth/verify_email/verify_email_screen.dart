import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tt1/core/providers/providers.dart';
import 'package:go_router/go_router.dart';
import 'package:tt1/core/utils/error_helper.dart';
import 'package:tt1/features/auth/verify_email/verify_email_state.dart';
import 'package:tt1/theme.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String? email;
  final bool autoSendCode;

  const VerifyEmailScreen({this.email, this.autoSendCode = false, super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  String? _email;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeEmail();
  }

  Future<void> _initializeEmail() async {
    debugPrint('📧 Starting email initialization...');
    String? email = widget.email;
    
    if (email == null) {
      debugPrint('📧 Email not in route args, checking secure storage...');
      final storage = ref.read(secureStorageServiceProvider);
      email = await storage.getEmail();
    }

    if (email == null && mounted) {
      debugPrint('❌ No email found anywhere');
      showError(context, 'Email not found. Please sign up again.');
      // Using GoRouter navigation to avoid invalid pop on declarative routes
      context.go('/login');
      return;
    }

    debugPrint('✅ Email found: $email, calling controller initialize');
    setState(() {
      _email = email;
      _isInitialized = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(verifyEmailControllerProvider.notifier).initialize(
        email!,
        autoSendCode: widget.autoSendCode,
      );
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (!_isInitialized || _email == null) return;

    final controller = ref.read(verifyEmailControllerProvider.notifier);

    if (value.isNotEmpty) {
      controller.updateDigit(index, value);
      
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
  }

  void _onDigitDeleted(int index) {
    if (!_isInitialized || _email == null) return;

    final controller = ref.read(verifyEmailControllerProvider.notifier);
    controller.clearDigit(index);

    if (index > 0 && _controllers[index].text.isEmpty) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _handleResend() async {
    if (!_isInitialized || _email == null) return;

    final controller = ref.read(verifyEmailControllerProvider.notifier);
    final success = await controller.resendCode();

    if (success && mounted) {
      showSuccess(context, 'Verification code sent to your email');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _email == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final state = ref.watch(verifyEmailControllerProvider);

    ref.listen<VerifyEmailState>(verifyEmailControllerProvider, (previous, next) async {
      // Handle verification completion
      if (previous != null && previous.isVerifying && !next.isVerifying) {
        if (next.errorMessage == null) {
          final storage = ref.read(secureStorageServiceProvider);
          await storage.clearEmail();

          if (mounted) {
            showSuccess(context, 'Email verified successfully!');
            // After email verification, backend sets stage to PENDING_ADDRESS
            context.go('/address');
          }
        } else {
          // Clear all text controllers when verification fails
          for (var controller in _controllers) {
            controller.clear();
          }
          // Focus on first input
          if (mounted) {
            _focusNodes[0].requestFocus();
          }
        }
      }
      
      // Handle auto-send completion (show feedback)
      if (previous != null && previous.isResending && !next.isResending) {
        if (next.errorMessage == null && mounted && widget.autoSendCode) {
          showSuccess(context, 'Verification code sent to your email');
        }
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: AppSpacing.horizontalLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                      onPressed: state.isLoading ? null : () => context.go('/login'),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  Text(
                    'Verify Your Email',
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    'We sent a 6-digit code to',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: OpeiColors.grey600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    _email!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 48),
                  
                  IgnorePointer(
                    ignoring: state.isLoading,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return CodeInputBox(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          onChanged: (value) => _onDigitChanged(index, value),
                          onBackspace: () => _onDigitDeleted(index),
                          hasError: state.errorMessage != null,
                          isDisabled: state.isLoading,
                        );
                      }),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  if (state.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        state.errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: OpeiColors.errorRed,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  
                  const SizedBox(height: 32),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.canResend ? "Didn't receive the code? " : "Resend code in ",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: OpeiColors.grey600,
                        ),
                      ),
                      if (!state.canResend)
                        Text(
                          state.timerText,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: OpeiColors.grey600,
                          ),
                        ),
                      if (state.canResend)
                        GestureDetector(
                          onTap: _handleResend,
                          child: Text(
                            'Resend',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 60),
                ],
              ),
            ),
            
            if (state.isLoading)
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
                          state.isVerifying ? 'Verifying...' : 'Sending code...',
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

class CodeInputBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;
  final bool hasError;
  final bool isDisabled;

  const CodeInputBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
    this.hasError = false,
    this.isDisabled = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        enabled: !isDisabled,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          counterText: '',
          contentPadding: const EdgeInsets.all(0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(
              color: hasError ? OpeiColors.errorRed : OpeiColors.grey300,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(
              color: hasError ? OpeiColors.errorRed : OpeiColors.pureBlack,
              width: 2,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(
              color: OpeiColors.grey200,
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor: isDisabled 
              ? OpeiColors.grey100 
              : OpeiColors.pureWhite,
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            onChanged(value);
          }
        },
        onFieldSubmitted: (_) {
          if (controller.text.isEmpty) {
            onBackspace();
          }
        },
        onTap: () {
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length),
          );
        },
      ),
    );
  }
}
