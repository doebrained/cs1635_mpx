import 'package:flutter/foundation.dart';
import '../models/recipe.dart';

class RecipeFilterViewModel extends ChangeNotifier {
  bool _celiacOnly = false;
  bool _lactoseOnly = false;

  bool get celiacOnly => _celiacOnly;
  bool get lactoseOnly => _lactoseOnly;

  // Index into the *filtered* list
  int _currentIndex = 0;

  // Base dataset (later this will come from your API)
  final List<Recipe> _allRecipes = const [
    Recipe(
      title: 'Gluten-Free Veggie Pasta',
      isCeliacSafe: true,
      isLactoseFree: true,
      imageUrl: 'https://picsum.photos/seed/pasta/600/400',
    ),
    Recipe(
      title: 'Creamy Mac and Cheese',
      isCeliacSafe: false,
      isLactoseFree: false,
      imageUrl: 'https://picsum.photos/seed/mac/600/400',
    ),
    Recipe(
      title: 'Grilled Chicken with Rice',
      isCeliacSafe: true,
      isLactoseFree: true,
      imageUrl: 'https://picsum.photos/seed/chicken/600/400',
    ),
    Recipe(
      title: 'Margherita Pizza',
      isCeliacSafe: false,
      isLactoseFree: false,
      imageUrl: 'https://picsum.photos/seed/pizza/600/400',
    ),
    Recipe(
      title: 'Fruit & Nut Breakfast Bowl',
      isCeliacSafe: true,
      isLactoseFree: false, // has dairy
      imageUrl: 'https://picsum.photos/seed/breakfast/600/400',
    ),
  ];

  /// Apply filters to the full list every time.
  List<Recipe> get filteredRecipes {
    return _allRecipes.where((recipe) {
      if (_celiacOnly && !recipe.isCeliacSafe) return false;
      if (_lactoseOnly && !recipe.isLactoseFree) return false;
      return true;
    }).toList();
  }

  /// Current top card based on filtered list + index.
  Recipe? get currentRecipe {
    final list = filteredRecipes;
    if (list.isEmpty) return null;
    if (_currentIndex >= list.length) return null;
    return list[_currentIndex];
  }

  /// Next card in stack, if any.
  Recipe? get nextRecipe {
    final list = filteredRecipes;
    if (list.isEmpty) return null;
    final nextIndex = _currentIndex + 1;
    if (nextIndex >= list.length) return null;
    return list[nextIndex];
  }

  /// Optional: store liked recipes.
  final List<Recipe> likedRecipes = [];

  void _advanceIndex() {
    final list = filteredRecipes;
    if (_currentIndex < list.length - 1) {
      _currentIndex++;
    } else {
      _currentIndex = list.length; // so currentRecipe becomes null
    }
    notifyListeners();
  }

  void swipeLeft() {
    // Skip
    _advanceIndex();
  }

  void swipeRight() {
    // Like
    final current = currentRecipe;
    if (current != null && !likedRecipes.contains(current)) {
      likedRecipes.add(current);
    }
    _advanceIndex();
  }

  void toggleCeliacOnly(bool value) {
    _celiacOnly = value;
    _currentIndex = 0; // reset deck whenever filters change
    notifyListeners();
  }

  void toggleLactoseOnly(bool value) {
    _lactoseOnly = value;
    _currentIndex = 0;
    notifyListeners();
  }
}
