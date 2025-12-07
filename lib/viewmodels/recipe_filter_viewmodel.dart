import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../services/recipe_api_service.dart';

class RecipeFilterViewModel extends ChangeNotifier {
  final RecipeApiService _apiService;

  RecipeFilterViewModel({RecipeApiService? apiService})
      : _apiService = apiService ?? RecipeApiService();

  // ---------------------------
  // FILTER STATES
  // ---------------------------
  bool _celiacOnly = false;
  bool _lactoseOnly = false;
  bool _vegetarianOnly = false;
  bool _veganOnly = false;
  bool _nutFreeOnly = false;
  bool _halalOnly = false;
  bool _kosherOnly = false;

  bool get celiacOnly => _celiacOnly;
  bool get lactoseOnly => _lactoseOnly;
  bool get vegetarianOnly => _vegetarianOnly;
  bool get veganOnly => _veganOnly;
  bool get nutFreeOnly => _nutFreeOnly;
  bool get halalOnly => _halalOnly;
  bool get kosherOnly => _kosherOnly;

  // ---------------------------
  // LOADING STATE
  // ---------------------------
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Recipe> _allRecipes = [];
  List<Recipe> get allRecipes => _allRecipes;

  // ---------------------------
  // FILTERED LIST
  // ---------------------------
  List<Recipe> get filteredRecipes {
    return _allRecipes.where((r) {
      if (_celiacOnly && !r.isCeliacSafe) return false;
      if (_lactoseOnly && !r.isLactoseFree) return false;
      if (_vegetarianOnly && !r.isVegetarian) return false;
      if (_veganOnly && !r.isVegan) return false;
      if (_nutFreeOnly && !r.isNutFree) return false;
      if (_halalOnly && !r.isHalal) return false;
      if (_kosherOnly && !r.isKosher) return false;
      return true;
    }).toList();
  }

  final List<Recipe> likedRecipes = [];

  // ---------------------------
  // TOGGLES
  // ---------------------------
  void toggleCeliacOnly(bool v) { _celiacOnly = v; notifyListeners(); }
  void toggleLactoseOnly(bool v) { _lactoseOnly = v; notifyListeners(); }
  void toggleVegetarian(bool v) { _vegetarianOnly = v; notifyListeners(); }
  void toggleVegan(bool v) { _veganOnly = v; notifyListeners(); }
  void toggleNutFree(bool v) { _nutFreeOnly = v; notifyListeners(); }
  void toggleHalal(bool v) { _halalOnly = v; notifyListeners(); }
  void toggleKosher(bool v) { _kosherOnly = v; notifyListeners(); }

  // ---------------------------
  // LIKE / REJECT
  // ---------------------------
  void like(Recipe recipe) {
    if (!likedRecipes.contains(recipe)) {
      likedRecipes.add(recipe);
      notifyListeners();
    }
  }

  void reject(Recipe recipe) {
    notifyListeners();
  }

  // ---------------------------
  // LOAD RECIPES
  // ---------------------------
  Future<void> loadRecipes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allRecipes = await _apiService.fetchRecipes();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retryLoadRecipes() async => loadRecipes();
}
