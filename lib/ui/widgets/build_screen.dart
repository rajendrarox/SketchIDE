import 'package:flutter/material.dart';

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

class _BuildScreenState extends State<BuildScreen> {
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
      ),
      body: const Center(
        child: Text('Build Screen'), // Main content of the screen
      ),
    );
  }
}
