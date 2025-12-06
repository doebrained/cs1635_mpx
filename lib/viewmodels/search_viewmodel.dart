import 'package:flutter/foundation.dart';
import '../models/recipe.dart';

class SearchViewModel extends ChangeNotifier {
  final List<Recipe> _allRecipes;
  String _query = "";
  List<Recipe> _cachedResults = [];

  SearchViewModel({required List<Recipe> allRecipes})
    : _allRecipes = allRecipes;

  String get query => _query;

  List<Recipe> get searchResults => _cachedResults;

  void updateQuery(String newQuery) {
    _query = newQuery;
    if (newQuery.isEmpty) {
      _cachedResults = [];
    } else {
      // Offload filtering to isolate for responsive UI
      _filterRecipesIsolate(newQuery);
    }
    notifyListeners();
  }

  void clearQuery() {
    _query = "";
    _cachedResults = [];
    notifyListeners();
  }

  /// Async isolate function to filter recipes without blocking UI
  Future<void> _filterRecipesIsolate(String query) async {
    try {
      final results = await compute(
        _filterRecipesHelper,
        _FilterParams(recipes: _allRecipes, query: query),
      );
      if (_query == query) {
        // Only update if query hasn't changed
        _cachedResults = results;
        notifyListeners();
      }
    } catch (e) {
      // Silently fail; keep previous results
    }
  }
}

/// Helper class to pass multiple parameters to isolate
class _FilterParams {
  final List<Recipe> recipes;
  final String query;
  _FilterParams({required this.recipes, required this.query});
}

/// Top-level isolate function: Filters recipes by query
Future<List<Recipe>> _filterRecipesHelper(_FilterParams params) async {
  final queryLower = params.query.toLowerCase();
  return params.recipes
      .where((r) => r.title.toLowerCase().contains(queryLower))
      .toList();
}
