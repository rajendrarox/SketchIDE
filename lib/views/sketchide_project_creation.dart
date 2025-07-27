import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../viewmodels/project_viewmodel.dart';
import '../models/sketchide_project.dart';
import '../models/project_complexity.dart';

class SketchIDEProjectCreation extends StatefulWidget {
  final VoidCallback? onProjectCreated;
  final SketchIDEProject? project; // For editing mode

  const SketchIDEProjectCreation({
    super.key,
    this.onProjectCreated,
    this.project, // Optional project for editing
  });

  @override
  State<SketchIDEProjectCreation> createState() =>
      _SketchIDEProjectCreationState();
}

class _SketchIDEProjectCreationState extends State<SketchIDEProjectCreation> {
  final _formKey = GlobalKey<FormState>();
  final _appNameController = TextEditingController();
  final _packageNameController = TextEditingController();
  final _projectNameController = TextEditingController();

  String? _selectedIconPath;
  bool _projectHasCustomIcon = false;
  int _projectVersionCode = 1;
  String _projectVersionName = '1.0';
  ProjectTemplate _selectedTemplate = ProjectTemplate.helloWorld;

  // Theme colors (like Sketchware Pro)
  final List<Color> _themeColors = [
    const Color(0xFF2196F3), // colorAccent
    const Color(0xFF3F51B5), // colorPrimary
    const Color(0xFF303F9F), // colorPrimaryDark
    const Color(0xFFE8EAF6), // colorControlHighlight
    const Color(0xFF757575), // colorControlNormal
  ];

  final List<String> _themeColorLabels = [
    'colorAccent',
    'colorPrimary',
    'colorPrimaryDark',
    'colorControlHighlight',
    'colorControlNormal',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final viewModel = context.read<ProjectViewModel>();

    if (widget.project != null) {
      // Editing mode - populate with existing project data
      final project = widget.project!;
      _appNameController.text = project.projectInfo.appName;
      _packageNameController.text = project.projectInfo.packageName;
      _projectNameController.text = project.projectInfo.projectName;
      _selectedIconPath = project.projectInfo.iconPath;
      _projectVersionCode = project.projectInfo.versionCode;
      _projectVersionName = project.projectInfo.versionName;
      _projectHasCustomIcon = project.projectInfo.iconPath != null;
    } else {
      // Creation mode - use ViewModel data
      _appNameController.text = viewModel.appName;
      _packageNameController.text = viewModel.packageName;
      _projectNameController.text = viewModel.appName; // Default to app name
    }

    // Listen for app name changes to update package name (only in creation mode)
    if (widget.project == null) {
      _appNameController.addListener(() {
        final appName = _appNameController.text;
        if (appName.isNotEmpty) {
          final packageName = _generatePackageName(appName);
          _packageNameController.text = packageName;
          _projectNameController.text = appName;
        }
      });
    }
  }

