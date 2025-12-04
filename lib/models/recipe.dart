class Recipe {
  final int id;
  final String title;
  final String imageUrl;
  final String summaryHtml;
  final bool isCeliacSafe;   // glutenFree
  final bool isLactoseFree;  // dairyFree

  const Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.summaryHtml,
    required this.isCeliacSafe,
    required this.isLactoseFree,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      title: json['title'] ?? 'Untitled recipe',
      imageUrl: json['image'] ?? '',              // THIS MUST MATCH API FIELD
      summaryHtml: json['summary'] ?? '',
      isCeliacSafe: json['glutenFree'] ?? false,  // from Spoonacular
      isLactoseFree: json['dairyFree'] ?? false,  // from Spoonacular
    );
  }
}
