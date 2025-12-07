import 'package:flutter_test/flutter_test.dart';

import 'package:mpx/viewmodels/search_viewmodel.dart';
import 'package:mpx/models/recipe.dart';

void main() {
  late SearchViewModel vm;

  // ------------------------------------------------------------
  // Sample Recipes (Valid for Your Model)
  // ------------------------------------------------------------
  final recipeSoup = Recipe(
    id: "1",
    title: "Chicken Soup",
    imageUrl: "http://example.com/soup.jpg",
    instructions: "Boil chicken and vegetables.",
    sourceUrl: "",
    area: "American",
    category: "Soup",
    ingredients: ["Chicken — 1 cup", "Carrots — 1", "Water — 2 cups"],
  );

  final recipeSalad = Recipe(
    id: "2",
    title: "Vegan Salad",
    imageUrl: "http://example.com/salad.jpg",
    instructions: "Mix vegetables and serve.",
    sourceUrl: "",
    area: "American",
    category: "Salad",
    ingredients: ["Lettuce", "Tomato", "Cucumber"],
  );

  setUp(() {
    vm = SearchViewModel(allRecipes: [recipeSoup, recipeSalad]);
  });

  // ------------------------------------------------------------
  // Test: updateQuery basic functionality
  // ------------------------------------------------------------
  test('updateQuery sets query, notifies, and filters results', () async {
    int notifyCount = 0;
    vm.addListener(() => notifyCount++);

    vm.updateQuery("soup");

    expect(vm.query, "soup");

    // compute() is async → wait for the isolate to finish
    await Future.delayed(const Duration(milliseconds: 60));

    expect(vm.searchResults.length, 1);
    expect(vm.searchResults.first.title, "Chicken Soup");
    expect(notifyCount, greaterThanOrEqualTo(2));
  });

  // ------------------------------------------------------------
  // Test: updateQuery with empty string clears search
  // ------------------------------------------------------------
  test('updateQuery("") clears results and notifies once', () {
    int listenerCalls = 0;
    vm.addListener(() => listenerCalls++);

    vm.updateQuery("");

    expect(vm.query, "");
    expect(vm.searchResults, isEmpty);
    expect(listenerCalls, 1);
  });

  // ------------------------------------------------------------
  // Test: clearQuery resets query & results
  // ------------------------------------------------------------
  test('clearQuery resets query and cached results', () async {
    vm.updateQuery("soup");

    await Future.delayed(const Duration(milliseconds: 60));

    expect(vm.searchResults.isNotEmpty, true);

    vm.clearQuery();

    expect(vm.query, "");
    expect(vm.searchResults, isEmpty);
  });

  // ------------------------------------------------------------
  // Test: older isolate results shouldn't overwrite new query
  // ------------------------------------------------------------
  test('newer query prevents older async results from applying', () async {
    // Trigger two updates quickly, forcing an outdated isolate response
    vm.updateQuery("ch");   // would match Chicken Soup
    vm.updateQuery("veg");  // updates to Vegan Salad

    await Future.delayed(const Duration(milliseconds: 80));

    expect(vm.query, "veg");
    expect(vm.searchResults.length, 1);
    expect(vm.searchResults.first.title, "Vegan Salad");
  });
}
