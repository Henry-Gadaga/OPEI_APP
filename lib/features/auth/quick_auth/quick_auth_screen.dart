import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tt1/core/providers/providers.dart';
import 'package:tt1/features/auth/quick_auth/quick_auth_controller.dart';
import 'package:tt1/features/auth/quick_auth/quick_auth_state.dart';
import 'package:tt1/features/auth/quick_auth_setup/quick_auth_setup_controller.dart';
import 'package:tt1/features/dashboard/dashboard_controller.dart';
import 'package:tt1/theme.dart';
import 'package:tt1/widgets/bouncing_dots.dart';

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
    
    ref.listen(quickAuthControllerProvider, (previous, next) async {
      if (next is QuickAuthSuccess) {
        final dashboardController =
            ref.read(dashboardControllerProvider.notifier);
        dashboardController.prepareForFreshLaunch();
        dashboardController.refreshBalance(showSpinner: true);
        context.go('/dashboard');
      } else if (next is QuickAuthFailed) {
        await ref.read(authRepositoryProvider).logout();
        ref.read(authSessionProvider.notifier).clearSession();
        ref
            .read(quickAuthSetupControllerProvider.notifier)
            .reset();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: OpeiColors.errorRed,
          ),
        );
          context.go('/login');
      }
    });

    if (state is QuickAuthLoading || state is QuickAuthSuccess) {
      return Scaffold(
        backgroundColor: OpeiColors.pureWhite,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Verifying your PIN',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hang tight, just a moment...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: OpeiColors.iosLabelSecondary,
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

    final pinState = state is QuickAuthPinEntry ? state : QuickAuthPinEntry();

    return Scaffold(
      backgroundColor: OpeiColors.pureWhite,
      body: SafeArea(
        child: AnimatedOpacity(
          opacity: _isReady ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: AnimatedSlide(
            offset: _isReady ? Offset.zero : const Offset(0, 0.04),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
        child: Column(
          children: [
            const SizedBox(height: 48),
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFFF5F5F7),
              child: Text(
                _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: OpeiColors.pureBlack,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome back',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              _userName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: OpeiColors.grey600,
              ),
            ),
            if (pinState.errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                pinState.errorMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: OpeiColors.errorRed,
                ),
              ),
            ],
            const SizedBox(height: 48),
            if (_hasPinSetup) ...[
              _buildPinDots(pinState.pin),
              const Spacer(),
              _buildNumericKeypad(context),
            ] else ...[
              const Spacer(),
              Text(
                'No quick PIN set up for quick login',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: OpeiColors.grey600,
                ),
              ),
              const Spacer(),
            ],
            TextButton(
              onPressed: () => context.go('/login'),
              child: Text(
                'Use Password Instead',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: OpeiColors.grey600,
                ),
              ),
            ),
                TextButton(
                  onPressed: () => ref
                      .read(quickAuthControllerProvider.notifier)
                      .logoutAndResetPin(),
                  child: Text(
                    'Forgot PIN?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: OpeiColors.errorRed,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
            const SizedBox(height: 32),
          ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinDots(String pin) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          6,
          (index) => Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: index < pin.length
                  ? OpeiColors.pureBlack
                  : Colors.transparent,
              border: Border.all(
                color: index < pin.length
                    ? OpeiColors.pureBlack
                    : OpeiColors.grey300,
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );

  Widget _buildNumericKeypad(BuildContext context) {
    final buttons = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];

    return Column(
      children: buttons
          .map((row) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((button) {
                  if (button.isEmpty)
                    return const SizedBox(width: 80, height: 80);
              
              return GestureDetector(
                onTap: () {
                  if (button == 'del') {
                        ref
                            .read(quickAuthControllerProvider.notifier)
                            .removeDigit();
                  } else {
                        ref
                            .read(quickAuthControllerProvider.notifier)
                            .addDigit(button);
                  }
                },
                child: Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                        color: button == 'del'
                            ? Colors.transparent
                            : const Color(0xFFF5F5F7),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: button == 'del'
                            ? const Icon(Icons.backspace_outlined,
                                size: 24, color: OpeiColors.pureBlack)
                        : Text(
                            button,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                  ),
                ),
              );
            }).toList(),
              ))
          .toList(),
    );
  }
}
