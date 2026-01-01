import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Global helper that dismisses the on-screen keyboard when the user taps
/// outside the currently focused input, without stealing taps from other
/// interactive widgets.
class KeyboardDismissOnTap extends StatelessWidget {
  final Widget child;

  const KeyboardDismissOnTap({super.key, required this.child});

  bool _isTappingEditable(PointerDownEvent event) {
    final binding = RendererBinding.instance;
    if (binding.renderViews.isEmpty) {
      return false;
    }
    final renderObject = binding.renderViews.first;
    final result = HitTestResult();
    renderObject.hitTest(result, position: event.position);
    for (final entry in result.path) {
      final target = entry.target;
      if (target is RenderEditable) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (PointerDownEvent event) {
        final focus = FocusManager.instance.primaryFocus;
        if (focus == null || !focus.hasPrimaryFocus) {
          return;
        }

        if (_isTappingEditable(event)) {
          return;
        }

        final focusContext = focus.context;
        if (focusContext == null) {
          focus.unfocus();
          return;
        }

        final renderObject = focusContext.findRenderObject();
        if (renderObject is! RenderBox || !renderObject.attached) {
          focus.unfocus();
          return;
        }

        final topLeft = renderObject.localToGlobal(Offset.zero);
        final focusRect = topLeft & renderObject.size;

        if (!focusRect.contains(event.position)) {
          focus.unfocus();
        }
      },
      child: child,
    );
  }
}