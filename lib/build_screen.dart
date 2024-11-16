import 'package:flutter/material.dart';
import 'view_screen/view_screen.dart'; // Import the view screen
import 'event_screen.dart'; // Import the event screen
import 'component_screen.dart'; // Import the component screen
import 'build_navigation_screen.dart'; // Import the drawer screen

void main() {
  runApp(const BuildDesign());
}

class BuildDesign extends StatefulWidget {
  const BuildDesign({super.key});

  @override
  State<BuildDesign> createState() => _BuildDesignState();
}

class _BuildDesignState extends State<BuildDesign> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Build Design',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const BuildScreen(),
    );
  }
}

class BuildScreen extends StatefulWidget {
  const BuildScreen({super.key});

  @override
  State<BuildScreen> createState() => _BuildScreenState();
}

class _BuildScreenState extends State<BuildScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Key to control the Scaffold
  late TabController _tabController;
  String selectedActivity = 'main.dart'; // Default value for spinner

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the key to the Scaffold
      appBar: AppBar(
        elevation: 4.0, // Adds elevation (shadow effect)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Build Design'), // Main title
            Text(
              'Project:45', // Subtitle text
              style: TextStyle(fontSize: 10),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: () {
              // Add action for "Redo" here
            },
          ),
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: () {
              // Add action for "Undo" here
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // Add action for "Save" here
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert), // Options menu icon
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer(); // Open the right drawer
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'View'),
            Tab(text: 'Event'),
            Tab(text: 'Component'),
          ],
        ),
      ),
      endDrawer: const BuildNavigationScreen(), // Link to the new drawer screen
      body: TabBarView(
        controller: _tabController,
        children: const [
          ViewScreen(), // Using the ViewScreen widget
          EventScreen(), // Using the EventScreen widget
          ComponentScreen(), // Using the ComponentScreen widget
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(Icons.mobile_friendly_rounded, size: 24.0), // Small icon on the left
              const SizedBox(width: 8.0),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedActivity,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedActivity = newValue!;
                      });
                    },
                    items: <String>['main.dart', 'splash.dart']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      );
                    }).toList(),
                    isExpanded: true, // Ensures the dropdown spans available width
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: () {
                  // Add action for the run button
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4), // Rounded corners
                  ),
                  padding: EdgeInsets.zero, // Remove padding
                ),
                child: const SizedBox(
                  width: 50, // Square button size
                  height: 50,
                  child: Center(
                    child: Text(
                      'Run',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
