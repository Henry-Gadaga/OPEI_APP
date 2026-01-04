import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:opei/theme.dart';

/// A unified success hero widget used across the app.
///
/// Displays the monochrome checkmark asset with a compact "Done" label
/// directly beneath it, matching the sleek Apple-style treatment used
/// in P2P trade success.
class SuccessHero extends StatelessWidget {
  /// Height of the checkmark SVG icon.
  final double iconHeight;

  /// Vertical gap between the icon and the label.
  final double gap;

  /// The label text shown under the icon. Defaults to 'Done'.
  final String label;

  const SuccessHero({
    super.key,
    this.iconHeight = 64,
    this.gap = 2,
    this.label = 'Done',
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/images/checkmark2.svg',
          height: iconHeight,
          fit: BoxFit.contain,
        ),
        SizedBox(height: gap),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: OpeiColors.pureBlack,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
