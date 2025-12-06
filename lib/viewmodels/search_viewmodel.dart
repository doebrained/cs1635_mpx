import 'package:flutter/foundation.dart';
import '../models/recipe.dart';

class SearchViewModel extends ChangeNotifier {
  final List<Recipe> _allRecipes;
  String _query = "";

  SearchViewModel({required List<Recipe> allRecipes})
      : _allRecipes = allRecipes;

  String get query => _query;

  List<Recipe> get searchResults {
    if (_query.isEmpty) {
      return [];
    }
    return _allRecipes
        .where((r) =>
            r.title.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  void updateQuery(String newQuery) {
    _query = newQuery;
    notifyListeners();
  }

  void clearQuery() {
    _query = "";
    notifyListeners();
  }
}
