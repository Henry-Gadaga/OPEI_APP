import 'package:flutter/material.dart';
import 'package:opei/theme.dart';

/// The four macro stages of the Opei onboarding journey. The progress pill
/// indicator is the same widget on every onboarding screen, so the user feels
/// they're moving through one continuous flow.
enum OnboardingStage {
  account, // Sign-up: email + phone + PIN
  verify, // Email verification
  address, // Home address
  identity, // KYC / identity verification
}

/// Animated 4-segment progress indicator shown in the top-right of every
/// onboarding header. White-tinted to sit on the blue gradient.
class OnboardingProgress extends StatelessWidget {
  final OnboardingStage stage;

  const OnboardingProgress({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    final current = stage.index; // enum implicit index — 0..3
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (i) {
        final completed = i < current;
        final active = i == current;
        return AnimatedContainer(
          duration: OpeiBrand.motion,
          curve: OpeiBrand.motionCurve,
          width: active ? 24 : 8,
          height: 6,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: completed
                ? Colors.white
                : active
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.30),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}
