import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/features/auth/verify_email/verify_email_state.dart';
import 'package:opei/theme.dart';
import 'package:opei/widgets/opei_premium/opei_premium.dart';

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
    String? email = widget.email;

    if (email == null) {
      final storage = ref.read(secureStorageServiceProvider);
      email = await storage.getEmail();
    }

    if (email == null && mounted) {
      showError(context, 'Email not found. Please sign up again.');
      context.go('/login');
      return;
    }

    setState(() {
      _email = email;
      _isInitialized = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(verifyEmailControllerProvider.notifier).initialize(
            email!,
            autoSendCode: widget.autoSendCode,
          );
      // Auto-focus first box for fastest possible entry.
      if (_focusNodes.isNotEmpty) _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (!_isInitialized || _email == null || _isPasting) return;

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
    setState(() => _isLoggingOut = true);

    final authRepository = ref.read(authRepositoryProvider);
    final sessionNotifier = ref.read(authSessionProvider.notifier);
    final storage = ref.read(secureStorageServiceProvider);

    try {
      await authRepository.logout();
    } catch (_) {
      // best-effort logout
    } finally {
      sessionNotifier.clearSession();
      await storage.clearEmail();
    }

    if (!mounted) return;
    context.go('/welcome');
  }

  Future<void> _handleResend() async {
    if (!_isInitialized || _email == null) return;

    final controller = ref.read(verifyEmailControllerProvider.notifier);
    final success = await controller.resendCode();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Verification code sent'),
          backgroundColor: OpeiBrand.success,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
          ),
        ),
      );
      // Re-focus first box for re-entry.
      _focusNodes[0].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _email == null) {
      return const Scaffold(
        backgroundColor: OpeiBrand.surface,
        body: Center(
          child: CircularProgressIndicator(color: OpeiBrand.primary),
        ),
      );
    }

    final state = ref.watch(verifyEmailControllerProvider);

    ref.listen<VerifyEmailState>(verifyEmailControllerProvider,
        (previous, next) async {
      if (previous != null && previous.isVerifying && !next.isVerifying) {
        if (next.errorMessage == null) {
          final storage = ref.read(secureStorageServiceProvider);
          await storage.clearEmail();
          if (!context.mounted) return;
          context.go('/address');
        } else {
          for (final c in _controllers) {
            c.clear();
          }
          if (mounted) _focusNodes[0].requestFocus();
        }
      }
      if (previous != null && previous.isResending && !next.isResending) {
        if (next.errorMessage == null && widget.autoSendCode && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Verification code sent'),
              backgroundColor: OpeiBrand.success,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
              ),
            ),
          );
        }
      }
    });

    final bottomPad = MediaQuery.of(context).viewPadding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: OpeiBrand.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          if (state.isLoading || _isLoggingOut) return;
          await _handleBackNavigation();
        },
        child: Scaffold(
          backgroundColor: OpeiBrand.surface,
          appBar: OpeiAppBar(
            backgroundColor: OpeiBrand.surface,
            onBack: state.isLoading || _isLoggingOut
                ? null
                : () => _handleBackNavigation(),
          ),
          body: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress bar — step 2 of 4
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
                            color: i < 2
                                ? OpeiBrand.primary
                                : OpeiBrand.hairline,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Check your\nemail',
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
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: kPrimaryFontFamily,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w400,
                              color: OpeiBrand.inkSecondary,
                              letterSpacing: -0.1,
                              height: 1.45,
                            ),
                            children: [
                              const TextSpan(
                                text: "We sent a 6-digit code to ",
                              ),
                              TextSpan(
                                text: _email!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: OpeiBrand.ink,
                                ),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),
                        IgnorePointer(
                          ignoring: state.isLoading || _isLoggingOut,
                          child: _OtpRow(
                            controllers: _controllers,
                            focusNodes: _focusNodes,
                            hasError: state.errorMessage != null,
                            isDisabled: state.isLoading,
                            onChanged: _onDigitChanged,
                          ),
                        ),
                        if (state.errorMessage != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            state.errorMessage!,
                            style: const TextStyle(
                              fontFamily: kPrimaryFontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: OpeiBrand.danger,
                              letterSpacing: -0.1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 28),
                        Center(
                          child: _ResendRow(
                            canResend: state.canResend,
                            timerText: state.timerText,
                            onResend: _handleResend,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: GestureDetector(
                            onTap: state.isLoading || _isLoggingOut
                                ? null
                                : _handleBackNavigation,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Wrong email? Start over',
                                style: TextStyle(
                                  fontFamily: kPrimaryFontFamily,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: OpeiBrand.inkSecondary,
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Loading strip — only visible while verifying
                _BottomTrust(
                  isLoading: state.isVerifying || _isLoggingOut,
                  busyLabel: _isLoggingOut ? 'Signing out…' : 'Verifying…',
                  bottomPad: bottomPad,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpRow extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool hasError;
  final bool isDisabled;
  final void Function(int, String) onChanged;

  const _OtpRow({
    required this.controllers,
    required this.focusNodes,
    required this.hasError,
    required this.isDisabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const spacing = 10.0;
        final available = c.maxWidth - spacing * 5;
        final boxWidth = (available / 6).clamp(44.0, 60.0);
        final boxHeight = boxWidth * 1.22;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) {
            return _OtpBox(
              controller: controllers[i],
              focusNode: focusNodes[i],
              hasError: hasError,
              isDisabled: isDisabled,
              width: boxWidth,
              height: boxHeight,
              onChanged: (v) => onChanged(i, v),
            );
          }),
        );
      },
    );
  }
}

class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final bool isDisabled;
  final double width;
  final double height;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.isDisabled,
    required this.width,
    required this.height,
    required this.onChanged,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_rebuild);
    widget.controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_rebuild);
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = widget.focusNode.hasFocus;
    final hasValue = widget.controller.text.isNotEmpty;
    final color = widget.hasError
        ? OpeiBrand.danger
        : isFocused
            ? OpeiBrand.primary
            : hasValue
                ? OpeiBrand.hairlineStrong
                : OpeiBrand.hairline;

    return AnimatedContainer(
      duration: OpeiBrand.motionFast,
      curve: OpeiBrand.motionCurve,
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        // Always white inside (clear). Disabled state only changes border.
        color: OpeiBrand.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color,
          width: isFocused || widget.hasError ? 1.6 : 1.0,
        ),
      ),
      alignment: Alignment.center,
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        enabled: !widget.isDisabled,
        cursorColor: OpeiBrand.primary,
        cursorWidth: 1.6,
        cursorHeight: 22,
        style: const TextStyle(
          fontFamily: kPrimaryFontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: OpeiBrand.ink,
          letterSpacing: -0.4,
          height: 1.0,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          counterText: '',
          isCollapsed: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: widget.onChanged,
        onTap: () {
          widget.controller.selection = TextSelection.fromPosition(
            TextPosition(offset: widget.controller.text.length),
          );
        },
      ),
    );
  }
}

