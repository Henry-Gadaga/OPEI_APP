import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const Duration kOpeiForwardTransitionDuration = Duration(milliseconds: 300);
const Duration kOpeiReverseTransitionDuration = Duration(milliseconds: 240);

/// Defines the default navigation transition used across the app.
Widget buildOpeiPageTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final theme = Theme.of(context);

  final direction = Directionality.of(context) == TextDirection.rtl ? -1.0 : 1.0;

  final slideCurve = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  final slideTween = Tween<Offset>(
    begin: Offset(direction, 0),
    end: Offset.zero,
  );

  final slideAnimation = slideTween.animate(slideCurve);

  final shadowTween = Tween<double>(begin: 0.18, end: 0.0).animate(slideCurve);

  return Stack(
    children: [
      // Keep a solid backdrop so the previous screen never peeks through.
      Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
        ),
      ),
      ClipRect(
        child: SlideTransition(
          position: slideAnimation,
          child: AnimatedBuilder(
            animation: shadowTween,
            builder: (context, content) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: shadowTween.value),
                      blurRadius: 22,
                      spreadRadius: -8,
                      offset: Offset(direction * 6, 0),
                    ),
                  ],
                ),
                child: content,
              );
            },
            child: child,
          ),
        ),
      ),
    ],
  );
}

/// Custom page route that plugs into the Opei transition curve.
class OpeiPageRoute<T> extends PageRouteBuilder<T> {
  OpeiPageRoute({
    required WidgetBuilder builder,
    bool fullscreenDialog = false,
    RouteSettings? settings,
  }) : super(
          transitionDuration: kOpeiForwardTransitionDuration,
          reverseTransitionDuration: kOpeiReverseTransitionDuration,
          fullscreenDialog: fullscreenDialog,
          opaque: true,
          settings: settings,
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
        buildOpeiPageTransition(
      context,
      animation,
      secondaryAnimation,
      child,
    ),
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