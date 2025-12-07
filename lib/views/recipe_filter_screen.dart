import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import '../viewmodels/recipe_filter_viewmodel.dart';
import '../models/recipe.dart';
import 'widgets/recipe_card.dart';
import 'navigation_drawer.dart';
import 'widgets/recipe_detail_sheet.dart';
import 'widgets/fade_in_widget.dart';
import 'widgets/snackstack_header.dart';

class RecipeFilterScreen extends StatefulWidget {
  const RecipeFilterScreen({super.key});

  @override
  State<RecipeFilterScreen> createState() => _RecipeFilterScreenState();
}

class _RecipeFilterScreenState extends State<RecipeFilterScreen> {
  bool _expanded = false; // NEW — controls collapse

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
      appBar: AppBar(
        centerTitle: true,
        title: const SnackStackHeader(),
      ),

      body: Column(
        children: [
          // ---------------------------------------------------
          // COLLAPSIBLE FILTER HEADER
          // ---------------------------------------------------
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              color: Colors.grey.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Dietary Filters",
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more)
                ],
              ),
            ),
          ),

          // ---------------------------------------------------
          // COLLAPSIBLE FILTER CONTENT
          // ---------------------------------------------------
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: _expanded ? 280 : 0, // COMPRESSED height when collapsed
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
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
                  SwitchListTile(
                    title: const Text('Vegetarian only'),
                    value: vm.vegetarianOnly,
                    onChanged: vm.toggleVegetarian,
                  ),
                  SwitchListTile(
                    title: const Text('Vegan only'),
                    value: vm.veganOnly,
                    onChanged: vm.toggleVegan,
                  ),
                  SwitchListTile(
                    title: const Text('Nut-free only'),
                    value: vm.nutFreeOnly,
                    onChanged: vm.toggleNutFree,
                  ),
                  SwitchListTile(
                    title: const Text('Halal only'),
                    value: vm.halalOnly,
                    onChanged: vm.toggleHalal,
                  ),
                  SwitchListTile(
                    title: const Text('Kosher only'),
                    value: vm.kosherOnly,
                    onChanged: vm.toggleKosher,
                  ),
                ],
              ),
            ),
          ),

          // ---------------------------------------------------
          // MATCHING COUNT
          // ---------------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Matching recipes: ${filtered.length}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),

          const Divider(height: 1),

          // ---------------------------------------------------
          // MAIN SWIPE DECK AREA
          // ---------------------------------------------------
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())

                : vm.errorMessage != null
                    ? Center(child: Text(vm.errorMessage!))

                    : filtered.isEmpty
                        ? Center(
                            child: Text(
                              "No recipes match your filters.",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          )

                        : FadeInWidget(
                            duration: const Duration(milliseconds: 400),
                            child: _SwipeDeck(recipes: filtered),
                          ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------
// SWIPE DECK COMPONENT
// -------------------------------------------------------
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
            onSwipe: (prev, next, dir) {
              final recipe = widget.recipes[prev];

              if (dir == CardSwiperDirection.right) vm.like(recipe);

              if (dir == CardSwiperDirection.top) {
                showRecipeDetailSheet(context, recipe);
                _controller.undo();
              }

              setState(() {
                _currentIndex =
                    dir == CardSwiperDirection.top ? prev : (next ?? prev);
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
              icon: Icon(Icons.close,
                  color: Theme.of(context).colorScheme.error),
              onPressed: () =>
                  _controller.swipe(CardSwiperDirection.left),
            ),
            const SizedBox(width: 24),
            IconButton(
              iconSize: 36,
              icon: Icon(Icons.arrow_upward,
                  color: Theme.of(context).colorScheme.primary),
              onPressed: () {
                showRecipeDetailSheet(
                    context, widget.recipes[_currentIndex]);
              },
            ),
            const SizedBox(width: 24),
            IconButton(
              iconSize: 40,
              icon: Icon(Icons.favorite,
                  color: Theme.of(context).colorScheme.secondary),
              onPressed: () =>
                  _controller.swipe(CardSwiperDirection.right),
            ),
          ],
        ),
      ],
    );
  }
}
