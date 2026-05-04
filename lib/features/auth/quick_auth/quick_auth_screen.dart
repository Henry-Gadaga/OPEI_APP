import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/features/auth/quick_auth/quick_auth_controller.dart';
import 'package:opei/features/auth/quick_auth/quick_auth_state.dart';
import 'package:opei/features/auth/quick_auth_setup/quick_auth_setup_controller.dart';
import 'package:opei/features/dashboard/dashboard_controller.dart';
import 'package:opei/responsive/responsive_widgets.dart';
import 'package:opei/theme.dart';
import 'package:opei/widgets/bouncing_dots.dart';
import 'package:opei/widgets/opei_pin_pad.dart';

class QuickAuthScreen extends ConsumerStatefulWidget {
  const QuickAuthScreen({super.key});

  @override
  ConsumerState<QuickAuthScreen> createState() => _QuickAuthScreenState();
}

class _QuickAuthScreenState extends ConsumerState<QuickAuthScreen> {
  bool _hasPinSetup = false;
  String _userName = '';
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _checkAuthSetup();
  }

  Future<void> _checkAuthSetup() async {
    final quickAuthService = ref.read(quickAuthServiceProvider);
    final storage = ref.read(secureStorageServiceProvider);
    final user = await storage.getUser();
    var userIdentifier = user?.id;
    userIdentifier ??= await quickAuthService.getRegisteredUserId();

    if (userIdentifier == null) {
      if (!mounted) return;
      setState(() {
        _hasPinSetup = false;
        _userName = 'User';
        _isReady = true;
      });
      return;
    }

    final hasPin = await quickAuthService.hasPinSetup(userIdentifier);

    if (!mounted) return;
    setState(() {
      _hasPinSetup = hasPin;
      _userName = user?.email.split('@').first ?? 'User';
      _isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quickAuthControllerProvider);

    ref.listen<QuickAuthState>(quickAuthControllerProvider, (previous, next) {
      if (next is QuickAuthSuccess) {
        _handleQuickAuthSuccess();
      } else if (next is QuickAuthFailed) {
        _handleQuickAuthFailure(next.message);
      }
    });

    if (state is QuickAuthLoading || state is QuickAuthSuccess) {
      return const _VerifyingView();
    }

    final pinState = state is QuickAuthPinEntry ? state : QuickAuthPinEntry();

    return ResponsiveScaffold(
      body: AnimatedOpacity(
        opacity: _isReady ? 1 : 0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        child: AnimatedSlide(
          offset: _isReady ? Offset.zero : const Offset(0, 0.04),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _Avatar(initial: _userName.isNotEmpty
                              ? _userName[0].toUpperCase()
                              : 'U'),
                          const SizedBox(height: 22),
                          const Text(
                            'Welcome back',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: OpeiBrand.ink,
                              letterSpacing: -0.6,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _hasPinSetup
                                ? 'Enter your 6-digit PIN to continue'
                                : 'No quick PIN is set up on this device',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: OpeiBrand.inkSecondary,
                              letterSpacing: -0.1,
                            ),
                          ),
                          const SizedBox(height: 36),
                          if (_hasPinSetup) ...[
                            OpeiPinDots(
                              filled: pinState.pin.length,
                              errored: pinState.errorMessage != null,
                            ),
                            const SizedBox(height: 18),
                            _ErrorLine(message: pinState.errorMessage),
                            const SizedBox(height: 28),
                            OpeiPinKeypad(
                              onDigit: (d) => ref
                                  .read(quickAuthControllerProvider.notifier)
                                  .addDigit(d),
                              onDelete: () => ref
                                  .read(quickAuthControllerProvider.notifier)
                                  .removeDigit(),
                            ),
                          ] else ...[
                            const SizedBox(height: 24),
                            const Icon(Icons.lock_outline_rounded,
                                size: 36, color: OpeiBrand.inkTertiary),
                            const SizedBox(height: 32),
                          ],
                          const SizedBox(height: 24),
                          _BottomLinks(
                            onUsePassword: () => context.go('/login'),
                            onForgotPin: () => ref
                                .read(quickAuthControllerProvider.notifier)
                                .logoutAndResetPin(),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleQuickAuthSuccess() async {
    if (!mounted) return;
    final navigator = GoRouter.of(context);
    final dashboardController =
        ref.read(dashboardControllerProvider.notifier);
    dashboardController.prepareForFreshLaunch();
    dashboardController.refreshBalance(showSpinner: true);
    navigator.go('/dashboard');
  }

  Future<void> _handleQuickAuthFailure(String message) async {
    if (!mounted) return;

    final authRepository = ref.read(authRepositoryProvider);
    final sessionNotifier = ref.read(authSessionProvider.notifier);

    sessionNotifier.clearSession();

    try {
      if (mounted) {
        ref.read(quickAuthSetupControllerProvider.notifier).reset();
      }
    } catch (e) {
      debugPrint('QuickAuthSetup provider already disposed: $e');
    }

    unawaited(
      authRepository.logout().timeout(const Duration(seconds: 8)).catchError(
        (error, stackTrace) {
          debugPrint('⚠️ Logout after quick-auth failure hit an error: $error');
          return null;
        },
      ),
    );

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: OpeiBrand.danger,
      ),
    );
    if (!mounted) return;
    GoRouter.of(context).go('/login');
  }
}

class _VerifyingView extends StatelessWidget {
  const _VerifyingView();

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Verifying your PIN',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: OpeiBrand.ink,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Hang tight, just a moment…',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: OpeiBrand.inkSecondary,
                ),
              ),
              const SizedBox(height: 28),
              const BouncingDots(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initial;
  const _Avatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            OpeiBrand.primary,
            OpeiBrand.primary.withValues(alpha: 0.78),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: OpeiBrand.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}

class _ErrorLine extends StatelessWidget {
  final String? message;
  const _ErrorLine({required this.message});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: message == null
          ? const SizedBox(height: 16, key: ValueKey('empty'))
          : Padding(
              key: const ValueKey('msg'),
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: OpeiBrand.danger,
                  letterSpacing: -0.1,
                ),
              ),
            ),
    );
  }
}

class _BottomLinks extends StatelessWidget {
  final VoidCallback onUsePassword;
  final VoidCallback onForgotPin;
  const _BottomLinks({
    required this.onUsePassword,
    required this.onForgotPin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: onUsePassword,
          style: TextButton.styleFrom(
            foregroundColor: OpeiBrand.inkSecondary,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text(
            'Use password instead',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ),
        const SizedBox(height: 2),
        TextButton(
          onPressed: onForgotPin,
          style: TextButton.styleFrom(
            foregroundColor: OpeiBrand.danger,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text(
            'Forgot PIN?',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ],
    );
  }
}
