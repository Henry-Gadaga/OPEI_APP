import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tt1/features/auth/quick_auth_setup/quick_auth_setup_controller.dart';
import 'package:tt1/features/auth/quick_auth_setup/quick_auth_setup_state.dart';
import 'package:tt1/theme.dart';

class QuickAuthSetupScreen extends ConsumerWidget {
  final bool popOnComplete;

  const QuickAuthSetupScreen({super.key, this.popOnComplete = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quickAuthSetupControllerProvider);
    
    ref.listen(quickAuthSetupControllerProvider, (previous, next) {
      if (next is QuickAuthSetupSuccess) {
        Future.microtask(() => ref.read(quickAuthSetupControllerProvider.notifier).reset());
        if (popOnComplete) {
          context.pop(true);
        } else {
          context.go('/dashboard');
        }
      } else if (next is QuickAuthSetupError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: OpeiColors.errorRed,
          ),
        );
        ref.read(quickAuthSetupControllerProvider.notifier).reset();
      }
    });

    if (state is QuickAuthSetupPinEntry) {
      return _PinEntryScreen(state: state);
    }

    if (state is QuickAuthSetupLoading) {
      return const Scaffold(
        backgroundColor: OpeiColors.pureWhite,
        body: Center(child: CircularProgressIndicator(color: OpeiColors.pureBlack)),
      );
    }

    return const Scaffold(
      backgroundColor: OpeiColors.pureWhite,
      body: Center(child: CircularProgressIndicator(color: OpeiColors.pureBlack)),
      );
  }
}

class _PinEntryScreen extends ConsumerWidget {
  final QuickAuthSetupPinEntry state;
  
  const _PinEntryScreen({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: OpeiColors.pureWhite,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    onPressed: () => ref.read(quickAuthSetupControllerProvider.notifier).reset(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              state.isConfirming ? 'Confirm PIN' : 'Create PIN',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.isConfirming
                  ? 'Enter your PIN again to confirm'
                  : 'Create a 6-digit PIN',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: OpeiColors.grey600,
              ),
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: OpeiColors.errorRed,
                ),
              ),
            ],
            const SizedBox(height: 48),
            _buildPinDots(state.pin),
            const Spacer(),
            _buildNumericKeypad(context, ref),
            const SizedBox(height: 32),
          ],
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
              color: index < pin.length ? OpeiColors.pureBlack : Colors.transparent,
              border: Border.all(
                color: index < pin.length ? OpeiColors.pureBlack : OpeiColors.grey300,
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );

  Widget _buildNumericKeypad(BuildContext context, WidgetRef ref) {
    final buttons = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];

    return Column(
      children: buttons.map((row) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((button) {
              if (button.isEmpty) return const SizedBox(width: 80, height: 80);
              
              return GestureDetector(
                onTap: () {
                  if (button == 'del') {
                    ref.read(quickAuthSetupControllerProvider.notifier).removeDigit();
                  } else {
                    ref.read(quickAuthSetupControllerProvider.notifier).addDigit(button);
                  }
                },
                child: Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: button == 'del' ? Colors.transparent : const Color(0xFFF5F5F7),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: button == 'del'
                        ? const Icon(Icons.backspace_outlined, size: 24, color: OpeiColors.pureBlack)
                        : Text(
                            button,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                  ),
                ),
              );
            }).toList(),
          )).toList(),
    );
  }
}
