import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const Duration kOpeiForwardTransitionDuration = Duration.zero;
const Duration kOpeiReverseTransitionDuration = Duration.zero;

/// Defines the default navigation transition used across the app.
Widget buildOpeiPageTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) =>
    child;

/// Custom page route that plugs into the Opei transition curve.
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
            context,
            animation,
            secondaryAnimation,
            child,
          ),
        );
}

/// GoRouter helper to build a page using the house transition.
NoTransitionPage<T> buildOpeiTransitionPage<T>({
  required GoRouterState state,
  required Widget child,
}) {
  return NoTransitionPage<T>(
    key: state.pageKey,
    child: child,
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
  ) {
    return buildOpeiPageTransition(
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }
}