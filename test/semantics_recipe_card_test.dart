import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx/views/widgets/recipe_card.dart';
import 'package:mpx/models/recipe.dart';

void main() {
  testWidgets('RecipeCard exposes semantics label', (WidgetTester tester) async {
    final recipe = Recipe(
      id: '1',
      title: 'Test Chicken',
      imageUrl: '',
      instructions: 'Do things',
      sourceUrl: '',
      area: '',
      category: '',
      ingredients: ['1 cup chicken'],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecipeCard(recipe: recipe, onTap: () {}),
        ),
      ),
    );

    // Ensure semantics are generated
    final semantics = tester.getSemantics(find.byType(RecipeCard));
    expect(semantics.label, contains('Test Chicken'));
  });
}
