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
      // Exclude recipes that have already been interacted with
      if (likedRecipes.contains(r) || rejectedRecipes.contains(r)) {
        return false;
      }
      if (_celiacOnly && !r.isCeliacSafe) return false;
      if (_lactoseOnly && !r.isLactoseFree) return false;
      return true;
    }).toList();
  }

  final List<Recipe> likedRecipes = [];
  final List<Recipe> rejectedRecipes = [];
  bool _recipesLoaded = false;

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

  void reject(Recipe recipe) {
    if (!rejectedRecipes.contains(recipe)) {
      rejectedRecipes.add(recipe);
      notifyListeners();
    }
  }

  Future<void> loadRecipes() async {
    // Only load once; don't reload when returning to screen
    if (_recipesLoaded) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final recipes = await _apiService.fetchRecipes();
      _allRecipes = recipes;
      _recipesLoaded = true;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
