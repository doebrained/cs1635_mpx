import 'package:flutter/foundation.dart';

import '../models/recipe.dart';
import '../services/recipe_api_service.dart';

class RecipeFilterViewModel extends ChangeNotifier {
  final RecipeApiService _apiService;
  // int _retryCount = 0;
  // static const int _maxRetries = 3;

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
  // List<Recipe> _filteredRecipes = [];
  List<Recipe> get allRecipes => _allRecipes;

  //List<Recipe> get filteredRecipes => _filteredRecipes;
    List<Recipe> get filteredRecipes {
    return _allRecipes.where((r) {
      if (_celiacOnly && !r.isCeliacSafe) return false;
      if (_lactoseOnly && !r.isLactoseFree) return false;
      return true;
    }).toList();
  }

  final List<Recipe> likedRecipes = [];
  //final List<Recipe> rejectedRecipes = [];
  //bool _recipesLoaded = false;

  void toggleCeliacOnly(bool value) {
    _celiacOnly = value;
    //_recomputeFiltered();
    notifyListeners();
  }

  void toggleLactoseOnly(bool value) {
    _lactoseOnly = value;
    //_recomputeFiltered();
    notifyListeners();
  }

  void like(Recipe recipe) {
    if (!likedRecipes.contains(recipe)) {
      likedRecipes.add(recipe);
      //_recomputeFiltered();
      notifyListeners();
    }
  }

  // void reject(Recipe recipe) {
  //   if (!rejectedRecipes.contains(recipe)) {
  //     rejectedRecipes.add(recipe);
  //     _recomputeFiltered();
  //     notifyListeners();
  //   }
  // }

  /// Recompute filtered recipes using isolate
  // Future<void> _recomputeFiltered() async {
  //   try {
  //     final result = await compute(
  //       _filterRecipesIsolate,
  //       _FilterData(
  //         recipes: _allRecipes,
  //         liked: likedRecipes,
  //         rejected: rejectedRecipes,
  //         celiacOnly: _celiacOnly,
  //         lactoseOnly: _lactoseOnly,
  //       ),
  //     );
  //     _filteredRecipes = result;
  //     notifyListeners();
  //   } catch (e) {
  //     // Fallback to unfiltered if compute fails
  //     _filteredRecipes = _allRecipes;
  //   }
  // }

  Future<void> loadRecipes() async {
    // Only load once; don't reload when returning to screen
  //   if (_recipesLoaded) {
  //     return;
  //   }
  //   await _loadRecipesWithRetry();
  // }
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

//   /// Retry logic with exponential backoff
//   Future<void> _loadRecipesWithRetry() async {
//     _isLoading = true;
//     _errorMessage = null;
//     _retryCount = 0;
//     notifyListeners();

//     try {
//       final recipes = await _apiService.fetchRecipes();
//       _allRecipes = recipes;
//       _recipesLoaded = true;
//       await _recomputeFiltered();
//     } catch (e) {
//       _errorMessage = _formatErrorMessage(e);
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   /// Retry failed recipe load with exponential backoff
//   Future<void> retryLoadRecipes() async {
//     if (_retryCount >= _maxRetries) {
//       _errorMessage = 'Max retries reached. Please try again later.';
//       notifyListeners();
//       return;
//     }

//     _retryCount++;
//     final delayMs = (500 * (1 << (_retryCount - 1))).toInt(); // 500ms, 1s, 2s
//     await Future.delayed(Duration(milliseconds: delayMs));

//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       final recipes = await _apiService.fetchRecipes();
//       _allRecipes = recipes;
//       _recipesLoaded = true;
//       _retryCount = 0; // Reset on success
//       await _recomputeFiltered();
//     } catch (e) {
//       _errorMessage = _formatErrorMessage(e);
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   /// Format error messages for user display
//   String _formatErrorMessage(dynamic error) {
//     final message = error.toString();
//     if (message.contains('timeout') || message.contains('TimeoutException')) {
//       return 'Network timeout. Check your internet connection and try again.';
//     } else if (message.contains('SocketException')) {
//       return 'Failed to connect. Check your internet connection.';
//     } else if (message.contains('401') || message.contains('403')) {
//       return 'Access denied. Please try again later.';
//     } else if (message.contains('404')) {
//       return 'Recipe service unavailable.';
//     } else if (message.contains('500')) {
//       return 'Server error. Please try again later.';
//     } else {
//       return 'Failed to load recipes. Please try again.';
//     }
//   }
// }

// /// Helper class for isolate filtering
// class _FilterData {
//   final List<Recipe> recipes;
//   final List<Recipe> liked;
//   final List<Recipe> rejected;
//   final bool celiacOnly;
//   final bool lactoseOnly;

//   _FilterData({
//     required this.recipes,
//     required this.liked,
//     required this.rejected,
//     required this.celiacOnly,
//     required this.lactoseOnly,
//   });
// }

// /// Top-level isolate function: Filters recipes
// List<Recipe> _filterRecipesIsolate(_FilterData data) {
//   return data.recipes.where((r) {
//     // Exclude recipes that have already been interacted with
//     if (data.liked.contains(r) || data.rejected.contains(r)) {
//       return false;
//     }
//     if (data.celiacOnly && !r.isCeliacSafe) return false;
//     if (data.lactoseOnly && !r.isLactoseFree) return false;
//     return true;
//   }).toList();
// }
