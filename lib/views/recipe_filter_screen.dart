import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import '../theme/app_theme.dart';import '../viewmodels/recipe_filter_viewmodel.dart';
import '../models/recipe.dart';
import 'widgets/recipe_card.dart';
import 'navigation_drawer.dart';
import 'widgets/recipe_detail_sheet.dart';
import 'widgets/fade_in_widget.dart';
import 'widgets/snackstack_header.dart'; // ⭐ NEW IMPORT

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
      drawer: const AppNavigationDrawer(currentRoute: '/'),

      // ⭐ UPDATED HEADER
      appBar: AppBar(
        centerTitle: true,
        title: const SnackStackHeader(),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dietary Filters',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Column(
              children: [
                Semantics(
                  container: true,
                  label: 'Celiac-safe only',
                  hint: 'Toggle to show gluten-free recipes only',
                  child: SwitchListTile(
                    title: const Text('Celiac-safe only (gluten-free)'),
                    value: vm.celiacOnly,
                    onChanged: vm.toggleCeliacOnly,
                  ),
                ),
                Semantics(
                  container: true,
                  label: 'Lactose-free only',
                  hint: 'Toggle to show lactose-free recipes only',
                  child: SwitchListTile(
                    title: const Text('Lactose-free only'),
                    value: vm.lactoseOnly,
                    onChanged: vm.toggleLactoseOnly,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'Matching recipes: ${filtered.length}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const Divider(),

            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.errorMessage != null
                      ? FadeInWidget(
                          duration: const Duration(milliseconds: 400),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline,
                                    size: 48, color: Colors.red),
                                const SizedBox(height: 16),
                                Text(
                                  vm.errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 24),
                                _ScaleButtonOnTap(
                                  onPressed: () => vm.retryLoadRecipes(),
                                  child: ElevatedButton.icon(
                                    onPressed: null,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Retry'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : filtered.isEmpty
                          ? Center(
                              child: Text(
                                'No recipes match your filters.\nTry changing them!',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            )
                          : FadeInWidget(
                              duration: const Duration(milliseconds: 600),
                              child: _SwipeDeck(recipes: filtered),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScaleButtonOnTap extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  const _ScaleButtonOnTap({required this.onPressed, required this.child});

  @override
  State<_ScaleButtonOnTap> createState() => _ScaleButtonOnTapState();
}

class _ScaleButtonOnTapState extends State<_ScaleButtonOnTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown() async => await _controller.forward();
  void _handleTapUp() async {
    await _controller.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Retry loading recipes',
      hint: 'Retries fetching recipes from the server',
      child: GestureDetector(
        onTapDown: (_) => _handleTapDown(),
        onTapUp: (_) => _handleTapUp(),
        onTapCancel: _handleTapCancel,
        child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
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
              return RecipeCard(recipe: widget.recipes[index]);
            },
            onSwipe: (previousIndex, currentIndex, direction) {
              final recipe = widget.recipes[previousIndex];

              if (direction == CardSwiperDirection.right) {
                vm.like(recipe);
              } else if (direction == CardSwiperDirection.left) {
                vm.reject(recipe);
              } else if (direction == CardSwiperDirection.top) {
                showRecipeDetailSheet(context, recipe);
                _controller.undo();
              }

              setState(() {
                if (direction == CardSwiperDirection.top) {
                  _currentIndex = previousIndex;
                } else {
                  _currentIndex = currentIndex ?? widget.recipes.length;
                }
              });

              return true;
            },
          ),
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              button: true,
              label: 'Reject recipe',
              child: IconButton(
                iconSize: 40,
                icon: Icon(Icons.close,
                    color: Theme.of(context).colorScheme.error),
                onPressed: () =>
                    _controller.swipe(CardSwiperDirection.left),
              ),
            ),
            const SizedBox(width: 24),
            Semantics(
              button: true,
              label: 'Show details',
              child: IconButton(
                iconSize: 36,
                icon: Icon(Icons.arrow_upward,
                    color: Theme.of(context).colorScheme.primary),
                onPressed: () {
                  if (_currentIndex < widget.recipes.length) {
                    showRecipeDetailSheet(
                        context, widget.recipes[_currentIndex]);
                  }
                },
              ),
            ),
            const SizedBox(width: 24),
            Semantics(
              button: true,
              label: 'Save recipe',
              child: IconButton(
                iconSize: 40,
                icon: Icon(Icons.favorite,
                    color: Theme.of(context).colorScheme.secondary),
                onPressed: () =>
                    _controller.swipe(CardSwiperDirection.right),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
