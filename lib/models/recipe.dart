class Recipe {
  final String id;
  final String title;
  final String imageUrl;
  final String instructions;
  final String sourceUrl;
  final String area;
  final String category;
  final List<String> ingredients;

  Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.instructions,
    required this.sourceUrl,
    required this.area,
    required this.category,
    required this.ingredients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // Parse ingredient/measure pairs from TheMealDB
    final ingredients = <String>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient = (json['strIngredient$i'] ?? '').toString().trim();
      final measure = (json['strMeasure$i'] ?? '').toString().trim();

      if (ingredient.isNotEmpty &&
          ingredient.toLowerCase() != 'null') {
        final entry = (measure.isNotEmpty &&
                measure.toLowerCase() != 'null')
            ? '$ingredient — $measure'
            : ingredient;
        ingredients.add(entry);
      }
    }

    return Recipe(
      id: json['idMeal'] ?? '',
      title: json['strMeal'] ?? '',
      imageUrl: json['strMealThumb'] ?? '',
      instructions: json['strInstructions'] ?? '',
      sourceUrl: json['strSource'] ?? '',
      area: json['strArea'] ?? '',
      category: json['strCategory'] ?? '',
      ingredients: ingredients,
    );
  }

  /// --- Allergen Detection ---

  bool get isCeliacSafe {
    final text = (ingredients.join(' ') + ' ' + instructions).toLowerCase();

    // Confirmed safe keywords
    const safeHints = ['gluten free', 'gluten-free', 'gf'];
    if (safeHints.any((k) => text.contains(k))) return true;

    // Common gluten-containing ingredients
    const glutenKeywords = [
      'wheat',
      'barley',
      'rye',
      'malt',
      'semolina',
      'spelt',
      'farro',
      'bulgur',
      'couscous',
      'flour',
      'bread',
      'pasta',
      'noodles',
      'breadcrumbs',
      'cracker',
      'tortilla',
    ];

    if (glutenKeywords.any((k) => text.contains(k))) return false;

    return true; // Default: assume safe
  }

  bool get isLactoseFree {
    final text = (ingredients.join(' ') + ' ' + instructions).toLowerCase();

    const dairyKeywords = [
      'milk',
      'cream',
      'cheese',
      'parmesan',
      'mozzarella',
      'cheddar',
      'butter',
      'yogurt',
      'custard',
      'sour cream',
      'whipped cream',
      'ghee',
    ];

    const safeHints = [
      'dairy free',
      'dairy-free',
      'lactose free',
      'lactose-free',
      'vegan',
    ];
    if (safeHints.any((k) => text.contains(k))) return true;

    if (dairyKeywords.any((k) => text.contains(k))) return false;

    return true;
  }

  /// --- Summary used in your UI (ingredients + instructions) ---
  String get summary {
    final ingPart = ingredients.isNotEmpty
        ? 'Ingredients: ${ingredients.take(4).join(', ')}'
            '${ingredients.length > 4 ? '...' : ''}'
        : '';

    final instructPart = instructions.isNotEmpty
        ? 'Instructions: ${instructions.split('.').first.trim()}.'
        : '';

    if (ingPart.isNotEmpty && instructPart.isNotEmpty) {
      return '$ingPart\n$instructPart';
    }
    return ingPart.isNotEmpty ? ingPart : instructPart;
  }
}
