import 'package:flutter/material.dart';
import 'dart:io';

import '../services/project_service.dart';

class DependenciesScreen extends StatefulWidget {
  final String projectId;

  const DependenciesScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<DependenciesScreen> createState() => _DependenciesScreenState();
}

class _DependenciesScreenState extends State<DependenciesScreen> {
  int _selectedTabIndex = 0;

  List<Map<String, String>> _dependencies = [];
  List<Map<String, String>> _devDependencies = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPubspecYaml();
  }

  Future<void> _loadPubspecYaml() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final projectService = ProjectService();
      final filesDir =
          await projectService.getProjectFilesDirectory(widget.projectId);
      final pubspecFile = File('$filesDir/pubspec.yaml');

      if (!await pubspecFile.exists()) {
        setState(() {
          _error = 'pubspec.yaml not found in project';
          _isLoading = false;
        });
        return;
      }

      final content = await pubspecFile.readAsString();

      _dependencies.clear();
      _devDependencies.clear();

      final lines = content.split('\n');
      bool inDependencies = false;
      bool inDevDependencies = false;

      for (final line in lines) {
        final trimmedLine = line.trim();

        if (trimmedLine.startsWith('dependencies:')) {
          inDependencies = true;
          inDevDependencies = false;
        } else if (trimmedLine.startsWith('dev_dependencies:')) {
          inDependencies = false;
          inDevDependencies = true;
        } else if (trimmedLine.isEmpty || trimmedLine.startsWith('#')) {
          continue;
        } else if (inDependencies &&
            (line.startsWith('    ') || line.startsWith('  ')) &&
            !line.startsWith('    #') &&
            !line.startsWith('  #') &&
            line.trim().isNotEmpty) {
          final depLine = line.trim();
          final colonIndex = depLine.indexOf(':');
          if (colonIndex > 0) {
            final name = depLine.substring(0, colonIndex).trim();
            final version = depLine.substring(colonIndex + 1).trim();
            if (name.isNotEmpty &&
                version.isNotEmpty &&
                !name.contains('sdk')) {
              _dependencies.add({
                'name': name,
                'version': version,
              });
            }
          }
        } else if (inDevDependencies &&
            (line.startsWith('    ') || line.startsWith('  ')) &&
            !line.startsWith('    #') &&
            !line.startsWith('  #') &&
            line.trim().isNotEmpty) {
          final depLine = line.trim();
          final colonIndex = depLine.indexOf(':');
          if (colonIndex > 0) {
            final name = depLine.substring(0, colonIndex).trim();
            final version = depLine.substring(colonIndex + 1).trim();
            if (name.isNotEmpty &&
                version.isNotEmpty &&
                !name.contains('sdk')) {
              _devDependencies.add({
                'name': name,
                'version': version,
              });
            }
          }
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading pubspec.yaml: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _savePubspecYaml() async {
    try {
      final projectService = ProjectService();
      final filesDir =
          await projectService.getProjectFilesDirectory(widget.projectId);
      final pubspecFile = File('$filesDir/pubspec.yaml');

      if (!await pubspecFile.exists()) {
        setState(() {
          _error = 'pubspec.yaml not found in project';
        });
        return;
      }

      final content = await pubspecFile.readAsString();
      final lines = content.split('\n');
      final updatedLines = <String>[];

      bool inDependencies = false;
      bool inDevDependencies = false;
      bool dependenciesWritten = false;
      bool devDependenciesWritten = false;

      for (final line in lines) {
        if (line.trim().startsWith('dependencies:')) {
          inDependencies = true;
          inDevDependencies = false;
          updatedLines.add(line);

          if (!dependenciesWritten) {
            for (final dep in _dependencies) {
              updatedLines.add('    ${dep['name']}: ${dep['version']}');
            }
            dependenciesWritten = true;
          }
        } else if (line.trim().startsWith('dev_dependencies:')) {
          inDependencies = false;
          inDevDependencies = true;
          updatedLines.add(line);

          if (!devDependenciesWritten) {
            for (final dep in _devDependencies) {
              updatedLines.add('    ${dep['name']}: ${dep['version']}');
            }
            devDependenciesWritten = true;
          }
        } else if (inDependencies &&
            (line.trim().startsWith('    ') || line.trim().startsWith('  ')) &&
            !line.trim().startsWith('    #') &&
            !line.trim().startsWith('  #') &&
            line.trim().isNotEmpty) {
          continue;
        } else if (inDevDependencies &&
            (line.trim().startsWith('    ') || line.trim().startsWith('  ')) &&
            !line.trim().startsWith('    #') &&
            !line.trim().startsWith('  #') &&
            line.trim().isNotEmpty) {
          continue;
        } else if (line.trim().isEmpty &&
            (inDependencies || inDevDependencies)) {
          inDependencies = false;
          inDevDependencies = false;
          updatedLines.add(line);
        } else if (line.trim().startsWith('flutter:') ||
            line.trim().startsWith('environment:') ||
            line.trim().startsWith('name:') ||
            line.trim().startsWith('description:') ||
            line.trim().startsWith('publish_to:') ||
            line.trim().startsWith('version:')) {
          inDependencies = false;
          inDevDependencies = false;
          updatedLines.add(line);
        } else {
          updatedLines.add(line);
        }
      }

      final updatedContent = updatedLines.join('\n');
      await pubspecFile.writeAsString(updatedContent);

      await _loadPubspecYaml();
    } catch (e) {
      setState(() {
        _error = 'Error saving pubspec.yaml: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Manager'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPubspecYaml,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDependencyDialog(context),
            tooltip:
                'Add ${_selectedTabIndex == 0 ? 'Dependency' : 'Dev Dependency'}',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Library Manager',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        _buildDependenciesCard(),
        _buildDevDependenciesCard(),
        if (_selectedTabIndex == 0 || _selectedTabIndex == 1) ...[
          const SizedBox(height: 16),
          Expanded(
            child: _buildDependenciesList(
              _selectedTabIndex == 0 ? _dependencies : _devDependencies,
              _selectedTabIndex == 0 ? 'Dependencies' : 'Dev Dependencies',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDependenciesCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTabIndex = 0;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.inventory,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dependencies',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage app dependencies',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDevDependenciesCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTabIndex = 1;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.developer_mode,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dev Dependencies',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage development dependencies',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading pubspec.yaml',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadPubspecYaml,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDependenciesList(
      List<Map<String, String>> dependencies, String title) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: dependencies.isEmpty
          ? _buildEmptyState(title)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dependencies.length,
              itemBuilder: (context, index) {
                final dependency = dependencies[index];
                return _buildDependencyCard(dependency, index, dependencies);
              },
            ),
    );
  }

  Widget _buildEmptyState(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No $title',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first ${title.toLowerCase()} to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddDependencyDialog(context),
            icon: const Icon(Icons.add),
            label: Text('Add $title'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDependencyCard(Map<String, String> dependency, int index,
      List<Map<String, String>> dependencies) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.inventory,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          dependency['name'] ?? '',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Version: ${dependency['version'] ?? ''}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditDependencyDialog(
                    context, dependency, index, dependencies);
                break;
              case 'delete':
                _showDeleteConfirmation(context, index, dependencies);
                break;
              case 'update':
                _showUpdateDialog(context, dependency);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'update',
              child: Row(
                children: [
                  Icon(Icons.update),
                  SizedBox(width: 8),
                  Text('Update'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDependencyDialog(BuildContext context) {
    final nameController = TextEditingController();
    final versionController = TextEditingController();
    final isDevDependency = _selectedTabIndex == 1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${isDevDependency ? 'Dev ' : ''}Dependency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Package Name',
                hintText: 'e.g., http, provider',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: versionController,
              decoration: const InputDecoration(
                labelText: 'Version',
                hintText: 'e.g., ^1.0.0',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  versionController.text.isNotEmpty) {
                setState(() {
                  final newDependency = {
                    'name': nameController.text,
                    'version': versionController.text,
                  };
                  if (isDevDependency) {
                    _devDependencies.add(newDependency);
                  } else {
                    _dependencies.add(newDependency);
                  }
                });
                Navigator.pop(context);
                await _savePubspecYaml();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDependencyDialog(
      BuildContext context,
      Map<String, String> dependency,
      int index,
      List<Map<String, String>> dependencies) {
    final nameController = TextEditingController(text: dependency['name']);
    final versionController =
        TextEditingController(text: dependency['version']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Dependency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Package Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: versionController,
              decoration: const InputDecoration(
                labelText: 'Version',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                dependencies[index] = {
                  'name': nameController.text,
                  'version': versionController.text,
                };
              });
              Navigator.pop(context);
              await _savePubspecYaml();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, int index, List<Map<String, String>> dependencies) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dependency'),
        content: Text(
            'Are you sure you want to delete "${dependencies[index]['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                dependencies.removeAt(index);
              });
              Navigator.pop(context);
              await _savePubspecYaml();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, Map<String, String> dependency) {
    final versionController =
        TextEditingController(text: dependency['version']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update ${dependency['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current version: ${dependency['version']}'),
            const SizedBox(height: 16),
            TextField(
              controller: versionController,
              decoration: const InputDecoration(
                labelText: 'New Version',
                hintText: 'e.g., ^2.0.0',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (versionController.text.isNotEmpty) {
                final currentList =
                    _selectedTabIndex == 0 ? _dependencies : _devDependencies;
                final index = currentList
                    .indexWhere((dep) => dep['name'] == dependency['name']);

                if (index != -1) {
                  setState(() {
                    currentList[index] = {
                      'name': dependency['name']!,
                      'version': versionController.text,
                    };
                  });
                }
                Navigator.pop(context);
                await _savePubspecYaml();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
