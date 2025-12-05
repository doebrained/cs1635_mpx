import 'package:flutter/material.dart';

import '../recipe_filter_screen.dart';
import '../saved_recipes_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.teal),
            child: Text(
              "Menu",
              style: TextStyle(fontSize: 22, color: Colors.white),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.grid_view),
            title: const Text("Recipe Cards"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const RecipeFilterScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text("Saved Recipes"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedRecipesScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
