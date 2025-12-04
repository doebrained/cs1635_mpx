import 'package:flutter/material.dart';

import 'navigation_drawer.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      drawer: const AppNavigationDrawer(currentRoute: '/search'),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Search page placeholder — implement search UI here.'),
        ),
      ),
    );
  }
}
