import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:opei/theme.dart';

/// Premium Opei CTA button.
/// - Full width by default, 56px tall
/// - Brand blue, 14px radius
/// - Loading state (spinner inside)
/// - Light haptic on tap
class OpeiPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool expand;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Color backgroundColor;
  final Color foregroundColor;

  const OpeiPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.expand = true,
    this.leadingIcon,
    this.trailingIcon,
    this.backgroundColor = OpeiBrand.primary,
    this.foregroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;

    final button = SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: disabled
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed!();
              },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: OpeiBrand.primaryTintStrong,
          disabledForegroundColor: OpeiBrand.primary.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OpeiBrand.radiusCta),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: const TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        child: AnimatedSwitcher(
          duration: OpeiBrand.motionFast,
          child: loading
              ? const SizedBox(
                  key: ValueKey('loader'),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Row(
                  key: const ValueKey('label'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (leadingIcon != null) ...[
                      Icon(leadingIcon, size: 18, color: foregroundColor),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (trailingIcon != null) ...[
                      const SizedBox(width: 8),
                      Icon(trailingIcon, size: 18, color: foregroundColor),
                    ],
                  ],
                ),
        ),
      ),
    );

    if (!expand) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

/// Subtle text-style secondary action used under primary CTAs.
class OpeiSecondaryLink extends StatelessWidget {
  final String label;
  final String? actionLabel;
  final VoidCallback onTap;

  const OpeiSecondaryLink({
    super.key,
    this.label = '',
    this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = TextStyle(
      fontFamily: kPrimaryFontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: OpeiBrand.inkSecondary,
      letterSpacing: -0.2,
    );
    final action = text.copyWith(
      color: OpeiBrand.primary,
      fontWeight: FontWeight.w600,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: RichText(
          text: TextSpan(
            style: text,
            children: [
              if (label.isNotEmpty) TextSpan(text: '$label '),
              TextSpan(text: actionLabel ?? '', style: action),
            ],
          ),
        ),
      ),
    );
  }
}
