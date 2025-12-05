import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import '../viewmodels/recipe_filter_viewmodel.dart';
import '../models/recipe.dart';
import 'widgets/recipe_card.dart';
import 'widgets/app_drawer.dart';

class RecipeFilterScreen extends StatefulWidget {
  const RecipeFilterScreen({super.key});

  @override
  State<RecipeFilterScreen> createState() => _RecipeFilterScreenState();
}

class _RecipeFilterScreenState extends State<RecipeFilterScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<RecipeFilterViewModel>().loadRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecipeFilterViewModel>();
    final filtered = vm.filteredRecipes;

    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Swipe Recipes'),
      ),
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
              style: const TextStyle(fontSize: 14),
            ),
            const Divider(),

            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.errorMessage != null
                      ? Center(child: Text("⚠️ Error: ${vm.errorMessage}"))
                      : filtered.isEmpty
                          ? const Center(
                              child: Text(
                                'No recipes match your filters.\nTry changing them!',
                                textAlign: TextAlign.center,
                              ),
                            )
                          : _SwipeDeck(recipes: filtered),
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
  int _currentIndex = 0;

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
            cardBuilder: (context, index, _, __) {
              _currentIndex = index;
              return RecipeCard(recipe: widget.recipes[index]);
            },
            onSwipe: (previousIndex, currentIndex, direction) {
              final recipe = widget.recipes[previousIndex];

              if (direction == CardSwiperDirection.right) {
                vm.like(recipe);
              } else if (direction == CardSwiperDirection.top) {
                _showDetails(context, recipe);
                _controller.undo();
              }

              setState(() {
                _currentIndex = currentIndex ?? widget.recipes.length;
              });

              return true;
            },
          ),
        ),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize: 40,
              icon: const Icon(Icons.close, color: Colors.redAccent),
              onPressed: () => _controller.swipe(CardSwiperDirection.left),
            ),
            const SizedBox(width: 24),
            IconButton(
              iconSize: 36,
              icon: const Icon(Icons.arrow_upward),
              onPressed: () {
                if (_currentIndex < widget.recipes.length) {
                  _showDetails(context, widget.recipes[_currentIndex]);
                }
              },
            ),
            const SizedBox(width: 24),
            IconButton(
              iconSize: 40,
              icon: const Icon(Icons.favorite, color: Colors.pinkAccent),
              onPressed: () => _controller.swipe(CardSwiperDirection.right),
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
    builder: (_) {
      return DraggableScrollableSheet(
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
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Text(recipe.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Image.network(recipe.imageUrl, height: 250, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    height: 250,
                    child: const Center(child: Icon(Icons.restaurant)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(_stripHtmlTags(recipe.summaryHtml)),
              ],
            ),
          );
        },
      );
    },
  );
}

String _stripHtmlTags(String html) =>
    html.replaceAll(RegExp(r'<[^>]*>'), '');
