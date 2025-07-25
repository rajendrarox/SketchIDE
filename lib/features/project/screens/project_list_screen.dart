import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/project_viewmodel.dart';
import '../../../domain/models/project.dart';
import '../../../data/services/export_service.dart';
import '../widgets/project_creation_bottom_sheet.dart';
import '../widgets/project_card.dart';
import '../../builder/screens/builder_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateProjectBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ProjectCreationBottomSheet(
        onCreateProject: ({required String name, required String appName, required String packageName, String? iconPath, String? version, int? versionCode}) async {
          final success = await context.read<ProjectViewModel>().createProject(
            name: name,
            appName: appName,
            packageName: packageName,
            iconPath: iconPath,
            version: version,
            versionCode: versionCode,
          );
          
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Project created successfully!')),
            );
          }
        },
      ),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  Future<void> _importProject() async {
    try {
      final importedProject = await ExportService.importProject();
      
      if (importedProject != null && mounted) {
        // TODO: Add the imported project to the repository
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project "${importedProject.name}" imported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditProjectBottomSheet(Project project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ProjectCreationBottomSheet(
        project: project,
        onCreateProject: ({required String name, required String appName, required String packageName, String? iconPath, String? version, int? versionCode}) async {
          final success = await context.read<ProjectViewModel>().updateProject(
            project.copyWith(
              name: name,
              appName: appName,
              packageName: packageName,
              iconPath: iconPath,
              version: version,
              versionCode: versionCode,
            ),
          );
          
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Project updated successfully!')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _searchQuery.isEmpty 
            ? const Text('Projects')
            : Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 246, 244, 244).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search projects...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    hintStyle: TextStyle(color: Color.fromARGB(179, 239, 236, 236)),
                  ),
                  style: const TextStyle(color: Color.fromARGB(255, 66, 64, 64), fontSize: 16),
                  onChanged: _onSearchChanged,
                ),
              ),
        actions: [
          if (_searchQuery.isEmpty) ...[
            IconButton(
              icon: const Icon(Icons.file_upload),
              onPressed: _importProject,
              tooltip: 'Import Project',
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _searchQuery = ' ';
                });
              },
            ),
          ] else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SketchIDE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create cross-platform applications',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Projects'),
              leading: const Icon(Icons.folder),
              selected: true,
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              title: const Text('Settings'),
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Navigate to settings
              },
            ),
            ListTile(
              title: const Text('About'),
              leading: const Icon(Icons.info),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Navigate to about
              },
            ),
          ],
        ),
      ),
      body: Consumer<ProjectViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${viewModel.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadProjects(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredProjects = viewModel.searchProjects(_searchQuery);

          if (filteredProjects.isEmpty) {
            if (_searchQuery.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No projects found for "$_searchQuery"',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No projects yet',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create your first project to get started',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _showCreateProjectBottomSheet,
                      icon: const Icon(Icons.add),
                      label: const Text('Create Project'),
                    ),
                  ],
                ),
              );
            }
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredProjects.length,
            itemBuilder: (context, index) {
              final project = filteredProjects[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                                  child: ProjectCard(
                    project: project,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BuilderScreen(project: project),
                        ),
                      );
                    },
                    onEdit: () {
                      _showEditProjectBottomSheet(project);
                    },
                    onDelete: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Project'),
                        content: Text('Are you sure you want to delete "${project.name}"? This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      final success = await viewModel.deleteProject(project.id);
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Project deleted successfully!')),
                        );
                      }
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateProjectBottomSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ProjectSearchDelegate extends SearchDelegate<String> {
  final Function(String) onSearchChanged;

  ProjectSearchDelegate({required this.onSearchChanged});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearchChanged('');
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        onSearchChanged('');
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearchChanged(query);
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    onSearchChanged(query);
    return const SizedBox.shrink();
  }
} 