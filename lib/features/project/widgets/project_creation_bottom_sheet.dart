import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../domain/models/project.dart';

class ProjectCreationBottomSheet extends StatefulWidget {
  final Function({
    required String name,
    required String appName,
    required String packageName,
    String? iconPath,
    String? version,
    int? versionCode,
  }) onCreateProject;
  final Project? project; // For editing existing project

  const ProjectCreationBottomSheet({
    super.key,
    required this.onCreateProject,
    this.project,
  });

  @override
  State<ProjectCreationBottomSheet> createState() => _ProjectCreationBottomSheetState();
}

class _ProjectCreationBottomSheetState extends State<ProjectCreationBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _appNameController = TextEditingController();
  final _nameController = TextEditingController();
  final _packageNameController = TextEditingController();
  final _versionNameController = TextEditingController();
  final _versionCodeController = TextEditingController();
  
  String? _selectedIconPath;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      // Editing existing project
      _appNameController.text = widget.project!.appName;
      _nameController.text = widget.project!.name;
      _packageNameController.text = widget.project!.packageName;
      _versionNameController.text = widget.project!.version;
      _versionCodeController.text = widget.project!.versionCode.toString();
      _selectedIconPath = widget.project!.iconPath;
    } else {
      // New project - set defaults
      _versionNameController.text = '1.0.0';
      _versionCodeController.text = '1';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _appNameController.dispose();
    _packageNameController.dispose();
    _versionNameController.dispose();
    _versionCodeController.dispose();
    super.dispose();
  }

  Future<void> _pickIcon() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );

    if (image != null) {
      setState(() {
        _selectedIconPath = image.path;
      });
    }
  }

  String _generateProjectName(String appName) {
    // Remove spaces and special characters, keep original case
    return appName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  }

  String _generatePackageName(String appName) {
    // Use the full app name (lowercase, no spaces) after com.sketchide.
    return 'com.sketchide.${appName.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}';
  }

  void _onAppNameChanged(String value) {
    // Auto-fill project name (remove spaces, keep case)
    if (_nameController.text.isEmpty || 
        _nameController.text == _generateProjectName(_appNameController.text)) {
      _nameController.text = _generateProjectName(value);
    }
    // Auto-fill package name (lowercase, no spaces)
    if (_packageNameController.text.isEmpty || 
        _packageNameController.text.startsWith('com.sketchide.')) {
      _packageNameController.text = _generatePackageName(value);
    }
  }

  Future<void> _createProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
    });

    try {
      await widget.onCreateProject(
        name: _nameController.text.trim(),
        appName: _appNameController.text.trim(),
        packageName: _packageNameController.text.trim(),
        iconPath: _selectedIconPath,
        version: _versionNameController.text.trim(),
        versionCode: int.tryParse(_versionCodeController.text.trim()) ?? 1,
      );
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create project: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.project != null ? 'Edit Project' : 'Create New Project',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // App Icon Picker
                Center(
                  child: GestureDetector(
                    onTap: _pickIcon,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        shape: BoxShape.circle,
                      ),
                      child: _selectedIconPath != null
                          ? ClipOval(
                              child: Image.file(
                                File(_selectedIconPath!),
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 40),
                                Text('App Icon', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // App Name
                TextFormField(
                  controller: _appNameController,
                  decoration: const InputDecoration(
                    labelText: 'App Name',
                    border: OutlineInputBorder(),
                    hintText: 'Enter app name',
                    prefixIcon: Icon(Icons.apps),
                  ),
                  onChanged: _onAppNameChanged,
                  maxLength: 50,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'App name is required';
                    }
                    if (value.length > 50) {
                      return 'App name must be less than 50 characters';
                    }
                    // Only allow letters, numbers, and spaces
                    if (RegExp(r'[^a-zA-Z0-9\s]').hasMatch(value)) {
                      return 'App name can only contain letters, numbers, and spaces';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Project Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Project Name',
                    border: OutlineInputBorder(),
                    hintText: 'Enter project name',
                    prefixIcon: Icon(Icons.folder),
                  ),
                  maxLength: 30,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Project name is required';
                    }
                    if (value.length > 30) {
                      return 'Project name must be less than 30 characters';
                    }
                    // Only allow letters, numbers, and underscores
                    if (RegExp(r'[^a-zA-Z0-9_]').hasMatch(value)) {
                      return 'Project name can only contain letters, numbers, and underscores';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Package Name
                TextFormField(
                  controller: _packageNameController,
                  decoration: const InputDecoration(
                    labelText: 'Package Name',
                    border: OutlineInputBorder(),
                    hintText: 'com.sketchide.myapp',
                    prefixIcon: Icon(Icons.code),
                  ),
                  maxLength: 100,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9._]')),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Package name is required';
                    }
                    if (value.length > 100) {
                      return 'Package name must be less than 100 characters';
                    }
                    // Only allow lowercase letters, numbers, dots, and underscores
                    if (RegExp(r'[^a-z0-9._]').hasMatch(value)) {
                      return 'Package name can only contain lowercase letters, numbers, dots, and underscores';
                    }
                    // Must start with a letter
                    if (!RegExp(r'^[a-z]').hasMatch(value)) {
                      return 'Package name must start with a letter';
                    }
                    // Must follow proper package naming convention
                    if (!RegExp(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)*$').hasMatch(value)) {
                      return 'Invalid package name format (e.g., com.sketchide.myapp)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Version Name
                TextFormField(
                  controller: _versionNameController,
                  decoration: const InputDecoration(
                    labelText: 'Version Name',
                    border: OutlineInputBorder(),
                    hintText: '1.0.0',
                    prefixIcon: Icon(Icons.tag),
                  ),
                  maxLength: 20,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Version name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Version Code
                TextFormField(
                  controller: _versionCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Version Code',
                    border: OutlineInputBorder(),
                    hintText: '1',
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Version code is required';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Version code must be a number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isCreating ? null : _createProject,
                        child: _isCreating
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(widget.project != null ? 'Update' : 'Create'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 