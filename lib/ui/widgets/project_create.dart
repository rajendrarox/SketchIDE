import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sketchide/data/local/db_handler.dart';
import 'package:sketchide/projects_screen.dart';
import 'dart:io';

class CreateProject extends StatefulWidget {
  const CreateProject({super.key});

  @override
  State<CreateProject> createState() => _CreateProjectState();
}

class _CreateProjectState extends State<CreateProject> {
  final TextEditingController appNameController = TextEditingController();
  final TextEditingController packageNameController = TextEditingController();
  final TextEditingController projectNameController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _createProject() async {
    final appName = appNameController.text;
    final packageName = packageNameController.text;
    final projectName = projectNameController.text;

    if (appName.isEmpty || packageName.isEmpty || projectName.isEmpty) {
      Get.snackbar(
        "Warning",
        "Please fill in all fields.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    DbHandler dbHandler = DbHandler.getInstence;
    bool success = await dbHandler.addProject(
      appName: appName,
      projectName: projectName,
      appPackageName: packageName,
      appLogo: _selectedImage ?? File(''),
    );

    if (!mounted) return; // Check if the widget is still in the widget tree

    if (success) {
      Get.snackbar("Success", "Project created successfully!");
      Navigator.pop(context);
      Get.offAll(() => const ProjectsScreen(title: "Projects"));
    } else {
      Get.snackbar("Error", "Failed to create project.");
    }
  }

  @override
  Widget build(BuildContext context) {
import 'package:sketchide/data/local/db_handler.dart';
import 'package:sketchide/projects_screen.dart';

class CreateProject extends StatelessWidget {
  const CreateProject({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController appNameController = TextEditingController();
    final TextEditingController packageNameController = TextEditingController();
    final TextEditingController projectNameController = TextEditingController();


    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Project"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select App Logo",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: _selectedImage != null
                      ? Image.file(
                          _selectedImage!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: const Icon(Icons.camera_alt, size: 50),
                        ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(


                "Enter Application Name",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: appNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Application Name",
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Enter Package Name",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: packageNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Package Name",
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Enter Project Name",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: projectNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Project Name",
                ),
              ),

              const SizedBox(height: 16),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,

                      Navigator.pop(context); // Cancel button action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey, // Cancel button color

                    ),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(

                    onPressed: _createProject,

                    onPressed: () async {
                      final appName = appNameController.text;
                      final packageName = packageNameController.text;
                      final projectName = projectNameController.text;

                      // Validate input fields
                      if (appName.isEmpty || packageName.isEmpty || projectName.isEmpty) {
                        Get.snackbar("Warning", "Please fill in all fields.",
                          snackPosition: SnackPosition.BOTTOM);
                        return; // Exit if validation fails
                      }

                      // Add the project to the database
                      DbHandler dbHandler = DbHandler.getInstence;
                      bool success = await dbHandler.addProject(
                        appName: appName,
                        projectName: projectName,
                        appPackageName: packageName,
                      );

                      if (success) {
                        // Show a success message
                        Get.snackbar("Success", "Project created successfully!");

                        // Navigate back to ProjectsScreen and refresh it
                        Navigator.pop(context); // Pop CreateProject screen
                        Get.offAll(() => const ProjectsScreen(title: "Projects")); // Navigate back to ProjectsScreen
                      } else {
                        Get.snackbar("Error", "Failed to create project.");
                      }
                    },

                    child: const Text("Create Project"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
