import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/search_viewmodel.dart';
import 'navigation_drawer.dart';
import 'widgets/recipe_detail_sheet.dart';
import 'widgets/fade_in_widget.dart';
import 'widgets/staggered_list_item.dart';
import 'widgets/snackstack_header.dart'; 

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchVm = context.watch<SearchViewModel>();

    return Scaffold(
      drawer: const AppNavigationDrawer(currentRoute: '/search'),
      appBar: AppBar(
        centerTitle: true,
        title: const SnackStackHeader(), 
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            TextField(
              autofocus: false,
              decoration: InputDecoration(
                hintText: "Search recipes...",
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: searchVm.updateQuery,
            ),

            const SizedBox(height: 16),

            Expanded(
              child: searchVm.query.isEmpty
                  ? Center(
                      child: Text(
                        "Type in the search bar to find recipes.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  : searchVm.searchResults.isEmpty
                      ? Center(
                          child: Text(
                            "No recipes found.",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      : FadeInWidget(
                          duration: const Duration(milliseconds: 400),
                          child: ListView.builder(
                            itemCount: searchVm.searchResults.length,
                            itemBuilder: (context, index) {
                              final recipe = searchVm.searchResults[index];
                              return StaggeredListItem(
                                index: index,
                                delay: Duration(milliseconds: 50 * index),
                                child: Semantics(
                                  button: true,
                                  label: recipe.title,
                                  hint: recipe.isCeliacSafe
                                      ? 'Gluten-free recipe. Double tap to view details.'
                                      : 'Contains gluten. Double tap to view details.',
                                  child: ListTile(
                                    title: Text(recipe.title),
                                    subtitle: Text(
                                      recipe.isCeliacSafe
                                          ? "Gluten-free"
                                          : "Contains gluten",
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                    ),
                                    onTap: () =>
                                        showRecipeDetailSheet(context, recipe),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
