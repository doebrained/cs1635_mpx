import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/recipe_filter_viewmodel.dart';
import '../models/recipe.dart';
import 'widgets/recipe_card.dart';

class RecipeFilterScreen extends StatelessWidget {
  const RecipeFilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RecipeFilterViewModel>();
    final filtered = viewModel.filteredRecipes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Swipe Recipes – Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dietary Filters',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // VERTICAL filters
            Column(
              children: [
                SwitchListTile(
                  title: const Text('Celiac-safe only (gluten-free)'),
                  value: viewModel.celiacOnly,
                  onChanged: viewModel.toggleCeliacOnly,
                ),
                SwitchListTile(
                  title: const Text('Lactose-free only'),
                  value: viewModel.lactoseOnly,
                  onChanged: viewModel.toggleLactoseOnly,
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              'Matching recipes: ${filtered.length}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),

            const Expanded(
              child: _SwipeDeck(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeDeck extends StatefulWidget {
  const _SwipeDeck();

  @override
  State<_SwipeDeck> createState() => _SwipeDeckState();
}

enum _SwipeAction { none, like, dislike }

class _SwipeDeckState extends State<_SwipeDeck> {
  Offset _dragOffset = Offset.zero;
  double _rotation = 0.0;
  bool _isDragging = false;
  _SwipeAction _pendingAction = _SwipeAction.none;

  void _resetCard() {
    setState(() {
      _dragOffset = Offset.zero;
      _rotation = 0.0;
      _isDragging = false;
      _pendingAction = _SwipeAction.none;
    });
  }

  void _animateOffScreen(_SwipeAction action, RecipeFilterViewModel vm) {
    final targetOffset =
        action == _SwipeAction.like ? const Offset(700, 0) : const Offset(-700, 0);

    setState(() {
      _pendingAction = action;
      _isDragging = false;
      _dragOffset = targetOffset;
      _rotation = action == _SwipeAction.like ? 0.25 : -0.25;
    });
  }

  void _handlePanEnd(
      DragEndDetails details, RecipeFilterViewModel vm, Recipe current) {
    final velocity = details.velocity.pixelsPerSecond;

    if (velocity.dx > 500) {
      _animateOffScreen(_SwipeAction.like, vm);
      return;
    } else if (velocity.dx < -500) {
      _animateOffScreen(_SwipeAction.dislike, vm);
      return;
    }

    if (velocity.dy < -500) {
      // swipe up for details (no card advance yet)
      _showDetails(context, current);
      _resetCard();
      return;
    }

    _resetCard();
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
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
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
                      height: 220,
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (recipe.isCeliacSafe)
                        _DetailTag(label: 'Celiac-safe'),
                      if (recipe.isLactoseFree)
                        _DetailTag(label: 'Lactose-free'),
                      if (!recipe.isCeliacSafe)
                        _DetailTag(label: 'Contains gluten'),
                      if (!recipe.isLactoseFree)
                        _DetailTag(label: 'Contains dairy'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Ingredients',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Ingredient 1\n• Ingredient 2\n• Ingredient 3\n(Placeholder until API integration.)',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. Step one.\n2. Step two.\n3. Step three.\n\nPlaceholder instructions.',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecipeFilterViewModel>();
    final current = vm.currentRecipe;
    final next = vm.nextRecipe;

    void handleAnimationEnd() {
      if (_pendingAction == _SwipeAction.like) {
        vm.swipeRight();
        _resetCard();
      } else if (_pendingAction == _SwipeAction.dislike) {
        vm.swipeLeft();
        _resetCard();
      }
    }

    if (current == null) {
      // NOTE: This will show either when there are no filtered recipes
      // OR when you've swiped through them all.
      final count = vm.filteredRecipes.length;
      return Center(
        child: Text(
          count == 0
              ? 'No recipes match your filters.\nTry changing them!'
              : 'No more recipes.\nYou’ve seen all $count matches.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (next != null)
                  Transform.translate(
                    offset: const Offset(0, 20),
                    child: Transform.scale(
                      scale: 0.95,
                      child: Opacity(
                        opacity: 0.7,
                        child: RecipeCard(recipe: next),
                      ),
                    ),
                  ),
                GestureDetector(
                  onPanStart: (_) {
                    setState(() {
                      _isDragging = true;
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _dragOffset += details.delta;
                      _rotation = _dragOffset.dx / 400;
                    });
                  },
                  onPanEnd: (details) =>
                      _handlePanEnd(details, vm, current),
                  child: AnimatedContainer(
                    duration: _isDragging
                        ? Duration.zero
                        : const Duration(milliseconds: 260),
                    curve: Curves.easeOut,
                    transform: Matrix4.identity()
                      ..translate(_dragOffset.dx, _dragOffset.dy)
                      ..rotateZ(_rotation),
                    onEnd: handleAnimationEnd,
                    child: RecipeCard(recipe: current),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize: 40,
              onPressed: () {
                _animateOffScreen(_SwipeAction.dislike, vm);
              },
              icon: const Icon(Icons.close, color: Colors.redAccent),
            ),
            const SizedBox(width: 24),
            IconButton(
              iconSize: 40,
              onPressed: () {
                _animateOffScreen(_SwipeAction.like, vm);
              },
              icon: const Icon(Icons.favorite, color: Colors.pinkAccent),
            ),
            const SizedBox(width: 24),
            IconButton(
              iconSize: 32,
              onPressed: () {
                _showDetails(context, current);
              },
              icon: const Icon(Icons.arrow_upward),
              tooltip: 'Details',
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _DetailTag extends StatelessWidget {
  final String label;
  const _DetailTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.teal.shade50,
      side: BorderSide(color: Colors.teal.shade200),
    );
  }
}
