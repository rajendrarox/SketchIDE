import 'package:flutter/material.dart';
import 'package:sketchide/ui/widgets/screens/tabs/event_tabs/event_activity.dart';
import 'package:sketchide/ui/widgets/screens/tabs/event_tabs/event_component.dart';
import 'package:sketchide/ui/widgets/screens/tabs/event_tabs/event_drawer.dart';
import 'package:sketchide/ui/widgets/screens/tabs/event_tabs/event_moreblock.dart';
import 'package:sketchide/ui/widgets/screens/tabs/event_tabs/event_view.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    Center(child: Text('Soon!')),
    const EventActivity(),
    const EventView(),
    const EventComponent(),
    const EventDrawer(),
    const EventMoreblock(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 100,
            child: NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                if (index == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Soon!')),
                  );
                } else {
                  _onTabSelected(index);
                }
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.add_circle_outline, size: 32),
                  label: Text(''),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.local_activity),
                  label: Text('Activity'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.view_agenda),
                  label: Text('View'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.widgets),
                  label: Text('Component'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.chrome_reader_mode),
                  label: Text('Drawer'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.extension_rounded),
                  label: Text('More Block'),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
