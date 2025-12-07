import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/recipe.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;

  const RecipeCard({super.key, required this.recipe, this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        label: recipe.title,
        hint: 'Open recipe details',
        button: onTap != null,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar with title + tags
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (recipe.isCeliacSafe) _TagChip(label: 'Gluten-free'),
                        if (recipe.isLactoseFree) _TagChip(label: 'Dairy-free'),
                        if (recipe.isVegetarian) _TagChip(label: 'Vegetarian'),
                        if (recipe.isVegan) _TagChip(label: 'Vegan'),
                        if (recipe.isNutFree) _TagChip(label: 'Nut-free'),
                        if (recipe.isKosher) _TagChip(label: 'Kosher'),
                        if (recipe.isHalal) _TagChip(label: 'Halal'),
                      ],
                    ),
                  ],
                ),
              ),

              // Image area
              Expanded(
                child: recipe.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        child: Image.network(
                          recipe.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          semanticLabel: '${recipe.title} image',
                          errorBuilder: (_, __, ___) => _ImagePlaceholder(),
                        ),
                      )
                    : const _ImagePlaceholder(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Chip(
      label: Text(
        label,
        style: textTheme.labelMedium?.copyWith(
          color: AccessibleColors.primary,
        ),
      ),
      backgroundColor: AccessibleColors.primaryLightest,
      side: BorderSide(color: AccessibleColors.primary, width: 1.5),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.restaurant, size: 40, color: Colors.grey),
    );
  }
}
