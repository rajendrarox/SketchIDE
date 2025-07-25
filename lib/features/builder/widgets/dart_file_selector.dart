import 'package:flutter/material.dart';
import '../models/dart_file_bean.dart';
import '../../../domain/models/project.dart';
import '../services/dart_file_manager.dart';

class DartFileSelector extends StatefulWidget {
  final Project project;
  final DartFileBean? selectedFile;
  final Function(DartFileBean) onFileSelected;
  final VoidCallback? onAddFile;

  const DartFileSelector({
    super.key,
    required this.project,
    this.selectedFile,
    required this.onFileSelected,
    this.onAddFile,
  });

  @override
  State<DartFileSelector> createState() => _DartFileSelectorState();
}

class _DartFileSelectorState extends State<DartFileSelector> {
  List<DartFileBean> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  @override
  void didUpdateWidget(DartFileSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project != widget.project) {
      _loadFiles();
    }
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final files = await DartFileManager.getAllDartFiles(widget.project);
      setState(() {
        _files = files;
        _isLoading = false;
      });

      // Auto-select default file if none selected
      if (widget.selectedFile == null && files.isNotEmpty) {
        final defaultFile = files.firstWhere(
          (file) => file.isDefault,
          orElse: () => files.first,
        );
        widget.onFileSelected(defaultFile);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading Dart files: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          // File selector dropdown
          Expanded(
            child: _buildFileSelector(),
          ),
          // Add file button
          Container(
            width: 48,
            height: 48,
            child: IconButton(
              onPressed: _showAddFileDialog,
              icon: const Icon(Icons.add),
              tooltip: 'Add Dart File',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileSelector() {
    if (_isLoading) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_files.isEmpty) {
      return const Center(
        child: Text(
          'No files available',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return DropdownButtonHideUnderline(
      child: DropdownButton<DartFileBean>(
        value: widget.selectedFile,
        isExpanded: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        items: _files.map((file) {
          return DropdownMenuItem<DartFileBean>(
            value: file,
            child: Row(
              children: [
                Icon(
                  file.icon,
                  size: 16,
                  color: file.isDefault ? Colors.blue : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    file.displayName,
                    style: TextStyle(
                      fontWeight: file.isDefault ? FontWeight.bold : FontWeight.normal,
                      color: file.isDefault ? Colors.blue : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (file.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'DEFAULT',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
        onChanged: (DartFileBean? file) {
          if (file != null) {
            widget.onFileSelected(file);
          }
        },
      ),
    );
  }

  void _showAddFileDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddFileDialog(
        project: widget.project,
        onFileCreated: (file) {
          setState(() {
            _files.add(file);
          });
          widget.onFileSelected(file);
        },
      ),
    );
  }
}

class _AddFileDialog extends StatefulWidget {
  final Project project;
  final Function(DartFileBean) onFileCreated;

  const _AddFileDialog({
    required this.project,
    required this.onFileCreated,
  });

  @override
  State<_AddFileDialog> createState() => _AddFileDialogState();
}

class _AddFileDialogState extends State<_AddFileDialog> {
  DartFileType _selectedType = DartFileType.page;
  final _nameController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Dart File'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // File type selector
          DropdownButtonFormField<DartFileType>(
            value: _selectedType,
            decoration: const InputDecoration(
              labelText: 'File Type',
              border: OutlineInputBorder(),
            ),
            items: [
              DartFileType.page,
              DartFileType.service,
              DartFileType.model,
              DartFileType.widget,
            ].map((type) {
              return DropdownMenuItem<DartFileType>(
                value: type,
                child: Row(
                  children: [
                    Icon(_getIconForType(type)),
                    const SizedBox(width: 8),
                    Text(type.displayName),
                  ],
                ),
              );
            }).toList(),
            onChanged: (DartFileType? type) {
              if (type != null) {
                setState(() {
                  _selectedType = type;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          // Name input
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              hintText: _getHintText(),
              border: const OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isCreating ? null : _createFile,
          child: _isCreating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  String _getHintText() {
    switch (_selectedType) {
      case DartFileType.page:
        return 'e.g., LoginPage, HomePage';
      case DartFileType.service:
        return 'e.g., AuthService, ApiService';
      case DartFileType.model:
        return 'e.g., User, Product';
      case DartFileType.widget:
        return 'e.g., CustomButton, LoadingWidget';
      default:
        return 'Enter name';
    }
  }

  IconData _getIconForType(DartFileType type) {
    switch (type) {
      case DartFileType.page:
        return Icons.pageview;
      case DartFileType.service:
        return Icons.build;
      case DartFileType.model:
        return Icons.data_object;
      case DartFileType.widget:
        return Icons.widgets;
      default:
        return Icons.file_present;
    }
  }

  Future<void> _createFile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final newFile = await DartFileManager.createDartFile(
        widget.project,
        _selectedType,
        name,
      );

      widget.onFileCreated(newFile);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Created ${newFile.fileName}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isCreating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 