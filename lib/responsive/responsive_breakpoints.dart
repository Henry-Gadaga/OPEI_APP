import 'package:flutter/widgets.dart';

/// Normalized viewport categories that drive spacing, typography, and layout.
enum ResponsiveSize {
  compact,
  phone,
  largePhone,
  tabletDesktop,
}

/// Shared breakpoint logic so we only derive device classes from constraints,
/// never from platform-specific heuristics.
class ResponsiveBreakpoints {
  static const double _compactMax = 359;
  static const double _phoneMax = 599;
  static const double _largePhoneMax = 839;

  const ResponsiveBreakpoints._();

  static ResponsiveSize resolve(double width) {
    if (width <= _compactMax) {
      return ResponsiveSize.compact;
    }
    if (width <= _phoneMax) {
      return ResponsiveSize.phone;
    }
    if (width <= _largePhoneMax) {
      return ResponsiveSize.largePhone;
    }
    return ResponsiveSize.tabletDesktop;
  }

  static ResponsiveSize of(BuildContext context) {
    final media = MediaQuery.maybeOf(context);
    if (media != null) {
      return resolve(media.size.width);
    }

    // Fallback for contexts created before MediaQuery (e.g., during app boot).
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final logicalWidth = view.physicalSize.width / view.devicePixelRatio;
    return resolve(logicalWidth);
  }
}
