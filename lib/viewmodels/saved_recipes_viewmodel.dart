import 'package:flutter/foundation.dart';
import '../models/recipe.dart';

class SavedRecipesViewModel extends ChangeNotifier {
  final List<Recipe> _likedRecipes;

  SavedRecipesViewModel({required List<Recipe> likedRecipes})
    : _likedRecipes = likedRecipes;

  List<Recipe> get savedRecipes => List.unmodifiable(_likedRecipes);

  int get savedCount => _likedRecipes.length;

  bool get hasSavedRecipes => _likedRecipes.isNotEmpty;

  void removeSavedRecipe(Recipe recipe) {
    if (_likedRecipes.contains(recipe)) {
      _likedRecipes.remove(recipe);
      notifyListeners();
    }
  }

  void addSavedRecipe(Recipe recipe) {
    if (!_likedRecipes.contains(recipe)) {
      _likedRecipes.add(recipe);
      notifyListeners();
    }
  }
}
