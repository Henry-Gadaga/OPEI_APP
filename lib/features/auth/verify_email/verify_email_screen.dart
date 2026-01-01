import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tt1/core/providers/providers.dart';
import 'package:go_router/go_router.dart';
import 'package:tt1/core/utils/error_helper.dart';
import 'package:tt1/features/auth/verify_email/verify_email_state.dart';
import 'package:tt1/responsive/responsive_tokens.dart';
import 'package:tt1/responsive/responsive_widgets.dart';
import 'package:tt1/theme.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String? email;
  final bool autoSendCode;

  const VerifyEmailScreen({this.email, this.autoSendCode = false, super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  String? _email;
  bool _isInitialized = false;
  bool _isPasting = false;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
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
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
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
    if (_isPasting) return;

    final controller = ref.read(verifyEmailControllerProvider.notifier);
    final sanitized = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (sanitized.length > 1) {
      _applyPastedDigits(index, sanitized);
      return;
    }

    if (sanitized.isEmpty) {
      controller.clearDigit(index);
      return;
    }

    controller.updateDigit(index, sanitized);

    if (index < 5) {
      _focusNodes[index + 1].requestFocus();
      _controllers[index + 1].selection = TextSelection.collapsed(
        offset: _controllers[index + 1].text.length,
      );
    } else {
      _focusNodes[index].unfocus();
    }
  }

  void _applyPastedDigits(int startIndex, String digits) {
    if (digits.isEmpty) return;
    final cappedDigits = digits.substring(
      0,
      min(digits.length, 6 - startIndex),
    );
    final notifier = ref.read(verifyEmailControllerProvider.notifier);
    _isPasting = true;

    for (var i = 0; i < 6; i++) {
      final targetIndex = startIndex + i;
      if (targetIndex >= 6) break;
      final char = i < cappedDigits.length ? cappedDigits[i] : '';
      _controllers[targetIndex].text = char;
      if (char.isNotEmpty) {
        notifier.updateDigit(targetIndex, char);
      } else {
        notifier.clearDigit(targetIndex);
      }
    }

    final insertionEnd = startIndex + cappedDigits.length;
    if (insertionEnd >= 6) {
      _focusNodes[5].unfocus();
    } else {
      _focusNodes[insertionEnd].requestFocus();
      _controllers[insertionEnd].selection = TextSelection.collapsed(
        offset: _controllers[insertionEnd].text.length,
      );
    }

    _isPasting = false;
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (!_isInitialized || _email == null) return false;
    if (event is! KeyDownEvent) return false;
    if (event.logicalKey != LogicalKeyboardKey.backspace) return false;

    final activeIndex = _focusNodes.indexWhere((node) => node.hasFocus);
    if (activeIndex == -1) return false;

    if (_controllers[activeIndex].text.isEmpty) {
      _handleEmptyBackspace(activeIndex);
    }
    return false;
  }

  void _handleEmptyBackspace(int index) {
    if (index == 0) {
      _focusNodes[0].requestFocus();
      return;
    }
    final previous = index - 1;
    final notifier = ref.read(verifyEmailControllerProvider.notifier);
    _focusNodes[previous].requestFocus();
    _controllers[previous].clear();
    notifier.clearDigit(previous);
  }

  Future<void> _handleBackNavigation() async {
    if (_isLoggingOut) return;
    setState(() {
      _isLoggingOut = true;
    });

    final authRepository = ref.read(authRepositoryProvider);
    final sessionNotifier = ref.read(authSessionProvider.notifier);
    final storage = ref.read(secureStorageServiceProvider);

    try {
      await authRepository.logout();
    } catch (e, stackTrace) {
      debugPrint('❌ Logout during verify-email failed: $e');
      debugPrint('$stackTrace');
    } finally {
      sessionNotifier.clearSession();
      await storage.clearEmail();
    }

    if (!mounted) {
      return;
    }

    context.go('/login');
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
      return const ResponsiveScaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final state = ref.watch(verifyEmailControllerProvider);
    final spacing = context.responsiveSpacingUnit;

    ref.listen<VerifyEmailState>(verifyEmailControllerProvider,
        (previous, next) async {
      // Handle verification completion
      if (previous != null && previous.isVerifying && !next.isVerifying) {
        if (next.errorMessage == null) {
          final storage = ref.read(secureStorageServiceProvider);
          await storage.clearEmail();

          if (!context.mounted) {
            return;
          }

          showSuccess(context, 'Email verified successfully!');
          // After email verification, backend sets stage to PENDING_ADDRESS
          context.go('/address');
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
        if (next.errorMessage == null && widget.autoSendCode && context.mounted) {
          showSuccess(context, 'Verification code sent to your email');
        }
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        if (state.isLoading || _isLoggingOut) {
          return;
        }
        await _handleBackNavigation();
      },
      child: ResponsiveScaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: spacing * 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: spacing * 3),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                      padding: EdgeInsets.zero,
                      onPressed: state.isLoading || _isLoggingOut
                          ? null
                          : () {
                              _handleBackNavigation();
                            },
                    ),
                  ),
                  SizedBox(height: spacing * 5),
                  Text(
                    'Verify Your Email',
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: spacing * 1.5),
                  Text(
                    'We sent a 6-digit code to',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: OpeiColors.grey600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: spacing * 0.5),
                  Text(
                    _email!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: spacing * 6),
                  IgnorePointer(
                    ignoring: state.isLoading || _isLoggingOut,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return CodeInputBox(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          onChanged: (value) => _onDigitChanged(index, value),
                          hasError: state.errorMessage != null,
                          isDisabled: state.isLoading,
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: spacing * 2),
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
                  SizedBox(height: spacing * 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.canResend
                            ? "Didn't receive the code? "
                            : "Resend code in ",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: OpeiColors.grey600,
                            ),
                      ),
                      if (!state.canResend)
                        Text(
                          state.timerText,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: OpeiColors.grey600,
                                  ),
                        ),
                      if (state.canResend)
                        GestureDetector(
                          onTap: _handleResend,
                          child: Text(
                            'Resend',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  decoration: TextDecoration.underline,
                                ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: spacing * 7.5),
                ],
              ),
            ),
            if (state.isLoading || _isLoggingOut)
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
                          _isLoggingOut
                              ? 'Signing out...'
                              : state.isVerifying
                                  ? 'Verifying...'
                                  : 'Sending code...',
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
  final bool hasError;
  final bool isDisabled;

  const CodeInputBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
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
          fillColor: isDisabled ? OpeiColors.grey100 : OpeiColors.pureWhite,
        ),
        onChanged: (value) => onChanged(value),
        onTap: () {
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length),
          );
        },
      ),
    );
  }
}
