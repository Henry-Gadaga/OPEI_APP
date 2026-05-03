import 'package:flutter/material.dart';

import 'package:opei/theme.dart';

/// Minimal premium app bar used across new auth/onboarding screens.
/// - 56px height
/// - Chevron back button
/// - Optional centered step pill ("Step 1 of 4")
/// - No title, hairline divider only when scrolled
class OpeiAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBack;
  final int? currentStep;
  final int? totalSteps;
  final Widget? trailing;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool showBack;

  const OpeiAppBar({
    super.key,
    this.onBack,
    this.currentStep,
    this.totalSteps,
    this.trailing,
    this.backgroundColor = OpeiBrand.surface,
    this.foregroundColor = OpeiBrand.ink,
    this.showBack = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final hasStep =
        currentStep != null && totalSteps != null && totalSteps! > 0;

    // SafeArea(bottom: false) pushes content below the status bar / notch.
    // Scaffold measures the appBar's actual rendered height, so adding the
    // SafeArea here correctly offsets the body too.
    return Material(
      color: backgroundColor,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  child: showBack
                      ? IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: foregroundColor,
                            size: 20,
                          ),
                          splashRadius: 20,
                          onPressed:
                              onBack ?? () => Navigator.of(context).pop(),
                        )
                      : const SizedBox.shrink(),
                ),
                Expanded(
                  child: Center(
                    child: hasStep
                        ? _StepPill(
                            current: currentStep!,
                            total: totalSteps!,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: trailing ?? const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  final int current;
  final int total;

  const _StepPill({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: OpeiBrand.primaryTint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Step $current of $total',
        style: const TextStyle(
          fontFamily: kPrimaryFontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: OpeiBrand.primary,
          letterSpacing: -0.1,
          height: 1.0,
        ),
      ),
    );
  }
}
