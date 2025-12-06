import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'viewmodels/recipe_filter_viewmodel.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/saved_recipes_viewmodel.dart';

import 'views/startup_screen.dart';
import 'views/recipe_filter_screen.dart';
import 'views/search_screen.dart';
import 'views/saved_recipes_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecipeFilterViewModel()),

        ChangeNotifierProxyProvider<RecipeFilterViewModel, SearchViewModel>(
          create: (_) => SearchViewModel(allRecipes: []),
          update: (_, filterVm, previousSearchVm) =>
              SearchViewModel(allRecipes: filterVm.allRecipes),
        ),

        ChangeNotifierProxyProvider<RecipeFilterViewModel,
            SavedRecipesViewModel>(
          create: (_) => SavedRecipesViewModel(likedRecipes: []),
          update: (_, filterVm, previousSavedVm) =>
              SavedRecipesViewModel(likedRecipes: filterVm.likedRecipes),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textScaleFactor =
        MediaQuery.of(context).textScaleFactor.clamp(1.0, 1.3);

    return MaterialApp(
      title: 'SnackStack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(textScaleFactor: textScaleFactor),

      // 🚀 NEW: App loads StartupScreen first
      initialRoute: '/startup',

      routes: {
        '/startup': (ctx) => const StartupScreen(),
        '/': (ctx) => const RecipeFilterScreen(),
        '/search': (ctx) => const SearchScreen(),
        '/saved': (ctx) => const SavedRecipesScreen(),
      },
    );
  }
}
