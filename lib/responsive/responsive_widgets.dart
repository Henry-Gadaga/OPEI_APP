import 'package:flutter/material.dart';

import 'responsive_breakpoints.dart';
import 'responsive_tokens.dart';

class ResponsiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Color? backgroundColor;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final bool useSafeArea;
  final EdgeInsetsGeometry? padding;

  const ResponsiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.useSafeArea = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.responsiveTokens;
    final horizontal =
        padding ?? EdgeInsets.symmetric(horizontal: tokens.horizontalPadding);

    Widget content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
        child: Padding(
          padding: horizontal,
          child: body,
        ),
      ),
    );

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      body: content,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      floatingActionButtonAnimator: floatingActionButtonAnimator,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
    );
  }
}

class ResponsiveSheet extends StatelessWidget {
  final Widget child;
  final double? maxWidthOverride;
  final EdgeInsetsGeometry? padding;

  const ResponsiveSheet({
    super.key,
    required this.child,
    this.maxWidthOverride,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.responsiveTokens;
    final width = maxWidthOverride ?? tokens.sheetMaxWidth;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width),
          child: Container(
            margin: const EdgeInsets.only(top: 12),
            padding: padding ??
                EdgeInsets.symmetric(horizontal: tokens.horizontalPadding),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

Future<T?> showResponsiveBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool useRootNavigator = true,
  Color barrierColor = const Color(0x59000000),
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    barrierColor: barrierColor,
    builder: (sheetContext) => ResponsiveSheet(child: builder(sheetContext)),
  );
}

class ResponsiveSliverGridDelegate
    extends SliverGridDelegateWithFixedCrossAxisCount {
  ResponsiveSliverGridDelegate({
    required BuildContext context,
    double maxChildAspectRatio = 1.0,
    super.mainAxisSpacing = 12,
    super.crossAxisSpacing = 12,
  }) : super(
          crossAxisCount: _columnsFor(context),
          childAspectRatio: maxChildAspectRatio,
        );

  static int _columnsFor(BuildContext context) {
    final size = context.responsiveSize;
    switch (size) {
      case ResponsiveSize.tabletDesktop:
        return 3;
      case ResponsiveSize.largePhone:
        return 2;
      default:
        return 1;
    }
  }
}
