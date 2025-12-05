import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api_config.dart';
import '../models/recipe.dart';

class RecipeApiService {
  final http.Client _client;

  RecipeApiService({http.Client? client}) : _client = client ?? http.Client();

  // Public method your ViewModel already calls
  Future<List<Recipe>> fetchRecipes({String query = 'chicken'}) async {
    return searchRecipesByName(query);
  }

  // Actual MealDB call
  Future<List<Recipe>> searchRecipesByName(String query) async {
    final uri = Uri.parse(
      '${ApiConfig.mealDbBaseUrl}/search.php?s=$query',
    );

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load recipes (${response.statusCode})');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final meals = data['meals'];

    if (meals == null) {
      return [];
    }

    return (meals as List)
        .map((mealJson) => Recipe.fromJson(mealJson as Map<String, dynamic>))
        .toList();
  }
}
