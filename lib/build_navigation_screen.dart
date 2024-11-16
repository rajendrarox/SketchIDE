import 'package:flutter/material.dart';
import 'event_screen.dart'; // Import the event screen
import 'component_screen.dart'; // Import the component screen

class BuildNavigationScreen extends StatelessWidget {
  const BuildNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header with reduced height
          Container(
            height: 40, // Set the desired height here
            color: Colors.blue,
            child: const Padding(
              padding: EdgeInsets.all(8.0), // Padding inside the header
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Configuration',
                  style: TextStyle(color: Colors.white, fontSize: 18), // Reduced font size
                ),
              ),
            ),
          ),
          // Library Button with subtitle
          ListTile(
            leading: const Icon(Icons.library_books),
            title: const Text('Library'),
            subtitle: const Text('component Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ComponentScreen()),
              );
            },
          ),
          // Component Settings Button with subtitle
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Component Settings'),
            subtitle: const Text('Manage component settings'),
            onTap: () {
              // Add action for component settings
            },
          ),
          // View Button with subtitle
          ListTile(
            leading: const Icon(Icons.view_comfy),
            title: const Text('View'),
            subtitle: const Text('Manage multiple screens'),
            onTap: () {
              // Add action for View management
            },
          ),
          // Event Button with subtitle
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Event'),
            subtitle: const Text('Manage events'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EventScreen()),
              );
            },
          ),
          // Media Button with subtitle
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('Media'),
            subtitle: const Text('Photos and Icons'),
            onTap: () {
              // Add action for media management
            },
          ),
          // Source Code Button with subtitle
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Show Source Code'),
            subtitle: const Text('View all types of code (e.g., Dart, JavaScript)'),
            onTap: () {
              // Add action for viewing source code
            },
          ),
        ],
      ),
    );
  }
}
