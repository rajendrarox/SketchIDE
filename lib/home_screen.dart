import 'package:flutter/material.dart'; // Import Flutter's material design package
import 'project_dialog.dart'; // Import your dialog for project creation
import 'file_service.dart'; // Import the file service for file operations

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> projects = []; // List to hold project details
  final FileService fileService = FileService(); // Create an instance of FileService

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SketchIDE"),
      ),
      body: projects.isEmpty
          ? Center(child: Text("No projects created yet"))
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
            builder: (_) => ProjectDialog(),
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
        child: Icon(Icons.add),
      ),
    );
  }
}
