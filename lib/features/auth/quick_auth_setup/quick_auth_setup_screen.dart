import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opei/features/auth/quick_auth_setup/quick_auth_setup_controller.dart';
import 'package:opei/features/auth/quick_auth_setup/quick_auth_setup_state.dart';
import 'package:opei/responsive/responsive_widgets.dart';
import 'package:opei/theme.dart';
import 'package:opei/widgets/bouncing_dots.dart';
import 'package:opei/widgets/opei_pin_pad.dart';

class QuickAuthSetupScreen extends ConsumerWidget {
  final bool popOnComplete;

  const QuickAuthSetupScreen({super.key, this.popOnComplete = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quickAuthSetupControllerProvider);

    ref.listen(quickAuthSetupControllerProvider, (previous, next) {
      if (next is QuickAuthSetupSuccess) {
        if (popOnComplete) {
          context.pop(true);
        } else {
          context.go('/dashboard');
        }
      } else if (next is QuickAuthSetupError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message, maxLines: 4, overflow: TextOverflow.ellipsis),
            backgroundColor: OpeiBrand.danger,
          ),
        );
        ref.read(quickAuthSetupControllerProvider.notifier).reset();
      }
    });

    if (state is QuickAuthSetupPinEntry) {
      return _PinEntryScreen(state: state);
    }

    if (state is QuickAuthSetupLoading) {
      return const _SavingPinView();
    }

    return const _SavingPinView();
  }
}

class _SavingPinView extends StatelessWidget {
  const _SavingPinView();

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Saving your PIN',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: OpeiBrand.ink,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Hang tight, just a moment…',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: OpeiBrand.inkSecondary,
                ),
              ),
              SizedBox(height: 28),
              BouncingDots(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinEntryScreen extends ConsumerWidget {
  final QuickAuthSetupPinEntry state;

  const _PinEntryScreen({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConfirming = state.isConfirming;
    return ResponsiveScaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 12).clamp(0.0, double.infinity),
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
              // Back bar
              _BackBar(
                onBack: () => ref
                    .read(quickAuthSetupControllerProvider.notifier)
                    .reset(),
              ),

              // ── Top zone: glyph + title + dots (takes all spare space) ─
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Glyph(isConfirming: isConfirming),
                    const SizedBox(height: 18),
                    Text(
                      isConfirming ? 'Confirm PIN' : 'Create PIN',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: OpeiBrand.ink,
                        letterSpacing: -0.7,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      isConfirming
                          ? 'Enter your PIN again to confirm'
                          : 'Choose a 6-digit PIN to sign in faster',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: OpeiBrand.inkSecondary,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 36),
                    OpeiPinDots(
                      filled: state.pin.length,
                      errored: state.errorMessage != null,
                    ),
                    const SizedBox(height: 12),
                    _ErrorLine(message: state.errorMessage),
                  ],
                ),
              ),

              // ── Bottom zone: keypad (natural height) ───────────────────
              OpeiPinKeypad(
                onDigit: (d) => ref
                    .read(quickAuthSetupControllerProvider.notifier)
                    .addDigit(d),
                onDelete: () => ref
                    .read(quickAuthSetupControllerProvider.notifier)
                    .removeDigit(),
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
    );
  }
}

class _BackBar extends StatelessWidget {
  final VoidCallback onBack;
  const _BackBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: 20,
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: OpeiBrand.ink,
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class _Glyph extends StatelessWidget {
  final bool isConfirming;
  const _Glyph({required this.isConfirming});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: OpeiBrand.primary.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          isConfirming
              ? Icons.lock_outline_rounded
              : Icons.lock_outline_rounded,
          size: 28,
          color: OpeiBrand.primary,
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
