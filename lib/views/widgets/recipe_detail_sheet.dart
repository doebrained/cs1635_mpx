import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/recipe.dart';
import 'fade_in_widget.dart';

Future<T?> showRecipeDetailSheet<T>(BuildContext context, Recipe recipe) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _RecipeDetailSheet(recipe: recipe),
  );
}

class _RecipeDetailSheet extends StatelessWidget {
  final Recipe recipe;
  const _RecipeDetailSheet({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return FadeInWidget(
      duration: const Duration(milliseconds: 400),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AccessibleColors.divider,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Semantics(
                  header: true,
                  child: Text(
                    recipe.title,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (recipe.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      recipe.imageUrl,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      semanticLabel: '${recipe.title} image',
                      errorBuilder: (_, __, ___) => Container(
                        color: AccessibleColors.surfaceLight,
                        height: 250,
                        child: Center(
                          child: Icon(
                            Icons.restaurant,
                            color: AccessibleColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 250,
                    color: AccessibleColors.surfaceLight,
                    child: Center(
                      child: Icon(
                        Icons.restaurant,
                        color: AccessibleColors.textTertiary,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (recipe.area.isNotEmpty)
                      Text(
                        'Area: ${recipe.area}',
                        style: textTheme.bodyMedium,
                      ),
                    if (recipe.area.isNotEmpty && recipe.category.isNotEmpty)
                      const SizedBox(width: 12),
                    if (recipe.category.isNotEmpty)
                      Text(
                        'Category: ${recipe.category}',
                        style: textTheme.bodyMedium,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Semantics(
                  header: true,
                  child: Text(
                    'Ingredients',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...recipe.ingredients.map(
                  (ing) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Semantics(
                      label: ing,
                      child: Text(
                        '• $ing',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  header: true,
                  child: Text(
                    'Instructions',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Semantics(
                  label: recipe.instructions,
                  child: Text(
                    recipe.instructions,
                    style: textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
