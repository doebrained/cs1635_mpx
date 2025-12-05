import 'package:flutter/material.dart';

import 'navigation_drawer.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppNavigationDrawer(currentRoute: '/search'),
      appBar: AppBar(title: const Text('Search')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Search page placeholder — implement search UI here.'),
        ),
      ),
    );
  }
}
