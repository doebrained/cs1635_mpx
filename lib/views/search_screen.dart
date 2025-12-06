import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/recipe_filter_viewmodel.dart';
import '../models/recipe.dart';
import 'navigation_drawer.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = "";

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecipeFilterViewModel>();
    final List<Recipe> all = vm.allRecipes;

    // Filter recipes by title
    final List<Recipe> results = _query.isEmpty
        ? []
        : all
            .where((r) => r.title.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      drawer: const AppNavigationDrawer(currentRoute: '/search'),
      appBar: AppBar(
        title: TextField(
          autofocus: false,
          decoration: const InputDecoration(
            hintText: "Search recipes...",
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() => _query = value);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _query.isEmpty
            ? const Center(
                child: Text(
                  "Type in the search bar to find recipes.",
                  textAlign: TextAlign.center,
                ),
              )
            : results.isEmpty
                ? const Center(
                    child: Text(
                      "No recipes found.",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final recipe = results[index];
                      return ListTile(
                        title: Text(recipe.title),
                        subtitle: Text(recipe.isCeliacSafe
                            ? "Gluten-free"
                            : "Contains gluten"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // OPTIONAL: Show details modal
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
