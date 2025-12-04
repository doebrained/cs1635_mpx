// lib/services/recipe_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

// Use the package-style import since your package is called "mpx"
import 'package:mpx/api_config.dart';

import '../models/recipe.dart';

class RecipeApiService {
  final http.Client _client;

  RecipeApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Recipe>> fetchRecipes() async {
    final uri = Uri.parse(
      '${ApiConfig.spoonacularBaseUrl}/recipes/complexSearch',
    ).replace(
      queryParameters: {
        'apiKey': ApiConfig.spoonacularApiKey,
        'number': '20',
        'addRecipeInformation': 'true',
        'instructionsRequired': 'true',
      },
    );

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load recipes: ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    final Map<String, dynamic> decoded = json.decode(response.body);
    final List<dynamic> results = decoded['results'] ?? [];

    return results
        .map((item) => Recipe.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
