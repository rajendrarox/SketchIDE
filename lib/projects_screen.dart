import 'package:flutter/material.dart';
import 'package:sketchide/data/local/db_handler.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<Map<String, dynamic>> allproject = [];
  DbHandler? dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = DbHandler.getInstence;
    getProjects();
  }

  void getProjects() async {
    allproject = await dbRef!.getAllProject();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Projects"),
      ),

      /// Display list of projects or a message if empty
      body: allproject.isNotEmpty
          ? ListView.builder(
              itemCount: allproject.length,
              itemBuilder: (_, index) {
                return ListTile(
                    leading: Text(allproject[index][DbHandler.COLUMN_PROJECT_ID]
                        .toString()),
                    title: Text(allproject[index][DbHandler.COLUMN_APP_NAME]),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(allproject[index][DbHandler.COLUMN_PROJECT_NAME]),
                        Text(allproject[index]
                            [DbHandler.COLUMN_APP_PACKAGE_NAME]),
                      ],
                    ));
              },
            )
          : const Center(
              child: Text("No Projects Yet"),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          /// Adding a new project
          bool check = await dbRef!.addProject(
              appName: "My App",
              projectName: "My_Project",
              appPackageName: "com.example.my_app");
          if (check) {
            getProjects();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
