
import 'package:flutter/material.dart'; // Import Flutter's material design package
import 'project_dialog.dart'; // Import your dialog for project creation
import 'file_service.dart'; // Import the file service for file operations

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState(); // Make public
}

class HomeScreenState extends State<HomeScreen> { // Make public
  List<Map<String, String>> projects = []; // List to hold project details
  final FileService fileService = FileService(); // Create an instance of FileService

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SketchIDE"),
      ),
      body: projects.isEmpty
          ? const Center(child: Text("No projects created yet"))
          : ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(projects[index]['appName'] ?? ''),
                  subtitle: Text(projects[index]['projectName'] ?? ''),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newProject = await showDialog<Map<String, String>>(
            context: context,
            builder: (_) => const ProjectDialog(),
          );

          if (newProject != null) {
            setState(() {
              projects.add(newProject);
            });

            // Save the project data using the FileService
            await fileService.saveProjectData(
              newProject['appName'] ?? '',
              newProject['projectName'] ?? '',
              newProject['packageName'] ?? '',
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
