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
    final ingredients = <String>[];

    // Parse ingredients from TheMealDB API (strIngredient1...20)
    for (int i = 1; i <= 20; i++) {
      final ing = (json["strIngredient$i"] ?? "").toString().trim();
      final measure = (json["strMeasure$i"] ?? "").toString().trim();

      if (ing.isNotEmpty && ing.toLowerCase() != "null") {
        ingredients.add(
          measure.isNotEmpty && measure.toLowerCase() != "null"
              ? "$ing — $measure"
              : ing,
        );
      }
    }

    return Recipe(
      id: json["idMeal"] ?? "",
      title: json["strMeal"] ?? "",
      imageUrl: json["strMealThumb"] ?? "",
      instructions: json["strInstructions"] ?? "",
      sourceUrl: json["strSource"] ?? "",
      area: json["strArea"] ?? "",
      category: json["strCategory"] ?? "",
      ingredients: ingredients,
    );
  }

  // ----------------------------
  // INTERNAL TEXT SEARCH HELPER
  // ----------------------------
  String get _fullText =>
      "${ingredients.join(' ').toLowerCase()} ${instructions.toLowerCase()}";

  // ----------------------------
  // GLUTEN / CELIAC SAFE
  // ----------------------------
  bool get isCeliacSafe {
    const safeHints = ["gluten free", "gluten-free", "gf"];
    if (safeHints.any(_fullText.contains)) return true;

    const glutenWords = [
      "wheat",
      "barley",
      "rye",
      "malt",
      "flour",
      "semolina",
      "couscous",
      "breadcrumbs",
      "noodles",
      "pasta",
      "cracker",
      "bread"
    ];

    return !glutenWords.any(_fullText.contains);
  }

  // ----------------------------
  // LACTOSE FREE
  // ----------------------------
  bool get isLactoseFree {
    const safeHints = [
      "lactose free",
      "lactose-free",
      "dairy free",
      "dairy-free",
      "vegan"
    ];
    if (safeHints.any(_fullText.contains)) return true;

    const dairyWords = [
      "milk",
      "cream",
      "cheese",
      "butter",
      "yogurt",
      "parmesan",
      "mozzarella",
      "cheddar",
      "custard",
      "sour cream",
      "ghee"
    ];

    return !dairyWords.any(_fullText.contains);
  }

  // ----------------------------
  // VEGETARIAN
  // ----------------------------
  bool get isVegetarian {
    // If vegan → automatically vegetarian
    if (isVegan) return true;

    const meatWords = [
      "chicken",
      "beef",
      "pork",
      "fish",
      "salmon",
      "shrimp",
      "crab",
      "lamb",
      "turkey",
      "bacon",
      "ham"
    ];

    return !meatWords.any(_fullText.contains);
  }

  // ----------------------------
  // VEGAN
  // ----------------------------
  bool get isVegan {
    const animalProducts = [
      "chicken",
      "beef",
      "pork",
      "fish",
      "egg",
      "milk",
      "cream",
      "cheese",
      "butter",
      "yogurt",
      "honey",
      "gelatin",
    ];

    return !animalProducts.any(_fullText.contains);
  }

  // ----------------------------
  // NUT FREE
  // ----------------------------
  bool get isNutFree {
    const nuts = [
      "almond",
      "peanut",
      "walnut",
      "cashew",
      "hazelnut",
      "pecan",
      "pistachio",
      "nut"
    ];

    return !nuts.any(_fullText.contains);
  }

  // ----------------------------
  // HALAL
  // ----------------------------
  bool get isHalal {
    const haramItems = [
      "pork",
      "bacon",
      "ham",
      "lard",
      "gelatin (non-halal)",
      "beer",
      "wine",
      "alcohol"
    ];

    // If any haram item exists → false
    return !haramItems.any(_fullText.contains);
  }

  // ----------------------------
  // KOSHER
  // ----------------------------
  bool get isKosher {
    const nonKosherSeafood = [
      "shrimp",
      "crab",
      "lobster",
      "clam",
      "oyster",
      "scallop"
    ];

    if (nonKosherSeafood.any(_fullText.contains)) return false;

    if (_fullText.contains("pork") || _fullText.contains("bacon")) {
      return false;
    }

    // Meat + dairy together breaks kosher
    if (_fullText.contains("meat") &&
        (_fullText.contains("milk") ||
         _fullText.contains("cheese") ||
         _fullText.contains("cream"))) {
      return false;
    }

    return true;
  }

  // ----------------------------
  // SUMMARY FOR UI
  // ----------------------------
  String get summary {
    final ing = ingredients.isNotEmpty
        ? "Ingredients: ${ingredients.take(4).join(', ')}${ingredients.length > 4 ? '...' : ''}"
        : "";
    final instr = instructions.isNotEmpty
        ? "Instructions: ${instructions.split('.').first.trim()}."
        : "";

    if (ing.isNotEmpty && instr.isNotEmpty) return "$ing\n$instr";
    return ing.isNotEmpty ? ing : instr;
  }
}
