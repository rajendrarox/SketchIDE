import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sketchide/data/local/db_handler.dart';
import 'package:sketchide/ui/widgets/project_create.dart';
import 'dart:io';

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
        elevation: 4.0,
      ),

      /// Display list of projects as cards or a message if empty
      body: allproject.isNotEmpty
          ? ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: allproject.length,
              itemBuilder: (_, index) {
                final appLogoPath =
                    allproject[index][DbHandler.COLUMN_APP_LOGO_PATH];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 1.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.all(
                          1.0), // Adds an 8-pixel margin around the avatar
                      child: appLogoPath != null && appLogoPath.isNotEmpty
                          ? CircleAvatar(
                              backgroundImage: FileImage(File(appLogoPath)),
                              radius: 25, // Sets the size of the avatar
                            )
                          : const CircleAvatar(
                              radius: 25,
                              child: Icon(
                                Icons.image,
                                size:100, // Size of the placeholder icon inside the CircleAvatar
                              ),
                            ),
                    ), // Placeholder if no logo
                    title: Text(
                      allproject[index][DbHandler.COLUMN_APP_NAME],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),

                final appLogoPath = allproject[index][DbHandler.COLUMN_APP_LOGO_PATH];
                
                return ListTile(
                  trailing: Text(allproject[index][DbHandler.COLUMN_PROJECT_ID]
                        .toString()),
                    leading:  appLogoPath != null
      ? appLogoPath.isNotEmpty
          ? Image.file(File(appLogoPath)) // Load image if path exists
          : const SizedBox.shrink()
      : const SizedBox.shrink(),
                    title: Text(allproject[index][DbHandler.COLUMN_APP_NAME]),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4.0),
                        Text(allproject[index][DbHandler.COLUMN_PROJECT_NAME]),
                        Text(allproject[index]
                            [DbHandler.COLUMN_APP_PACKAGE_NAME]),
                      ],
                    ),
                    trailing: Text(
                      allproject[index][DbHandler.COLUMN_PROJECT_ID].toString(),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                );
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
