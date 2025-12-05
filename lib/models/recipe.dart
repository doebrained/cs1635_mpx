class Recipe {
  final int id;
  final String title;
  final String imageUrl;
  final String summaryHtml;

  // Existing
  final bool isCeliacSafe;   // glutenFree
  final bool isLactoseFree;  // dairyFree

  // New
  final bool isVegetarian;   // vegetarian
  final bool isVegan;        // vegan
  final bool isKeto;         // ketogenic
  final bool isNutFree;      // you'll likely set this yourself

  const Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.summaryHtml,
    required this.isCeliacSafe,
    required this.isLactoseFree,
    required this.isVegetarian,
    required this.isVegan,
    required this.isKeto,
    required this.isNutFree,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // Spoonacular booleans are literally true/false, but we guard anyway
    bool asBool(dynamic value) => value == true;

    return Recipe(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      title: json['title'] ?? 'Untitled recipe',
      imageUrl: json['image'] ?? '',
      summaryHtml: json['summary'] ?? '',

      // existing
      isCeliacSafe: asBool(json['glutenFree']),
      isLactoseFree: asBool(json['dairyFree']),

      // new (Spoonacular fields)
      isVegetarian: asBool(json['vegetarian']),
      isVegan: asBool(json['vegan']),
      isKeto: asBool(json['ketogenic']), // Spoonacular uses "ketogenic"

      // Spoonacular doesn't give a direct "nutFree" flag; for now we just
      // read a custom field if you add it, otherwise default to false.
      isNutFree: asBool(json['nutFree']),
    );
  }
}
