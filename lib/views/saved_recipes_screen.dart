import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/recipe_filter_viewmodel.dart';
import 'widgets/recipe_card.dart';
import 'widgets/recipe_detail_sheet.dart';

class SavedRecipesScreen extends StatelessWidget {
  const SavedRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecipeFilterViewModel>();
    final saved = vm.likedRecipes;

    return Scaffold(
      appBar: AppBar(title: const Text("Saved Recipes")),
      body: saved.isEmpty
          ? const Center(
              child: Text(
                "You haven't saved any recipes yet.\nSwipe right to save!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: saved.length,
              itemBuilder: (context, index) {
                final recipe = saved[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SizedBox(
                    height: 300,
                    child: RecipeCard(
                      recipe: recipe,
                      onTap: () => showRecipeDetailSheet(context, recipe),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

