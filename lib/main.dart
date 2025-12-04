import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/recipe_filter_viewmodel.dart';
import 'views/recipe_filter_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => RecipeFilterViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Filter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const RecipeFilterScreen(),
    );
  }
}
