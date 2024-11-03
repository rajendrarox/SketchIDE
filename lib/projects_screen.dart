import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sketchide/data/local/db_handler.dart';
import 'package:sketchide/ui/widgets/project_create.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key, required this.title});

  final String title;

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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
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
        onPressed: () {
          FocusScope.of(context).unfocus(); // Dismiss the keyboard
          Get.to(() => const CreateProject()); // Navigate to CreateProject
        },

        child: const Icon(Icons.add),
      ),
    );
  }
}
