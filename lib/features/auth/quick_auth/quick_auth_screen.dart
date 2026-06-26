import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/features/auth/quick_auth/quick_auth_controller.dart';
import 'package:opei/features/auth/quick_auth/quick_auth_state.dart';
import 'package:opei/features/auth/quick_auth_setup/quick_auth_setup_controller.dart';
import 'package:opei/features/dashboard/dashboard_controller.dart';
import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/responsive/responsive_widgets.dart';
import 'package:opei/theme.dart';
import 'package:opei/widgets/opei_activity_indicator.dart';
import 'package:opei/widgets/opei_pin_pad.dart';

class QuickAuthScreen extends ConsumerStatefulWidget {
  const QuickAuthScreen({super.key});

  @override
  ConsumerState<QuickAuthScreen> createState() => _QuickAuthScreenState();
}

class _QuickAuthScreenState extends ConsumerState<QuickAuthScreen> {
  bool _hasPinSetup = false;
  bool _isReady = false;

  // Biometric login state. _biometricEnabled drives the keypad icon and
  // the auto-prompt; _showBiometricBanner is computed once at load time
  // from canUseBiometric + isBiometricEnabled + wasBiometricPromptShown.
  String? _userId;
  bool _biometricEnabled = false;
  bool _isFaceBiometric = false;
  bool _showBiometricBanner = false;
  bool _enrollingBiometric = false;
  bool _autoPromptedBiometric = false;

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
        _isReady = true;
      });
      return;
    }

    final hasPin = await quickAuthService.hasPinSetup(userIdentifier);

    // Resolve biometric availability + enabled state in parallel.
    final canUseBio = await quickAuthService.canUseBiometric();
    final biometricEnabled = canUseBio
        ? await quickAuthService.isBiometricEnabled(userIdentifier)
        : false;
    final isFace = canUseBio
        ? await quickAuthService.hasFaceBiometric()
        : false;
    final promptShown = await quickAuthService.wasBiometricPromptShown(
      userIdentifier,
    );

    // Show the inline opt-in banner to existing users (have PIN, no
    // biometric yet, hardware available, not previously dismissed).
    final showBanner = hasPin && canUseBio && !biometricEnabled && !promptShown;

    if (!mounted) return;
    setState(() {
      _userId = userIdentifier;
      _hasPinSetup = hasPin;
      _biometricEnabled = biometricEnabled;
      _isFaceBiometric = isFace;
      _showBiometricBanner = showBanner;
      _isReady = true;
    });

    // Auto-prompt biometric on screen open (after first paint) when the
    // user has already enabled it. Falls back gracefully to PIN if the
    // user cancels the OS prompt.
    if (biometricEnabled && hasPin && !_autoPromptedBiometric) {
      _autoPromptedBiometric = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(quickAuthControllerProvider.notifier).verifyBiometric();
      });
    }
  }

  Future<void> _handleEnableBiometric() async {
    if (_userId == null || _enrollingBiometric) return;
    final quickAuthService = ref.read(quickAuthServiceProvider);

    setState(() => _enrollingBiometric = true);

    try {
      final l10n = AppLocalizations.of(context)!;
      final ok = await quickAuthService.authenticateWithBiometric(
        _isFaceBiometric ? l10n.faceIdPrompt : l10n.fingerprintPrompt,
      );

      if (!mounted) return;

      if (ok) {
        await quickAuthService.enableBiometric(_userId!);
        await quickAuthService.markBiometricPromptShown(_userId!);
        if (!mounted) return;
        setState(() {
          _biometricEnabled = true;
          _showBiometricBanner = false;
          _enrollingBiometric = false;
        });
      } else {
        // User cancelled the OS prompt — keep banner visible so they
        // can try again, no error toast.
        setState(() => _enrollingBiometric = false);
      }
    } catch (e) {
      debugPrint('❌ Failed to enable biometric: $e');
      if (!mounted) return;
      setState(() => _enrollingBiometric = false);
    }
  }

  Future<void> _handleDismissBiometricBanner() async {
    if (_userId == null) return;
    final quickAuthService = ref.read(quickAuthServiceProvider);
    await quickAuthService.markBiometricPromptShown(_userId!);
    if (!mounted) return;
    setState(() => _showBiometricBanner = false);
  }

  void _handleTriggerBiometric() {
    if (!_biometricEnabled) return;
    ref.read(quickAuthControllerProvider.notifier).verifyBiometric();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedOpacity(
        opacity: _isReady ? 1 : 0,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  // ── Top spacer + heading ─────────────────────────────────
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_hasPinSetup) ...[
                          const Icon(
                            Icons.lock_outline_rounded,
                            size: 32,
                            color: OpeiBrand.inkTertiary,
                          ),
                          const SizedBox(height: 16),
                        ],
                        Text(
                          _hasPinSetup
                              ? l10n.quickAuthEnterPinTitle
                              : l10n.quickAuthNoPinTitle,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: OpeiBrand.ink,
                            letterSpacing: -0.6,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _hasPinSetup
                              ? l10n.quickAuthEnterPinSubtitle
                              : l10n.quickAuthNoPinSubtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                            color: OpeiBrand.inkSecondary,
                            letterSpacing: -0.1,
                          ),
                        ),
                        if (_hasPinSetup && _showBiometricBanner) ...[
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: _BiometricOptInBanner(
                              isFace: _isFaceBiometric,
                              isLoading: _enrollingBiometric,
                              onEnable: _handleEnableBiometric,
                              onDismiss: _handleDismissBiometricBanner,
                            ),
                          ),
                        ],
                        if (_hasPinSetup) ...[
                          const SizedBox(height: 36),
                          OpeiPinDots(
                            filled: pinState.pin.length,
                            errored: pinState.errorMessage != null,
                          ),
                          const SizedBox(height: 10),
                          _ErrorLine(message: pinState.errorMessage),
                        ],
                      ],
                    ),
                  ),

                  // ── Keypad zone ──────────────────────────────────────────
                  if (_hasPinSetup)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: OpeiPinKeypad(
                        onDigit: (d) => ref
                            .read(quickAuthControllerProvider.notifier)
                            .addDigit(d),
                        onDelete: () => ref
                            .read(quickAuthControllerProvider.notifier)
                            .removeDigit(),
                        leadingAction: _biometricEnabled
                            ? _BiometricKey(
                                isFace: _isFaceBiometric,
                                onTap: _handleTriggerBiometric,
                              )
                            : null,
                      ),
                    ),

                  // ── Bottom links ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: _BottomLinks(
                      onUsePassword: () {
                        ref.read(quickAuthStatusProvider.notifier).reset();
                        context.go('/login');
                      },
                      onForgotPin: () {
                        ref.read(quickAuthStatusProvider.notifier).reset();
                        context.go('/forgot-password');
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleQuickAuthSuccess() async {
    if (!mounted) return;
    final navigator = GoRouter.of(context);
    final dashboardController = ref.read(dashboardControllerProvider.notifier);
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
      authRepository.logout().timeout(const Duration(seconds: 8)).catchError((
        error,
        stackTrace,
      ) {
        debugPrint('⚠️ Logout after quick-auth failure hit an error: $error');
        return null;
      }),
    );

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(message, maxLines: 4, overflow: TextOverflow.ellipsis),
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
    final l10n = AppLocalizations.of(context)!;
    return ResponsiveScaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const OpeiActivityIndicator(size: 52, strokeWidth: 2.6),
              const SizedBox(height: 24),
              Text(
                l10n.quickAuthVerifyingTitle,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: OpeiBrand.ink,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.quickAuthVerifyingSubtitle,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: OpeiBrand.inkSecondary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
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

class _BiometricOptInBanner extends StatelessWidget {
  final bool isFace;
  final bool isLoading;
  final VoidCallback onEnable;
  final VoidCallback onDismiss;

  const _BiometricOptInBanner({
    required this.isFace,
    required this.isLoading,
    required this.onEnable,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = isFace
        ? l10n.quickAuthFaceIdBanner
        : l10n.quickAuthFingerprintBanner;
    final iconData = isFace ? Icons.face_outlined : Icons.fingerprint;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: OpeiBrand.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: OpeiBrand.primary.withValues(alpha: 0.16),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: OpeiBrand.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, size: 20, color: OpeiBrand.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: OpeiBrand.ink,
                letterSpacing: -0.1,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isLoading)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: OpeiBrand.primary,
              ),
            )
          else ...[
            TextButton(
              onPressed: onEnable,
              style: TextButton.styleFrom(
                foregroundColor: OpeiBrand.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.quickAuthEnableCta,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              iconSize: 16,
              onPressed: onDismiss,
              icon: const Icon(Icons.close, color: OpeiBrand.inkTertiary),
              tooltip: l10n.quickAuthDismissTooltip,
            ),
          ],
        ],
      ),
    );
  }
}

class _BiometricKey extends StatelessWidget {
  final bool isFace;
  final VoidCallback onTap;

  const _BiometricKey({required this.isFace, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: Icon(
          isFace ? Icons.face_outlined : Icons.fingerprint,
          size: 32,
          color: OpeiBrand.primary,
        ),
      ),
    );
  }
}

class _BottomLinks extends StatelessWidget {
  final VoidCallback onUsePassword;
  final VoidCallback onForgotPin;
  const _BottomLinks({required this.onUsePassword, required this.onForgotPin});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: onUsePassword,
          style: TextButton.styleFrom(
            foregroundColor: OpeiBrand.inkSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            l10n.quickAuthUsePasswordCta,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.1,
            ),
          ),
        ),
        Container(width: 1, height: 14, color: OpeiBrand.hairline),
        TextButton(
          onPressed: onForgotPin,
          style: TextButton.styleFrom(
            foregroundColor: OpeiBrand.inkSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            l10n.forgotPinCta,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ],
    );
  }
}
