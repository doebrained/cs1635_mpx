class Recipe {
  final String title;
  final bool isCeliacSafe;   // gluten-free
  final bool isLactoseFree;  // dairy-free
  final String imageUrl;

  const Recipe({
    required this.title,
    required this.isCeliacSafe,
    required this.isLactoseFree,
    required this.imageUrl,
  });
}
