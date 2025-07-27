import 'package:flutter/foundation.dart';
import '../models/sketchide_project.dart';
import '../models/project_complexity.dart';
import '../services/project_service.dart';
import '../services/native_storage_service.dart'; // Added import for NativeStorageService

class ProjectViewModel extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();

  // State
  List<SketchIDEProject> _projects = [];
  List<SketchIDEProject> _filteredProjects = [];
  bool _isLoading = false;
  String? _error;
  String _appName = '';
  String _packageName = '';
  String _projectName = '';
  String _versionName = '1.0';
  int _versionCode = 1;
  String? _iconPath;
  bool _isStorageAccessible = false;

  // Search and Sort
  String _searchQuery = '';
  String _sortBy = 'modified'; // 'name', 'created', 'modified'

  // Getters
  List<SketchIDEProject> get projects => _projects;
  List<SketchIDEProject> get filteredProjects => _filteredProjects;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get appName => _appName;
  String get packageName => _packageName;
  String get projectName => _projectName;
  String get versionName => _versionName;
  int get versionCode => _versionCode;
  String? get iconPath => _iconPath;
  bool get hasProjects => _projects.isNotEmpty;
  bool get isStorageAccessible => _isStorageAccessible;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;

  // Initialize
  Future<void> initialize() async {
    // Don't automatically check storage on initialization
    // Let the user decide when to grant permissions
  }

  // Check storage accessibility (don't request automatically)
  Future<void> checkStorageAccessibility() async {
    print('DEBUG: ProjectViewModel.checkStorageAccessibility() called');
    try {
      _isStorageAccessible =
          await _projectService.isExternalStorageAccessible();
      print('DEBUG: isExternalStorageAccessible result: $_isStorageAccessible');
      if (!_isStorageAccessible) {
        _error = 'Storage permission required to access external storage';
        print('DEBUG: Setting error message: $_error');
      } else {
        _error = null;
        print('DEBUG: Storage accessible, loading projects...');
        await loadProjects(); // Load projects if storage is accessible
      }
      notifyListeners();
    } catch (e) {
      print('ERROR: Exception in checkStorageAccessibility: $e');
      _isStorageAccessible = false;
      _error = 'Error checking storage accessibility: $e';
      notifyListeners();
    }
  }

  // Request storage permission (only when user explicitly requests)
  Future<void> requestStoragePermission() async {
    try {
      final granted = await NativeStorageService.requestStoragePermission();
      if (granted) {
        _isStorageAccessible = true;
        _error = null;
        await loadProjects(); // Reload projects after permission granted
      } else {
        _isStorageAccessible = false;
        _error =
            'Storage permission denied. Please grant permission in settings.';
      }
      notifyListeners();
    } catch (e) {
      _isStorageAccessible = false;
      _error = 'Error requesting storage permission: $e';
      notifyListeners();
    }
  }

  // Open app settings
  Future<void> openAppSettings() async {
    await NativeStorageService.openAppSettings();
  }

  // Load all projects (only if storage is accessible)
  Future<void> loadProjects() async {
    if (!_isStorageAccessible) {
      // Don't automatically request permission, just return
      return;
    }

    _setLoading(true);
    try {
      _projects = await _projectService.getAllProjects();
      _applyFiltersAndSort(); // Apply current filters and sorting
      _error = null;
    } catch (e) {
      _error = 'Failed to load projects: $e';
      // Check if it's a permission error
      if (e.toString().contains('permission') ||
          e.toString().contains('Storage')) {
        _isStorageAccessible = false;
      }
    } finally {
      _setLoading(false);
    }
  }

  // Set app name (auto-generates package name)
  void setAppName(String appName) {
    _appName = appName;
    _packageName = _generatePackageName(appName);
    _projectName = appName; // Default project name to app name
    notifyListeners();
  }

  // Set project name
  void setProjectName(String projectName) {
    _projectName = projectName;
    notifyListeners();
  }

  // Set version name
  void setVersionName(String versionName) {
    _versionName = versionName;
    notifyListeners();
  }

  // Set version code
  void setVersionCode(int versionCode) {
    _versionCode = versionCode;
    notifyListeners();
  }

  // Set icon path
  void setIconPath(String? iconPath) {
    _iconPath = iconPath;
    notifyListeners();
  }

  // Search projects
  void searchProjects(String query) {
    _searchQuery = query.toLowerCase();
    _applyFiltersAndSort();
    notifyListeners();
  }

  // Sort projects
  void sortProjects(String sortBy) {
    _sortBy = sortBy;
    _applyFiltersAndSort();
    notifyListeners();
  }

  // Apply filters and sorting
  void _applyFiltersAndSort() {
    // Filter projects
    if (_searchQuery.isEmpty) {
      _filteredProjects = List.from(_projects);
    } else {
      _filteredProjects = _projects.where((project) {
        final appName = project.projectInfo.appName.toLowerCase();
        final projectName = project.projectInfo.projectName.toLowerCase();
        final packageName = project.projectInfo.packageName.toLowerCase();

        return appName.contains(_searchQuery) ||
            projectName.contains(_searchQuery) ||
            packageName.contains(_searchQuery);
      }).toList();
    }

    // Sort projects
    switch (_sortBy) {
      case 'name':
        _filteredProjects.sort((a, b) => a.projectInfo.appName
            .toLowerCase()
            .compareTo(b.projectInfo.appName.toLowerCase()));
        break;
      case 'created':
        _filteredProjects.sort((a, b) =>
            b.projectInfo.createdAt.compareTo(a.projectInfo.createdAt));
        break;
      case 'modified':
      default:
        _filteredProjects.sort((a, b) =>
            b.projectInfo.modifiedAt.compareTo(a.projectInfo.modifiedAt));
        break;
    }
  }

  // Add imported project
  void addImportedProject(SketchIDEProject project) {
    _projects.insert(0, project);
    _applyFiltersAndSort();
    notifyListeners();
  }

  // Create new project
  Future<SketchIDEProject?> createProject({
    required String appName,
    required String packageName,
    required String projectName,
    String versionName = '1.0',
    int versionCode = 1,
    String? iconPath,
    ProjectTemplate template = ProjectTemplate.helloWorld,
  }) async {
    if (!_isStorageAccessible) {
      await checkStorageAccessibility();
      if (!_isStorageAccessible) {
        return null;
      }
    }

    if (appName.trim().isEmpty) {
      _error = 'App name is required';
      notifyListeners();
      return null;
    }

    if (projectName.trim().isEmpty) {
      _error = 'Project name is required';
      notifyListeners();
      return null;
    }

    // Check if project already exists
    final exists = await _projectService.projectExists(appName);
    if (exists) {
      _error = 'A project with this name already exists';
      notifyListeners();
      return null;
    }

    _setLoading(true);
    try {
      final project = await _projectService.createProject(
        appName: appName.trim(),
        packageName: packageName.trim(),
        projectName: projectName.trim(),
        versionName: versionName,
        versionCode: versionCode,
        iconPath: iconPath,
        template: template,
      );

      _projects.insert(0, project); // Add to beginning
      _error = null;

      notifyListeners();
      return project;
    } catch (e) {
      _error = 'Failed to create project: $e';
      // Check if it's a permission error
      if (e.toString().contains('permission') ||
          e.toString().contains('Storage')) {
        _isStorageAccessible = false;
      }
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Delete project
  Future<bool> deleteProject(SketchIDEProject project) async {
    if (!_isStorageAccessible) {
      await checkStorageAccessibility();
      if (!_isStorageAccessible) {
        return false;
      }
    }

    _setLoading(true);
    try {
      // Use the project ID directly from the project object
      final projectId = project.projectId;
      await _projectService.deleteProject(projectId);

      // Remove from local list
      _projects.removeWhere((p) => p.projectId == project.projectId);
      _applyFiltersAndSort(); // Update filtered list
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete project: $e';
      // Check if it's a permission error
      if (e.toString().contains('permission') ||
          e.toString().contains('Storage')) {
        _isStorageAccessible = false;
      }
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Save project
  Future<bool> saveProject(SketchIDEProject project) async {
    if (!_isStorageAccessible) {
      await checkStorageAccessibility();
      if (!_isStorageAccessible) {
        return false;
      }
    }

    _setLoading(true);
    try {
      await _projectService.saveProject(project);

      // Update in list
      final index =
          _projects.indexWhere((p) => p.projectId == project.projectId);
      if (index != -1) {
        _projects[index] = project;
      }

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to save project: $e';
      // Check if it's a permission error
      if (e.toString().contains('permission') ||
          e.toString().contains('Storage')) {
        _isStorageAccessible = false;
      }
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Export project
  Future<String?> exportProject(SketchIDEProject project) async {
    if (!_isStorageAccessible) {
      await checkStorageAccessibility();
      if (!_isStorageAccessible) {
        return null;
      }
    }

    _setLoading(true);
    try {
      final exportPath = await _projectService.exportProject(project);
      _error = null;
      return exportPath;
    } catch (e) {
      _error = 'Failed to export project: $e';
      // Check if it's a permission error
      if (e.toString().contains('permission') ||
          e.toString().contains('Storage')) {
        _isStorageAccessible = false;
      }
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Import project
  Future<bool> importProject(String filePath) async {
    if (!_isStorageAccessible) {
      await checkStorageAccessibility();
      if (!_isStorageAccessible) {
        return false;
      }
    }

    _setLoading(true);
    try {
      final project = await _projectService.importProject(filePath);

      // Check if project already exists
      final exists = _projects
          .any((p) => p.projectInfo.appName == project.projectInfo.appName);

      if (exists) {
        _error = 'A project with this name already exists';
        notifyListeners();
        return false;
      }

      _projects.insert(0, project);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to import project: $e';
      // Check if it's a permission error
      if (e.toString().contains('permission') ||
          e.toString().contains('Storage')) {
        _isStorageAccessible = false;
      }
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset form
  void resetForm() {
    _appName = '';
    _packageName = '';
    _iconPath = null;
    _error = null;
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  String _generatePackageName(String appName) {
    final sanitizedName = appName
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '')
        .toLowerCase();

    return 'com.sketchide.$sanitizedName';
  }
}
