import 'package:flutter/material.dart';

import 'navigation_drawer.dart';

class SavedRecipesScreen extends StatelessWidget {
  const SavedRecipesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Recipes')),
      drawer: const AppNavigationDrawer(currentRoute: '/saved'),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Saved recipes placeholder — show saved list here.'),
        ),
      ),
    );
  }
}
