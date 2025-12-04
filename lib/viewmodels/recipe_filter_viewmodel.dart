import 'package:flutter/foundation.dart';

import '../models/recipe.dart';
import '../services/recipe_api_service.dart';

class RecipeFilterViewModel extends ChangeNotifier {
  final RecipeApiService _apiService;

  RecipeFilterViewModel({RecipeApiService? apiService})
      : _apiService = apiService ?? RecipeApiService();

  bool _celiacOnly = false;
  bool _lactoseOnly = false;

  bool get celiacOnly => _celiacOnly;
  bool get lactoseOnly => _lactoseOnly;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Recipe> _allRecipes = [];
  List<Recipe> get allRecipes => _allRecipes;

  List<Recipe> get filteredRecipes {
    return _allRecipes.where((r) {
      if (_celiacOnly && !r.isCeliacSafe) return false;
      if (_lactoseOnly && !r.isLactoseFree) return false;
      return true;
    }).toList();
  }

  final List<Recipe> likedRecipes = [];

  void toggleCeliacOnly(bool value) {
    _celiacOnly = value;
    notifyListeners();
  }

  void toggleLactoseOnly(bool value) {
    _lactoseOnly = value;
    notifyListeners();
  }

  void like(Recipe recipe) {
    if (!likedRecipes.contains(recipe)) {
      likedRecipes.add(recipe);
      notifyListeners();
    }
  }

  Future<void> loadRecipes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final recipes = await _apiService.fetchRecipes();
      _allRecipes = recipes;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
