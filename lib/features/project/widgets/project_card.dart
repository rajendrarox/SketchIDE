import 'package:flutter/material.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import '../../../domain/models/project.dart';
import '../../../data/services/export_service.dart';
import '../../builder/screens/builder_screen.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Project Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200, width: 1),
                ),
                child: project.iconPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(project.iconPath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.android,
                        size: 40,
                        color: Colors.blue.shade600,
                      ),
              ),
              const SizedBox(width: 16),
              
              // Project Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Name
                    Text(
                      project.appName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Project Name with Version
                    Text(
                      '${project.name}-${project.version}(${project.versionCode})',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Package Name
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        project.packageName,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Settings Arrow
              GestureDetector(
                onTap: () {
                  _showProjectSettingsBottomSheet(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportProject(BuildContext context) async {
    try {
      // Show export location dialog
      final exportLocation = await ExportService.showExportLocationDialog(context);
      if (exportLocation == null) return; // User cancelled

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Creating Complete Backup'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Creating ${project.name}.ide...'),
              const SizedBox(height: 8),
              const Text(
                'Complete project backup with all files (this may take a moment)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

      // Export project with selected location
      final success = await ExportService.exportProjectWithLocation(project, exportLocation);

      // Hide loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show result
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                ? '✅ Complete backup saved as ${project.name}.ide'
                : '❌ Export failed: Please try again'
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: const Duration(seconds: 4),
            action: success ? SnackBarAction(
              label: 'View',
              onPressed: () {
                // Show backup details
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Complete Backup Saved'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Project: ${project.name}'),
                            const SizedBox(height: 8),
                            Text('File: ${project.name}.ide'),
                            const SizedBox(height: 8),
                            const Text(
                              'This backup contains ALL project files including:',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            const Text('• Source code files', style: TextStyle(fontSize: 11)),
                            const Text('• UI layout files', style: TextStyle(fontSize: 11)),
                            const Text('• Logic block files', style: TextStyle(fontSize: 11)),
                            const Text('• Asset files', style: TextStyle(fontSize: 11)),
                            const Text('• Configuration files', style: TextStyle(fontSize: 11)),
                            const SizedBox(height: 8),
                            Text(
                              'Location: ${_getLocationName(exportLocation)}',
                              style: const TextStyle(fontSize: 11, color: Colors.blue),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                });
              },
            ) : SnackBarAction(
              label: 'Settings',
              onPressed: () async {
                // Open app settings for permissions
                final Uri settingsUri = Uri(
                  scheme: 'package',
                  path: 'com.sketchide.app',
                );
                if (await canLaunchUrl(settingsUri)) {
                  await launchUrl(settingsUri);
                } else {
                  // Fallback to general settings
                  final Uri generalSettingsUri = Uri(
                    scheme: 'android-app',
                    host: 'com.android.settings',
                    path: 'com.android.settings.APPLICATION_DETAILS_SETTINGS',
                  );
                  await launchUrl(generalSettingsUri);
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Hide loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Export failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  String _getLocationName(String location) {
    switch (location) {
      case 'app_documents':
        return 'App Documents';
      case 'downloads':
        return 'Downloads Folder';
      case 'external_storage':
        return 'External Storage';
      case 'custom_location':
        return 'Custom Location';
      default:
        return 'Unknown Location';
    }
  }

  void _showProjectSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Project Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Change Project Settings'),
              onTap: () {
                Navigator.of(context).pop();
                onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Export Project'),
              onTap: () async {
                Navigator.of(context).pop();
                await _exportProject(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Export/Sign'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement export/sign
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Project Configuration'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement project configuration
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Project', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
} 