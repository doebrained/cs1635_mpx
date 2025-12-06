import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx/views/navigation_drawer.dart';

void main() {
  testWidgets('Navigation drawer exposes semantics labels', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppNavigationDrawer(currentRoute: '/'),
        ),
      ),
    );

    // allow layout/semantics to settle
    await tester.pumpAndSettle();

    // The drawer items should expose semantics labels matching their text
    expect(find.bySemanticsLabel('Recipe Cards'), findsWidgets);
    expect(find.bySemanticsLabel('Search'), findsWidgets);
    expect(find.bySemanticsLabel('Saved Recipes'), findsWidgets);
  });
}
