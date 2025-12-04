import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import '../viewmodels/recipe_filter_viewmodel.dart';
import '../models/recipe.dart';
import 'widgets/recipe_card.dart';
import 'navigation_drawer.dart';

class RecipeFilterScreen extends StatefulWidget {
  const RecipeFilterScreen({super.key});

  @override
  State<RecipeFilterScreen> createState() => _RecipeFilterScreenState();
}

class _RecipeFilterScreenState extends State<RecipeFilterScreen> {
  @override
  void initState() {
    super.initState();
    // Load recipes from Spoonacular once when the screen is created
    Future.microtask(() {
      context.read<RecipeFilterViewModel>().loadRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecipeFilterViewModel>();
    final filtered = vm.filteredRecipes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Swipe Recipes'),
      ),
      drawer: const AppNavigationDrawer(currentRoute: '/'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dietary Filters',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Filters stacked vertically
            Column(
              children: [
                SwitchListTile(
                  title: const Text('Celiac-safe only (gluten-free)'),
                  value: vm.celiacOnly,
                  onChanged: vm.toggleCeliacOnly,
                ),
                SwitchListTile(
                  title: const Text('Lactose-free only'),
                  value: vm.lactoseOnly,
                  onChanged: vm.toggleLactoseOnly,
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              'Matching recipes: ${filtered.length}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),

            Expanded(
              child: Builder(
                builder: (context) {
                  if (vm.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (vm.errorMessage != null) {
                    return Center(
                      child: Text(
                        "⚠️ Error: ${vm.errorMessage}",
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No recipes match your filters.\nTry changing them!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  return _SwipeDeck(recipes: filtered);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _SwipeDeck extends StatefulWidget {
  final List<Recipe> recipes;
  const _SwipeDeck({required this.recipes});

  @override
  State<_SwipeDeck> createState() => _SwipeDeckState();
}

class _SwipeDeckState extends State<_SwipeDeck> {
  final CardSwiperController _controller = CardSwiperController();
  int _currentIndex = 0; // index of the card currently on top

  @override
  Widget build(BuildContext context) {
    final vm = context.read<RecipeFilterViewModel>();

    return Column(
      children: [
        Expanded(
          child: CardSwiper(
            controller: _controller,
            cardsCount: widget.recipes.length,
            isLoop: false,
            allowedSwipeDirection: const AllowedSwipeDirection.only(
              left: true,
              right: true,
              up: true,
            ),
            cardBuilder: (context, index, hThreshold, vThreshold) {
              // IMPORTANT: don't update _currentIndex here
              // This builder can be called for multiple indices
              return RecipeCard(recipe: widget.recipes[index]);
            },
            onSwipe: (previousIndex, currentIndex, direction) {
              final recipe = widget.recipes[previousIndex];

              if (direction == CardSwiperDirection.right) {
                // Like current card and move to next
                vm.like(recipe);
                setState(() {
                  _currentIndex = currentIndex ?? widget.recipes.length;
                });
                return true; // accept swipe
              }

              if (direction == CardSwiperDirection.left) {
                // Skip current card and move to next
                setState(() {
                  _currentIndex = currentIndex ?? widget.recipes.length;
                });
                return true; // accept swipe
              }

              if (direction == CardSwiperDirection.top) {
                // Show details but DO NOT advance the deck
                _showDetails(context, recipe);
                return false; // reject swipe, card snaps back
              }

              return true;
            },
          ),
        ),
        const SizedBox(height: 12),

        // Controls row: X, Up (details), Heart
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize: 40,
              icon: const Icon(Icons.close, color: Colors.redAccent),
              onPressed: () {
                _controller.swipe(CardSwiperDirection.left);
              },
            ),
            const SizedBox(width: 24),
            IconButton(
              iconSize: 36,
              icon: const Icon(Icons.arrow_upward),
              onPressed: () {
                if (_currentIndex >= 0 &&
                    _currentIndex < widget.recipes.length) {
                  final recipe = widget.recipes[_currentIndex];
                  _showDetails(context, recipe);
                }
              },
            ),
            const SizedBox(width: 24),
            IconButton(
              iconSize: 40,
              icon: const Icon(Icons.favorite, color: Colors.pinkAccent),
              onPressed: () {
                _controller.swipe(CardSwiperDirection.right);
              },
            ),
          ],
        ),
      ],
    );
  }
}

void _showDetails(BuildContext context, Recipe recipe) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Text(
                  recipe.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    recipe.imageUrl,
                    fit: BoxFit.cover,
                    height: 250,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      height: 250,
                      alignment: Alignment.center,
                      child: const Icon(Icons.restaurant, size: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _DietTag(
                      label: recipe.isCeliacSafe
                          ? 'Gluten-free'
                          : 'Contains gluten',
                    ),
                    const SizedBox(width: 8),
                    _DietTag(
                      label: recipe.isLactoseFree
                          ? 'Dairy-free'
                          : 'Contains dairy',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _stripHtmlTags(recipe.summaryHtml),
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _DietTag extends StatelessWidget {
  final String label;
  const _DietTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.teal.shade50,
      side: BorderSide(color: Colors.teal.shade200),
    );
  }
}

/// Remove basic HTML tags from Spoonacular summary
String _stripHtmlTags(String html) {
  return html.replaceAll(RegExp(r'<[^>]*>'), '');
}