  String _generatePackageName(String appName) {
    final sanitizedName = appName
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '')
        .toLowerCase();
    return 'com.sketchide.$sanitizedName';
  }

  @override
  void dispose() {
    _appNameController.dispose();
    _packageNameController.dispose();
    _projectNameController.dispose();
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
        _projectHasCustomIcon = true;
      });
    }
  }

  void _onAppNameChanged(String value) {
    final viewModel = context.read<ProjectViewModel>();
    viewModel.setAppName(value);
  }

  Future<void> _createProject() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<ProjectViewModel>();
    viewModel.setIconPath(_selectedIconPath);
    viewModel.setProjectName(_projectNameController.text);
    viewModel.setVersionName(_projectVersionName);
    viewModel.setVersionCode(_projectVersionCode);

    bool success;
    if (widget.project != null) {
      // Editing mode - update existing project
      final updatedProject = widget.project!.copyWith(
        projectInfo: widget.project!.projectInfo.copyWith(
          appName: _appNameController.text.trim(),
          packageName: _packageNameController.text.trim(),
          projectName: _projectNameController.text.trim(),
          versionName: _projectVersionName,
          versionCode: _projectVersionCode,
          iconPath: _selectedIconPath,
          modifiedAt: DateTime.now(),
        ),
      );
      success = await viewModel.saveProject(updatedProject);
    } else {
      // Creation mode - create new project
      final project = await viewModel.createProject(
        appName: _appNameController.text.trim(),
        packageName: _packageNameController.text.trim(),
        projectName: _projectNameController.text.trim(),
        versionName: _projectVersionName,
        versionCode: _projectVersionCode,
        iconPath: _selectedIconPath,
        template: _selectedTemplate,
      );
      success = project != null;
    }

    if (success && mounted) {
      widget.onProjectCreated?.call();
      Navigator.of(context).pop();
    }
  }

  void _showVersionControlDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Version Control'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('Version Code'),
                      TextFormField(
                        initialValue: _projectVersionCode.toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _projectVersionCode = int.tryParse(value) ?? 1;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      const Text('Version Name'),
                      TextFormField(
                        initialValue: _projectVersionName,
                        onChanged: (value) {
                          setState(() {
                            _projectVersionName = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {});
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.project != null ? 'Edit Project' : 'Create New Project'),
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<ProjectViewModel>(
        builder: (context, viewModel, child) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // App Icon Section
                        Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 32),
                              GestureDetector(
                                onTap: _pickIcon,
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: _selectedIconPath != null
                                      ? ClipOval(
                                          child: Image.file(
                                            File(_selectedIconPath!),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Icon(
                                          Icons.add_photo_alternate,
                                          size: 32,
                                          color: Colors.grey[600],
                                        ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'App Icon',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // App Name Field
                        TextFormField(
                          controller: _appNameController,
                          decoration: const InputDecoration(
                            labelText: 'App Name',
                            hintText: 'Enter application name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.android),
                          ),
                          onChanged: _onAppNameChanged,
                          maxLength: 50,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9\s]')),
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'App name is required';
                            }
                            if (value.length > 50) {
                              return 'App name must be less than 50 characters';
                            }
                            if (RegExp(r'[^a-zA-Z0-9\s]').hasMatch(value)) {
                              return 'App name can only contain letters, numbers, and spaces';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Package Name Field
                        TextFormField(
                          controller: _packageNameController,
                          decoration: const InputDecoration(
                            labelText: 'Package Name',
                            hintText: 'com.my.newproject',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.code),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Package name is required';
                            }
                            if (!RegExp(
                                    r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)*$')
                                .hasMatch(value)) {
                              return 'Invalid package name format';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Project Name Field
                        TextFormField(
                          controller: _projectNameController,
                          decoration: const InputDecoration(
                            labelText: 'Project Name',
                            hintText: 'Enter project name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.folder),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Project name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 17),

                        // Template Selection Card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Project Template',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...ProjectTemplateInfo.templates.entries
                                    .map((entry) {
                                  final template = entry.key;
                                  final info = entry.value;
                                  final isSelected =
                                      template == _selectedTemplate;

                                  return RadioListTile<ProjectTemplate>(
                                    title: Row(
                                      children: [
                                        Text(
                                          info.icon,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                info.name,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                info.description,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    value: template,
                                    groupValue: _selectedTemplate,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedTemplate = value!;
                                      });
                                    },
                                    activeColor: Theme.of(context).primaryColor,
                                    contentPadding: EdgeInsets.zero,
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 17),

                        // Theme Colors Card (like Sketchware Pro)
                        Card(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: _themeColors
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            final index = entry.key;
                                            final color = entry.value;
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8),
                                              child: Column(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () =>
                                                        _showColorPicker(index),
                                                    child: Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        color: color,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color:
                                                              Colors.grey[300]!,
                                                          width: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    _themeColorLabels[index],
                                                    style: const TextStyle(
                                                        fontSize: 10),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                    const VerticalDivider(),
                                    IconButton(
                                      icon: const Icon(Icons.help_outline),
                                      onPressed: _showThemeColorHelp,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 13),

                        // Version Control Card (like Sketchware Pro)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        _projectVersionCode.toString(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Version code',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.settings,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        _projectVersionName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Version name',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _showVersionControlDialog,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(Icons.edit, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                            height: 64), // Bottom padding for action bar
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<ProjectViewModel>(
        builder: (context, viewModel, child) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading ? null : _createProject,
                    child: viewModel.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.project != null ? 'Save' : 'Create'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showColorPicker(int colorIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select ${_themeColorLabels[colorIndex]}'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _themeColors[colorIndex],
            onColorChanged: (color) {
              setState(() {
                _themeColors[colorIndex] = color;
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showThemeColorHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme Colors Help'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Theme colors define the visual appearance of your app:'),
            SizedBox(height: 8),
            Text('• colorAccent: Used for highlights and selections'),
            Text('• colorPrimary: Main brand color'),
            Text('• colorPrimaryDark: Status bar color'),
            Text('• colorControlHighlight: Button press effects'),
            Text('• colorControlNormal: Default control colors'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Simple Color Picker Widget
class ColorPicker extends StatefulWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
  });

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.pickerColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: _currentColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Center(
            child: Text(
              'Selected Color',
              style: TextStyle(
                color: _currentColor.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Colors.red,
            Colors.pink,
            Colors.purple,
            Colors.deepPurple,
            Colors.indigo,
            Colors.blue,
            Colors.lightBlue,
            Colors.cyan,
            Colors.teal,
            Colors.green,
            Colors.lightGreen,
            Colors.lime,
            Colors.yellow,
            Colors.amber,
            Colors.orange,
            Colors.deepOrange,
            Colors.brown,
            Colors.grey,
            Colors.blueGrey,
            Colors.black,
          ]
              .map((color) => GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentColor = color;
                      });
                      widget.onColorChanged(color);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _currentColor == color
                              ? Colors.black
                              : Colors.grey[300]!,
                          width: _currentColor == color ? 3 : 1,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
