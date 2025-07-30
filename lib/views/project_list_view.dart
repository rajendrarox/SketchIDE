import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/project_viewmodel.dart';
import '../models/sketchide_project.dart';
import 'sketchide_project_creation.dart';
import '../data/services/export_service.dart';
import 'design_activity_screen.dart';

class ProjectListView extends StatefulWidget {
  const ProjectListView({super.key});

  @override
  State<ProjectListView> createState() => _ProjectListViewState();
}

class _ProjectListViewState extends State<ProjectListView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Check storage accessibility on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<ProjectViewModel>();
      viewModel.checkStorageAccessibility();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectViewModel>(
      builder: (context, viewModel, child) {
        // Show permission screen if storage is not accessible
        if (!viewModel.isStorageAccessible) {
          return _buildPermissionRequiredScreen(context, viewModel);
        }

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              await viewModel.loadProjects();
            },
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, viewModel),
                _buildProjectList(context, viewModel),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _createNewProject(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Project'),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }

  // Build permission required screen
  Widget _buildPermissionRequiredScreen(
      BuildContext context, ProjectViewModel viewModel) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_off,
                size: 80,
                color: Colors.orange[400],
              ),
              const SizedBox(height: 24),
              const Text(
                'Storage Permission Required',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'SketchIDE needs access to external storage to create and manage projects, just like Sketchware Pro.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Projects will be stored in: /storage/emulated/0/.sketchide/',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => viewModel.requestStoragePermission(),
                icon: const Icon(Icons.refresh),
                label: const Text('Grant Permission'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => viewModel.openAppSettings(),
                icon: const Icon(Icons.settings),
                label: const Text('Open Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build sliver app bar
  Widget _buildSliverAppBar(BuildContext context, ProjectViewModel viewModel) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Search Bar (like Sketchware Pro)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for projects...',
                    prefixIcon: const Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    final viewModel = context.read<ProjectViewModel>();
                    viewModel.searchProjects(value);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.sort, color: Colors.black),
          onPressed: _showSortDialog,
          tooltip: 'Sort Projects',
        ),
        IconButton(
          icon: const Icon(Icons.file_upload, color: Colors.black),
          onPressed: () => _importProject(context),
          tooltip: 'Import Project',
        ),
      ],
    );
  }

  // Build project list
  Widget _buildProjectList(BuildContext context, ProjectViewModel viewModel) {
    return SliverList(
      delegate: SliverChildListDelegate([
        // Special Action Item (Restore Projects)
        _buildSpecialActionItem(),
        // Projects Title
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 4, 6),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Projects',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: IconButton(
                  icon: const Icon(Icons.sort),
                  onPressed: _showSortDialog,
                  tooltip: 'Sort Projects',
                ),
              ),
            ],
          ),
        ),
        // Loading State
        if (viewModel.isLoading)
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 80),
                CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ],
            ),
          ),
        // Error State
        if (viewModel.error != null && !viewModel.isLoading)
          _buildErrorState(context, viewModel),
        // Empty State
        if (viewModel.projects.isEmpty &&
            !viewModel.isLoading &&
            viewModel.error == null)
          _buildEmptyState(context),
        // No Search Results State
        if (viewModel.projects.isNotEmpty &&
            viewModel.filteredProjects.isEmpty &&
            !viewModel.isLoading)
          _buildNoSearchResultsState(context),
        // Projects List
        if (viewModel.projects.isNotEmpty && !viewModel.isLoading)
          ...viewModel.filteredProjects.asMap().entries.map((entry) {
            final index = entry.key;
            final project = entry.value;
            return _buildProjectItem(context, project, viewModel, index);
          }).toList(),
        // Bottom padding for FAB
        const SizedBox(height: 100),
      ]),
    );
  }

  Widget _buildSpecialActionItem() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: _restoreProject,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.history,
                    color: Colors.blue[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Restore Projects',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Get your projects in a couple of clicks',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectItem(
    BuildContext context,
    SketchIDEProject project,
    ProjectViewModel viewModel,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => _openProject(context, project),
          onLongPress: () =>
              _showProjectOptionsBottomSheet(context, project, viewModel),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              children: [
                // Project Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!, width: 0.5),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: project.projectInfo.iconPath != null
                            ? Image.file(
                                File(project.projectInfo.iconPath!),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : _buildDefaultAppIcon(project.projectInfo.appName),
                      ),
                      // Project ID overlay (like Sketchware Pro)
                      Positioned(
                        bottom: 4,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              project.projectInfo.packageName.split('.').last,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Project Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Project Name with Version
                      Text(
                        '${project.projectInfo.projectName} - ${project.projectInfo.versionName} (${project.projectInfo.versionCode})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // App Name
                      Text(
                        project.projectInfo.appName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Package Name
                      Text(
                        project.projectInfo.packageName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Expand Button
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showProjectOptionsBottomSheet(
                        context, project, viewModel),
                    tooltip: 'Project Options',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ProjectViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'Error Loading Projects',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              viewModel.error ?? 'An unknown error occurred',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => viewModel.loadProjects(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'No Projects Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first project to get started',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showCreateProjectDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Project'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResultsState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'No Projects Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term or create a new project.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showCreateProjectDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Project'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SketchIDEProjectCreation(),
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Projects'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Name (A-Z)'),
              onTap: () {
                Navigator.pop(context);
                final viewModel = context.read<ProjectViewModel>();
                viewModel.sortProjects('name');
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Date Created'),
              onTap: () {
                Navigator.pop(context);
                final viewModel = context.read<ProjectViewModel>();
                viewModel.sortProjects('created');
              },
            ),
            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('Last Modified'),
              onTap: () {
                Navigator.pop(context);
                final viewModel = context.read<ProjectViewModel>();
                viewModel.sortProjects('modified');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showProjectOptionsBottomSheet(
    BuildContext context,
    SketchIDEProject project,
    ProjectViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                children: [
                  const Text(
                    'Project Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Options
            _buildBottomSheetOption(
              icon: Icons.settings,
              title: 'Change project settings',
              onTap: () {
                Navigator.pop(context);
                _openProjectSettings(context, project);
              },
            ),
            _buildBottomSheetOption(
              icon: Icons.history,
              title: 'Backup project',
              onTap: () {
                Navigator.pop(context);
                _backupProject(context, project, viewModel);
              },
            ),
            _buildBottomSheetOption(
              icon: Icons.download,
              title: 'Export/Sign',
              onTap: () {
                Navigator.pop(context);
                _exportProject(context, project, viewModel);
              },
            ),
            _buildBottomSheetOption(
              icon: Icons.toggle_on,
              title: 'Project configuration',
              onTap: () {
                Navigator.pop(context);
                _showProjectConfiguration(context, project);
              },
            ),
            _buildBottomSheetOption(
              icon: Icons.delete,
              title: 'Delete project',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                _deleteProject(context, project, viewModel);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _restoreProject() async {
    try {
      final viewModel = context.read<ProjectViewModel>();
      final importedProject = await ExportService.importProject();

      if (importedProject != null && mounted) {
        // Add to projects list
        viewModel.addImportedProject(importedProject);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restored: ${importedProject.projectInfo.appName}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restore cancelled or failed'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _openProject(BuildContext context, SketchIDEProject project) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            DesignActivityScreen(projectId: project.projectId),
      ),
    );
  }

  void _openProjectSettings(BuildContext context, SketchIDEProject project) {
    // Navigate to project creation form in edit mode
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SketchIDEProjectCreation(
          project: project, // Pass existing project for editing
          onProjectCreated: () {
            // Refresh project list after editing
            final viewModel = context.read<ProjectViewModel>();
            viewModel.loadProjects();
          },
        ),
      ),
    );
  }

  void _backupProject(BuildContext context, SketchIDEProject project,
      ProjectViewModel viewModel) async {
    try {
      final success = await ExportService.exportProject(project);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backed up: ${project.projectInfo.appName}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup failed'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _exportProject(BuildContext context, SketchIDEProject project,
      ProjectViewModel viewModel) async {
    try {
      final success = await ExportService.exportProject(project);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported: ${project.projectInfo.appName}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export failed'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showProjectConfiguration(
      BuildContext context, SketchIDEProject project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Project Configuration - ${project.projectInfo.appName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Configuration options:'),
            const SizedBox(height: 8),
            const Text('• Build settings'),
            const Text('• Dependencies'),
            const Text('• Permissions'),
            const Text('• Theme configuration'),
            const Text('• Platform settings'),
            const SizedBox(height: 8),
            Text(
              'Configuration functionality will be implemented in future updates.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteProject(BuildContext context, SketchIDEProject project,
      ProjectViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text(
          'Are you sure you want to delete "${project.projectInfo.appName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await viewModel.deleteProject(project);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Deleted: ${project.projectInfo.appName}'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Failed to delete: ${viewModel.error ?? 'Unknown error'}'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _importProject(BuildContext context) async {
    try {
      final viewModel = context.read<ProjectViewModel>();
      final importedProject = await ExportService.importProject();

      if (importedProject != null && context.mounted) {
        // Add to projects list
        viewModel.addImportedProject(importedProject);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imported: ${importedProject.projectInfo.appName}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Import cancelled or failed'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showPermissionHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Grant Storage Permission'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'For Android 10 and below:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('1. Go to Settings > Apps > SketchIDE\n'
                '2. Tap "Permissions"\n'
                '3. Enable "Storage" permission'),
            SizedBox(height: 16),
            Text(
              'For Android 11 and above:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('1. Go to Settings > Apps > SketchIDE\n'
                '2. Tap "Permissions"\n'
                '3. Enable "All files access"'),
            SizedBox(height: 16),
            Text(
              'This allows SketchIDE to access external storage like Sketchware Pro.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Create new project
  void _createNewProject(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SketchIDEProjectCreation(),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildDefaultAppIcon(String appName) {
    final initials = _getAppInitials(appName);
    final color = _getColorFromString(appName);

    return Container(
      color: color,
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getAppInitials(String appName) {
    if (appName.isEmpty) return 'A';

    final words = appName.trim().split(' ');
    if (words.length == 1) {
      return appName.substring(0, 1).toUpperCase();
    }

    final firstWord = words[0];
    final lastWord = words.last;

    if (firstWord == lastWord) {
      return firstWord.substring(0, 1).toUpperCase();
    }

    return '${firstWord.substring(0, 1)}${lastWord.substring(0, 1)}'
        .toUpperCase();
  }

  Color _getColorFromString(String text) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
      Colors.amber,
      Colors.deepPurple,
    ];

    int hash = 0;
    for (int i = 0; i < text.length; i++) {
      hash = text.codeUnitAt(i) + ((hash << 5) - hash);
    }

    return colors[hash.abs() % colors.length];
  }
}
