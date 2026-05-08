import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const Duration kOpeiForwardTransitionDuration = Duration(milliseconds: 260);
const Duration kOpeiReverseTransitionDuration = Duration(milliseconds: 220);
const Curve kOpeiTransitionCurve = Curves.easeInOut;

/// Subtle fade + micro-slide transition. Barely noticeable movement keeps
/// the app feeling fast and premium without any dramatic swooping.
Widget buildOpeiPageTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  // Tiny 2% horizontal nudge — enough to give direction, not enough to feel
  // like a page flip.
  final slide = Tween<Offset>(
    begin: const Offset(0.025, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: animation, curve: kOpeiTransitionCurve));

  // Clean full-range fade over the whole duration.
  final fade = CurvedAnimation(
    parent: animation,
    curve: kOpeiTransitionCurve,
  );

  return FadeTransition(
    opacity: fade,
    child: SlideTransition(position: slide, child: child),
  );
}

/// Custom page route for Navigator.push usage.
class OpeiPageRoute<T> extends PageRouteBuilder<T> {
  OpeiPageRoute({
    required WidgetBuilder builder,
    super.fullscreenDialog,
    super.settings,
  }) : super(
          transitionDuration: kOpeiForwardTransitionDuration,
          reverseTransitionDuration: kOpeiReverseTransitionDuration,
          opaque: true,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              buildOpeiPageTransition(
                  context, animation, secondaryAnimation, child),
        );
}

/// GoRouter helper — uses the same slide+fade transition.
CustomTransitionPage<T> buildOpeiTransitionPage<T>({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: kOpeiForwardTransitionDuration,
    reverseTransitionDuration: kOpeiReverseTransitionDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        buildOpeiPageTransition(context, animation, secondaryAnimation, child),
  );
}

/// Theme bridge so Navigator routes inherit the same transition profile.
class OpeiPageTransitionsBuilder extends PageTransitionsBuilder {
  const OpeiPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      buildOpeiPageTransition(context, animation, secondaryAnimation, child);
}