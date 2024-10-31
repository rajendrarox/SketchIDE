import 'package:flutter/material.dart';

class ProjectDialog extends StatefulWidget {
  @override
  _ProjectDialogState createState() => _ProjectDialogState();
}

class _ProjectDialogState extends State<ProjectDialog> {
  final TextEditingController _appNameController = TextEditingController();
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _packageNameController = TextEditingController();
  String? _appLogo;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Create New Project"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _appNameController,
              decoration: InputDecoration(labelText: "Enter App Name"),
            ),
            TextField(
              controller: _projectNameController,
              decoration: InputDecoration(labelText: "Enter Project Name"),
            ),
            TextField(
              controller: _packageNameController,
              decoration: InputDecoration(labelText: "Enter App Package Name"),
            ),
            TextButton(
              onPressed: () async {
                // Implement logo selection (left as exercise)
              },
              child: Text("Select App Logo"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Cancel"),
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
          child: Text("Create"),
        ),
      ],
    );
  }
}