class _ResendRow extends StatelessWidget {
  final bool canResend;
  final String timerText;
  final VoidCallback onResend;

  const _ResendRow({
    required this.canResend,
    required this.timerText,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    const baseStyle = TextStyle(
      fontFamily: kPrimaryFontFamily,
      fontSize: 13.5,
      fontWeight: FontWeight.w500,
      color: OpeiBrand.inkSecondary,
      letterSpacing: -0.1,
    );

    if (canResend) {
      return RichText(
        text: TextSpan(
          style: baseStyle,
          children: [
            const TextSpan(text: "Didn't get the code? "),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: onResend,
                child: const Text(
                  'Resend',
                  style: TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: OpeiBrand.primary,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Text(
      'Resend code in $timerText',
      style: baseStyle.copyWith(color: OpeiBrand.inkTertiary),
    );
  }
}

class _BottomTrust extends StatelessWidget {
  final bool isLoading;
  final String busyLabel;
  final double bottomPad;

  const _BottomTrust({
    required this.isLoading,
    required this.busyLabel,
    this.bottomPad = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Bottom strip only renders while we're verifying / signing out — keeps
    // the screen ultra compact when idle.
    return AnimatedSize(
      duration: OpeiBrand.motionFast,
      curve: OpeiBrand.motionCurve,
      alignment: Alignment.bottomCenter,
      child: !isLoading
          ? const SizedBox.shrink()
          : Container(
              decoration: const BoxDecoration(
                color: OpeiBrand.surface,
                border: Border(
                  top: BorderSide(color: OpeiBrand.hairline, width: 1),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                24,
                14,
                24,
                14 + bottomPad,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: OpeiBrand.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    busyLabel,
                    style: const TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: OpeiBrand.inkSecondary,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
