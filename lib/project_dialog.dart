
import 'package:flutter/material.dart';

class ProjectDialog extends StatefulWidget {
  const ProjectDialog({super.key});

  @override
  ProjectDialogState createState() => ProjectDialogState(); 
}

class ProjectDialogState extends State<ProjectDialog> { 
  final TextEditingController _appNameController = TextEditingController();
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _packageNameController = TextEditingController();
  String? _appLogo;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create New Project"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _appNameController,
              decoration: const InputDecoration(labelText: "Enter App Name"),
            ),
            TextField(
              controller: _projectNameController,
              decoration: const InputDecoration(labelText: "Enter Project Name"),
            ),
            TextField(
              controller: _packageNameController,
              decoration: const InputDecoration(labelText: "Enter App Package Name"),
            ),
            TextButton(
              onPressed: () async {
                // Implement logo selection (left as exercise)
              },
              child: const Text("Select App Logo"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop({
              'appName': _appNameController.text,
              'projectName': _projectNameController.text,
              'packageName': _packageNameController.text,
              'appLogo': _appLogo,
            });
          },
          child: const Text("Create"),
        ),
      ],
    );
  }
}
