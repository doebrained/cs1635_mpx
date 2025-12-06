import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mpx/views/recipe_filter_screen.dart';
import 'package:mpx/viewmodels/recipe_filter_viewmodel.dart';
import 'package:mpx/models/recipe.dart';
import 'package:mpx/services/recipe_api_service.dart';

class _MockApi extends RecipeApiService {
  final List<Recipe> _recipes;
  _MockApi(this._recipes) : super();

  @override
  Future<List<Recipe>> fetchRecipes({String query = 'chicken'}) async {
    return _recipes;
  }
}

void main() {
  testWidgets('RecipeFilterScreen exposes filter switches and action button semantics', (WidgetTester tester) async {
    final recipe = Recipe(
      id: 'r2',
      title: 'Filter Chicken',
      imageUrl: '',
      instructions: '',
      sourceUrl: '',
      area: '',
      category: '',
      ingredients: const [],
    );

    final mockApi = _MockApi([recipe]);
    final vm = RecipeFilterViewModel(apiService: mockApi);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<RecipeFilterViewModel>.value(value: vm),
        ],
        child: const MaterialApp(home: RecipeFilterScreen()),
      ),
    );

    // Dietary switches should always be visible
    expect(find.bySemanticsLabel('Celiac-safe only'), findsWidgets);
    expect(find.bySemanticsLabel('Lactose-free only'), findsWidgets);
  });
}
