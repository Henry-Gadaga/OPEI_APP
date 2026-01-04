import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opei/responsive/responsive_widgets.dart';
import 'package:opei/theme.dart';

void main() {
  testWidgets(
      'ResponsiveScaffold constrains body width on tablet breakpoints',
      (tester) async {
    const bodyKey = ValueKey('responsive-body');

    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: MediaQuery(
          data: const MediaQueryData(size: Size(1000, 800)),
          child: const ResponsiveScaffold(
            body: SizedBox(
              key: bodyKey,
              width: double.infinity,
              height: 100,
            ),
          ),
        ),
      ),
    );

    final bodySize = tester.getSize(find.byKey(bodyKey));
    // Tablet tokens: max width 720 with 32px horizontal padding on each side.
    expect(bodySize.width, 720 - (32 * 2));
  });

  testWidgets('ResponsiveSheet caps sheet width on wide layouts',
      (tester) async {
    const sheetChildKey = ValueKey('responsive-sheet-child');

    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: MediaQuery(
          data: const MediaQueryData(size: Size(1200, 800)),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ResponsiveSheet(
              child: Container(
                key: sheetChildKey,
                height: 20,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    final sheetChildSize = tester.getSize(find.byKey(sheetChildKey));
    // Sheet max width 720 with 32px padding each side.
    expect(sheetChildSize.width, 720 - (32 * 2));
  });
}
