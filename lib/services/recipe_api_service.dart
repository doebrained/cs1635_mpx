import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../api_config.dart';
import '../models/recipe.dart';

class RecipeApiService {
  final http.Client _client;
  static const Duration _httpTimeout = Duration(seconds: 10);

  RecipeApiService({http.Client? client}) : _client = client ?? http.Client();

  // Public method your ViewModel already calls
  Future<List<Recipe>> fetchRecipes({String query = ''}) async {
    return searchRecipesByName(query);
  }

  // Actual MealDB call with timeout and isolate parsing
  Future<List<Recipe>> searchRecipesByName(String query) async {
    final uri = Uri.parse('${ApiConfig.mealDbBaseUrl}/search.php?s=$query');

    try {
      final response = await _client
          .get(uri)
          .timeout(
            _httpTimeout,
            onTimeout: () => throw TimeoutException(
              'Recipe request timed out after ${_httpTimeout.inSeconds} seconds',
            ),
          );

      if (response.statusCode != 200) {
        throw Exception('Failed to load recipes (${response.statusCode})');
      }

      // Offload JSON parsing to isolate to prevent UI jank
      return compute(_parseRecipesIsolate, response.body);
    } on TimeoutException catch (e) {
      throw Exception('Network timeout: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }
}

/// Isolate function: Parses recipe JSON in background thread
/// Must be a top-level or static function
Future<List<Recipe>> _parseRecipesIsolate(String responseBody) async {
  final data = json.decode(responseBody) as Map<String, dynamic>;
  final meals = data['meals'];

  if (meals == null) {
    return [];
  }

  return (meals as List)
      .map((mealJson) => Recipe.fromJson(mealJson as Map<String, dynamic>))
      .toList();
}

