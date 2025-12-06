import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mpx/views/search_screen.dart';
import 'package:mpx/viewmodels/search_viewmodel.dart';
import 'package:mpx/models/recipe.dart';

/// A top-level fake that extends the real ViewModel but overrides
/// getters so tests can control results deterministically.
class FakeSearchViewModel extends SearchViewModel {
  String _fakeQuery = '';
  List<Recipe> _fakeResults = [];

  FakeSearchViewModel() : super(allRecipes: []);

  @override
  String get query => _fakeQuery;

  @override
  List<Recipe> get searchResults => _fakeResults;

  void setResultsForQuery(String q, List<Recipe> results) {
    _fakeQuery = q;
    _fakeResults = results;
    notifyListeners();
  }

  @override
  void updateQuery(String newQuery) {
    // Not used in this fake; tests will call setResultsForQuery directly
  }
}

void main() {
  testWidgets('Search results expose semantics labels and hints', (WidgetTester tester) async {
    final glutenRecipe = Recipe(
      id: 's1',
      title: 'Gluten Chicken',
      imageUrl: '',
      instructions: 'This is gluten-free in instructions',
      sourceUrl: '',
      area: '',
      category: '',
      ingredients: const ['chicken'],
    );

    final wheatRecipe = Recipe(
      id: 's2',
      title: 'Wheat Bread',
      imageUrl: '',
      instructions: 'Contains wheat flour',
      sourceUrl: '',
      area: '',
      category: '',
      ingredients: const ['wheat flour'],
    );

    final fakeVm = FakeSearchViewModel();

    await tester.pumpWidget(
      ChangeNotifierProvider<SearchViewModel>.value(
        value: fakeVm,
        child: const MaterialApp(home: SearchScreen()),
      ),
    );

    // Simulate search results being available for the query
    fakeVm.setResultsForQuery('Gluten', [glutenRecipe]);

    // Allow UI to rebuild
    await tester.pumpAndSettle();

    // The search result item should expose semantics with the recipe title
    expect(find.bySemanticsLabel(glutenRecipe.title), findsWidgets);

    // Also confirm the hint corresponds to gluten-free wording for this recipe
    final semantics = tester.getSemantics(find.bySemanticsLabel(glutenRecipe.title));
    expect(semantics.hint, contains('Gluten-free'));
  });
}
