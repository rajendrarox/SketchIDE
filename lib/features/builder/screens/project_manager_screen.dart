import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../../../domain/models/project.dart';
import 'code_editor_screen.dart';

class ProjectManagerScreen extends StatefulWidget {
  final Project project;

  const ProjectManagerScreen({
    super.key,
    required this.project,
  });

  @override
  State<ProjectManagerScreen> createState() => _ProjectManagerScreenState();
}

class _ProjectManagerScreenState extends State<ProjectManagerScreen> {
  List<ProjectFileItem> _fileItems = [];
  bool _isLoading = true;
  String _currentPath = '';
  List<String> _pathHistory = [];

  @override
  void initState() {
    super.initState();
    _currentPath = widget.project.projectPath;
    _loadCurrentDirectory();
  }

  Future<void> _loadCurrentDirectory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dir = Directory(_currentPath);
      if (await dir.exists()) {
        _fileItems = await _scanDirectory(dir);
      }
    } catch (e) {
      print('Error loading directory: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<ProjectFileItem>> _scanDirectory(Directory dir) async {
    final List<ProjectFileItem> items = [];
    
    try {
      final List<FileSystemEntity> entities = await dir.list().toList();
      
      // Separate directories and files
      final List<Directory> directories = [];
      final List<File> files = [];
      
      for (final entity in entities) {
        final name = path.basename(entity.path);
        
        // Skip hidden files and directories
        if (name.startsWith('.')) continue;
        
        if (entity is Directory) {
          directories.add(entity);
        } else if (entity is File) {
          files.add(entity);
        }
      }
      
      // Sort directories in specific order
      directories.sort((a, b) {
        final aName = path.basename(a.path).toLowerCase();
        final bName = path.basename(b.path).toLowerCase();
        
        // Define priority order for directories
        final order = [
          'android',
          'ios', 
          'assets',
          'build',
          'lib',
          'logic',
          'ui',
        ];
        
        final aIndex = order.indexOf(aName);
        final bIndex = order.indexOf(bName);
        
        // If both are in the order list, sort by their position
        if (aIndex != -1 && bIndex != -1) {
          return aIndex.compareTo(bIndex);
        }
        
        // If only one is in the order list, prioritize it
        if (aIndex != -1) return -1;
        if (bIndex != -1) return 1;
        
        // If neither is in the order list, sort alphabetically
        return aName.compareTo(bName);
      });
      
      // Sort files in specific order
      files.sort((a, b) {
        final aName = path.basename(a.path).toLowerCase();
        final bName = path.basename(b.path).toLowerCase();
        
        // Define priority order for files
        final order = [
          'meta.json',
          'pubspec.yaml',
          'icon.png',
        ];
        
        final aIndex = order.indexOf(aName);
        final bIndex = order.indexOf(bName);
        
        // If both are in the order list, sort by their position
        if (aIndex != -1 && bIndex != -1) {
          return aIndex.compareTo(bIndex);
        }
        
        // If only one is in the order list, prioritize it
        if (aIndex != -1) return -1;
        if (bIndex != -1) return 1;
        
        // If neither is in the order list, sort alphabetically
        return aName.compareTo(bName);
      });
      
      // Add directories first
      for (final directory in directories) {
        final name = path.basename(directory.path);
        items.add(ProjectFileItem(
          name: name,
          path: directory.path,
          isDirectory: true,
          icon: _getIconForDirectory(name),
        ));
      }
      
      // Then add files
      for (final file in files) {
        final name = path.basename(file.path);
        items.add(ProjectFileItem(
          name: name,
          path: file.path,
          isDirectory: false,
          icon: _getIconForFile(name),
          fileSize: await file.length(),
        ));
      }
    } catch (e) {
      print('Error scanning directory ${dir.path}: $e');
    }
    
    return items;
  }

  IconData _getIconForDirectory(String name) {
    switch (name.toLowerCase()) {
      case 'lib':
        return Icons.code;
      case 'android':
        return Icons.android;
      case 'ios':
        return Icons.phone_iphone;
      case 'assets':
        return Icons.folder_open;
      case 'ui':
        return Icons.view_agenda;
      case 'logic':
        return Icons.psychology;
      case 'build':
        return Icons.build;
      case 'src':
        return Icons.source;
      case 'res':
        return Icons.folder_special;
      case 'main':
        return Icons.home;
      case 'values':
        return Icons.settings;
      case 'drawable':
        return Icons.image;
      case 'mipmap-hdpi':
      case 'mipmap-mdpi':
      case 'mipmap-xhdpi':
      case 'mipmap-xxhdpi':
      case 'mipmap-xxxhdpi':
        return Icons.apps;
      case 'runner':
        return Icons.play_arrow;
      case 'assets.xcassets':
        return Icons.photo_library;
      case 'appicon.appiconset':
        return Icons.apps;
      case 'base.lproj':
        return Icons.language;
      default:
        return Icons.folder;
    }
  }

  IconData _getIconForFile(String name) {
    final extension = path.extension(name).toLowerCase();
    
    switch (extension) {
      case '.dart':
        return Icons.code;
      case '.json':
        return Icons.data_object;
      case '.yaml':
      case '.yml':
        return Icons.settings;
      case '.xml':
        return Icons.code;
      case '.kt':
      case '.java':
        return Icons.code;
      case '.swift':
        return Icons.code;
      case '.png':
      case '.jpg':
      case '.jpeg':
      case '.gif':
      case '.webp':
        return Icons.image;
      case '.mp3':
      case '.wav':
      case '.aac':
        return Icons.music_note;
      case '.ttf':
      case '.otf':
        return Icons.font_download;
      case '.gradle':
        return Icons.build;
      case '.plist':
        return Icons.settings;
      case '.podfile':
        return Icons.code;
      case '.md':
        return Icons.description;
      case '.txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _navigateToDirectory(String dirPath) {
    setState(() {
      _pathHistory.add(_currentPath);
      _currentPath = dirPath;
    });
    _loadCurrentDirectory();
  }

  void _navigateBack() {
    if (_pathHistory.isNotEmpty) {
      setState(() {
        _currentPath = _pathHistory.removeLast();
      });
      _loadCurrentDirectory();
    }
  }

  String _getRelativePath() {
    final projectPath = widget.project.projectPath;
    if (_currentPath == projectPath) {
      return 'Root';
    }
    return path.relative(_currentPath, from: projectPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Project Manager - ${widget.project.name}'),
            Text(
              _getRelativePath(),
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_pathHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.arrow_upward, color: Colors.black),
              onPressed: _navigateBack,
              tooltip: 'Go Back',
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadCurrentDirectory,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Project Info Header
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(
                          Icons.folder,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.project.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${widget.project.appName} (${widget.project.packageName})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${_fileItems.length} items',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // File List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _fileItems.length,
                    itemBuilder: (context, index) {
                      return _buildFileItem(_fileItems[index]);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFileItem(ProjectFileItem item) {
    final extension = path.extension(item.name).toLowerCase();
    final isCodeFile = [
      '.dart', '.json', '.yaml', '.yml', '.xml', '.kt', '.java', 
      '.swift', '.gradle', '.md', '.txt', '.plist', '.podfile'
    ].contains(extension);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      elevation: 1,
      child: ListTile(
        leading: Icon(
          item.icon,
          color: item.isDirectory 
              ? Colors.blue.shade600 
              : isCodeFile 
                  ? Colors.green.shade600 
                  : Colors.grey.shade600,
          size: 24,
        ),
        title: Text(
          item.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: item.isDirectory ? FontWeight.w500 : FontWeight.normal,
            color: item.isDirectory 
                ? Colors.blue.shade700 
                : isCodeFile 
                    ? Colors.green.shade700 
                    : Colors.grey.shade800,
          ),
        ),
        subtitle: item.isDirectory
            ? const Text('Directory')
            : Text(_formatFileSize(item.fileSize ?? 0)),
        trailing: item.isDirectory
            ? const Icon(Icons.arrow_forward_ios, size: 16)
            : isCodeFile
                ? const Icon(Icons.edit, size: 16, color: Colors.green)
                : null,
        onTap: () {
          if (item.isDirectory) {
            _navigateToDirectory(item.path);
          } else {
            _handleFileTap(item);
          }
        },
      ),
    );
  }

  void _handleFileTap(ProjectFileItem item) {
    final extension = path.extension(item.name).toLowerCase();
    final isCodeFile = [
      '.dart', '.json', '.yaml', '.yml', '.xml', '.kt', '.java', 
      '.swift', '.gradle', '.md', '.txt', '.plist', '.podfile'
    ].contains(extension);

    if (isCodeFile) {
      // Open in Code Editor
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CodeEditorScreen(
            project: widget.project,
            filePath: item.path,
            fileName: item.name,
          ),
        ),
      );
    } else {
      // Show file details dialog for non-code files
      _showFileDetails(item);
    }
  }

  void _showFileDetails(ProjectFileItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(item.icon, color: Colors.blue.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Path: ${item.path}'),
            const SizedBox(height: 8),
            Text('Size: ${_formatFileSize(item.fileSize ?? 0)}'),
            const SizedBox(height: 8),
            Text('Type: ${item.isDirectory ? 'Directory' : 'File'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class ProjectFileItem {
  final String name;
  final String path;
  final bool isDirectory;
  final IconData icon;
  final int? fileSize;

  ProjectFileItem({
    required this.name,
    required this.path,
    required this.isDirectory,
    required this.icon,
    this.fileSize,
  });
} 