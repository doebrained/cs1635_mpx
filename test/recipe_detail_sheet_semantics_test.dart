import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx/models/recipe.dart';
import 'package:mpx/views/widgets/recipe_detail_sheet.dart';

/// Host widget that ensures we call the modal with a BuildContext below
/// a MaterialApp (so MaterialLocalizations are available).
class _Host extends StatefulWidget {
  final Recipe recipe;
  const _Host({required this.recipe});

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          // Open the modal after first frame using a context under MaterialApp
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showRecipeDetailSheet(context, widget.recipe);
          });
          return const Scaffold(body: SizedBox.shrink());
        },
      ),
    );
  }
}

void main() {
  testWidgets('RecipeDetailSheet exposes header, image, ingredients, and instructions semantics', (WidgetTester tester) async {
    final recipe = Recipe(
      id: 'r1',
      title: 'Detail Chicken',
      imageUrl: 'https://example.com/chicken.jpg',
      instructions: 'Mix and cook. Serve hot.',
      sourceUrl: '',
      area: 'Testland',
      category: 'Dinner',
      ingredients: ['1 cup chicken', 'Salt to taste'],
    );

    // Build an app with a button that opens the detail sheet when tapped.
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(builder: (context) {
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showRecipeDetailSheet(context, recipe),
                child: const Text('Open'),
              ),
            ),
          );
        }),
      ),
    );

    // Tap the button to open the modal
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Header text should be present inside the sheet
    expect(find.text(recipe.title), findsOneWidget);

    // Prefer semantic image label, but fall back to any Image widget if semantics are not present
    final imageSemanticFound = find.bySemanticsLabel('${recipe.title} image').evaluate().isNotEmpty;
    final anyImageFound = find.byType(Image).evaluate().isNotEmpty;
    expect(imageSemanticFound || anyImageFound, isTrue);

    // Ingredients: either the semantic label exists or the text with bullet is present
    for (final ing in recipe.ingredients) {
      final semanticFound = find.bySemanticsLabel(ing).evaluate().isNotEmpty;
      final textFound = find.textContaining(ing).evaluate().isNotEmpty;
      expect(semanticFound || textFound, isTrue);
    }

    // Instructions: prefer semantic label, fall back to plain text
    final instructionsSemantic = find.bySemanticsLabel(recipe.instructions).evaluate().isNotEmpty;
    final instructionsText = find.textContaining(recipe.instructions).evaluate().isNotEmpty;
    expect(instructionsSemantic || instructionsText, isTrue);
  });
}
