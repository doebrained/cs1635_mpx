import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/search_viewmodel.dart';
import 'navigation_drawer.dart';
import 'widgets/recipe_detail_sheet.dart';
import 'widgets/fade_in_widget.dart';
import 'widgets/staggered_list_item.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchVm = context.watch<SearchViewModel>();

    return Scaffold(
      drawer: const AppNavigationDrawer(currentRoute: '/search'),
      appBar: AppBar(
        title: TextField(
          autofocus: false,
          decoration: const InputDecoration(
            hintText: "Search recipes...",
            border: InputBorder.none,
          ),
          onChanged: (value) => searchVm.updateQuery(value),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: searchVm.query.isEmpty
            ? const Center(
                child: Text(
                  "Type in the search bar to find recipes.",
                  textAlign: TextAlign.center,
                ),
              )
            : searchVm.searchResults.isEmpty
            ? const Center(
                child: Text(
                  "No recipes found.",
                  style: TextStyle(fontSize: 16),
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
                                ? 'Gluten-free. Double tap to view details.'
                                : 'Contains gluten. Double tap to view details.',
                            child: ListTile(
                              title: Text(recipe.title),
                              subtitle: Text(
                                recipe.isCeliacSafe
                                    ? "Gluten-free"
                                    : "Contains gluten",
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => showRecipeDetailSheet(context, recipe),
                            ),
                          ),
                        );
                  },
                ),
              ),
      ),
    );
  }
}
