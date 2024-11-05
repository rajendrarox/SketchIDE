import 'package:flutter/material.dart';
import 'view_screen/view_screen.dart';       // Import the view screen
import 'event_screen.dart';      // Import the event screen
import 'component_screen.dart';  // Import the component screen

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
  late TabController _tabController;

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
      appBar: AppBar(
        elevation: 4.0, // Adds elevation (shadow effect)
        leading: IconButton(
          // Back arrow button
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: const Column(
          // Title with a subtitle
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
            // "Do" button
            icon: const Icon(Icons.redo),
            onPressed: () {
              // Add action for "Do" here
            },
          ),
          IconButton(
            // "Undo" button
            icon: const Icon(Icons.undo),
            onPressed: () {
              // Add action for "Undo" here
            },
          ),
          IconButton(
            // "Save" button
            icon: const Icon(Icons.save),
            onPressed: () {
              // Add action for "Save" here
            },
          ),
          PopupMenuButton<String>(
            // Options menu
            onSelected: (value) {
              // Add actions for the options here
            },
            itemBuilder: (BuildContext context) {
              return {'Option 1', 'Option 2', 'Option 3'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
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
      body: TabBarView(
        controller: _tabController,
        children: const [
          ViewScreen(),       // Using the ViewScreen widget
          EventScreen(),      // Using the EventScreen widget
          ComponentScreen(),  // Using the ComponentScreen widget
        ],
      ),
    );
  }
}
