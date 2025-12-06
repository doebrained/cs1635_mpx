import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mpx/views/saved_recipes_screen.dart';
import 'package:mpx/viewmodels/saved_recipes_viewmodel.dart';
import 'package:mpx/models/recipe.dart';

void main() {
  testWidgets('Saved recipes list exposes semantics for saved items', (WidgetTester tester) async {
    final recipe = Recipe(
      id: 'r1',
      title: 'Saved Chicken',
      imageUrl: '',
      instructions: '',
      sourceUrl: '',
      area: '',
      category: '',
      ingredients: const [],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SavedRecipesViewModel(likedRecipes: [recipe])),
        ],
        child: const MaterialApp(home: SavedRecipesScreen()),
      ),
    );

    // allow list layout/semantics to settle
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Saved recipe: Saved Chicken'), findsWidgets);
  });
}
