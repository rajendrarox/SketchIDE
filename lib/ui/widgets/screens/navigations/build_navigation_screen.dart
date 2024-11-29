import 'package:flutter/material.dart';
import 'package:sketchide/ui/widgets/screens/navigations/build_screen/build_screen_library.dart';
import '../tabs/event_screen.dart';

class BuildNavigationScreen extends StatelessWidget {
  const BuildNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: buildNavigationItems(context),
      ),
    );
  }

  List<Widget> buildNavigationItems(BuildContext context) {
    // Define all the navigation items as a list of maps for reusability
    final items = [
      _NavigationItem(
        icon: Icons.auto_awesome_mosaic,
        title: 'Library',
        subtitle: 'Component Settings',
        color: Colors.blue,
        route: const BuildScreenLibrary(),
      ),
      _NavigationItem(
        icon: Icons.view_agenda,
        title: 'View',
        subtitle: 'Manage Multiple Screens',
        color: Colors.green,
        route: null,
      ),
      _NavigationItem(
        icon: Icons.photo,
        title: 'Image',
        subtitle: 'Import photos & icons',
        color: Colors.red,
        route: null,
      ),
      _NavigationItem(
        icon: Icons.graphic_eq,
        title: 'Sound',
        subtitle: 'Import music & sound effect',
        color: Colors.purple,
        route: const EventScreen(),
      ),
      _NavigationItem(
        icon: Icons.description,
        title: 'Assets',
        subtitle: 'Import asset files',
        color: Colors.orange,
        route: null,
      ),
      _NavigationItem(
        icon: Icons.code,
        title: 'Show Source Code',
        subtitle: 'View source code like Dart etc.',
        color: Colors.blueAccent,
        route: null,
      ),
    ];

    // Map the items into ListTile widgets
    return [
      Container(
        height: 40,
        color: Colors.blue,
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              'Configuration',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ),
      ...items.map((item) => buildNavigationTile(context, item)),
    ];
  }

  // Reusable method to build the ListTile
  Widget buildNavigationTile(BuildContext context, _NavigationItem item) {
    return ListTile(
      leading: Icon(item.icon, color: item.color),
      title: Text(item.title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(item.subtitle, style: const TextStyle(fontSize: 12)),
      onTap: () {
        if (item.route != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => item.route!),
          );
        }
      },
    );
  }
}

// Model class for the navigation items
class _NavigationItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget? route;

  _NavigationItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.route,
  });
}
