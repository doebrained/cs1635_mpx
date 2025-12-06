import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/saved_recipes_viewmodel.dart';
import 'navigation_drawer.dart';
import 'widgets/recipe_card.dart';
import 'widgets/recipe_detail_sheet.dart';
import 'widgets/fade_in_widget.dart';
import 'widgets/staggered_list_item.dart';

class SavedRecipesScreen extends StatelessWidget {
  const SavedRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SavedRecipesViewModel>();
    final saved = vm.savedRecipes;

    return Scaffold(
      drawer: const AppNavigationDrawer(currentRoute: '/saved'),
      appBar: AppBar(title: const Text("Saved Recipes")),
      body: saved.isEmpty
          ? const Center(
              child: Text(
                "You haven't saved any recipes yet.\nSwipe right to save!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            )
          : FadeInWidget(
              duration: const Duration(milliseconds: 400),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: saved.length,
                itemBuilder: (context, index) {
                  final recipe = saved[index];

                  return StaggeredListItem(
                    index: index,
                    delay: Duration(milliseconds: 50 * index),
                    child: Semantics(
                      button: true,
                      label: 'Saved recipe: ${recipe.title}',
                      hint: 'Double tap to open details',
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SizedBox(
                          height: 300,
                          child: RecipeCard(
                            recipe: recipe,
                            onTap: () => showRecipeDetailSheet(context, recipe),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
