import 'package:flutter/material.dart';

class AppNavigationDrawer extends StatelessWidget {
  final String currentRoute;
  const AppNavigationDrawer({Key? key, required this.currentRoute})
    : super(key: key);

  void _navigate(BuildContext context, String route) {
    if (route == currentRoute) {
      Navigator.of(context).pop();
      return;
    }
    // Replace so back doesn't pile up
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: const Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Menu',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            _buildItem(
              context,
              Icons.dashboard,
              'Recipe Cards',
              '/',
              currentRoute,
            ),
            _buildItem(
              context,
              Icons.search,
              'Search',
              '/search',
              currentRoute,
            ),
            _buildItem(
              context,
              Icons.bookmark,
              'Saved Recipes',
              '/saved',
              currentRoute,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'v1.0',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    IconData icon,
    String label,
    String route,
    String current,
  ) {
    final selected = route == current;
    return Semantics(
      button: true,
      label: label,
      selected: selected,
      hint: 'Double tap to navigate to $label',
      child: ListTile(
        leading: Icon(
          icon,
          color: selected ? Theme.of(context).colorScheme.primary : null,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: selected ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
        selected: selected,
        onTap: () => _navigate(context, route),
      ),
    );
  }
}
