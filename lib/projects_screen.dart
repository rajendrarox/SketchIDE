import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sketchide/data/local/db_handler.dart';
import 'package:sketchide/build_screen.dart';
import 'package:sketchide/models/message_handler.dart';
import 'package:sketchide/ui/widgets/project_create.dart';
import 'dart:io';

import 'package:url_launcher/url_launcher_string.dart';

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
      //Navigation Drawer
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Center(
                child: Text(
                  'SketchIDE',
                  style: TextStyle(
                    fontSize: 24.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Program Information'),
              onTap: () {
                MessageHandler.showMessage(context, "Feature Coming Soon..");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('System Settings'),
              onTap: () {
                MessageHandler.showMessage(context, "Feature Coming Soon..");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.developer_mode),
              title: const Text('Developer Tools'),
              onTap: () {
                MessageHandler.showMessage(context, "Feature Coming Soon..");
                Navigator.pop(context);
              },
            ),
            const Spacer(),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.telegram, color: Colors.blue),
                    onPressed: () async {
                      const url = 'https://t.me/sketchidegroup';
                      if (await canLaunchUrlString(url)) {
                        await launchUrlString(url);
                      } else {
                       MessageHandler.showMessage(context, "Could not open Telegram Group.");
                      }
                    },
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.code, color: Colors.black),
                    onPressed: () async {
                      const url = 'https://github.com/sketchide/SketchIDE';
                      if (await canLaunchUrlString(url)) {
                        await launchUrlString(url);
                      } else {
                        MessageHandler.showMessage(context, "Could not open GitHub repository.");
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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
                      padding: const EdgeInsets.all(1.0),
                      child: appLogoPath != null && appLogoPath.isNotEmpty
                          ? CircleAvatar(
                              backgroundImage: FileImage(File(appLogoPath)),
                              radius: 25,
                            )
                          : const CircleAvatar(
                              radius: 25,
                              child: Icon(
                                Icons.image,
                                size:
                                    20, // Size of the placeholder icon inside the CircleAvatar
                              ),
                            ),
                    ),
                    title: Text(
                      allproject[index][DbHandler.COLUMN_APP_NAME],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
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
                    // Add onTap to ListTile to navigate to the details screen
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BuildScreen(),
                        ),
                      );
                    },
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
