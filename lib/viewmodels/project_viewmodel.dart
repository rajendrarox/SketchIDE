import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../domain/models/project.dart';
import '../data/repositories/project_repository.dart';

class ProjectViewModel extends ChangeNotifier {
  final ProjectRepository _repository = ProjectRepository();
  final Uuid _uuid = const Uuid();

  List<Project> _projects = [];
  bool _isLoading = false;
  String? _error;

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProjects => _projects.isNotEmpty;

  Future<void> initialize() async {
    try {
      await _repository.initialize();
      await loadProjects();
    } catch (e) {
      _error = 'Failed to initialize: $e';
      notifyListeners();
    }
  }

  Future<void> loadProjects() async {
    _setLoading(true);
    try {
      _projects = await _repository.getAllProjects();
      _error = null;
    } catch (e) {
      _error = 'Failed to load projects: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createProject({
    required String name,
    required String appName,
    required String packageName,
    String? iconPath,
    String? version,
    int? versionCode,
  }) async {
    _setLoading(true);
    try {
      final now = DateTime.now();
      final projectId = _uuid.v4();
      
      print('Creating project: $name');
      print('App name: $appName');
      print('Package name: $packageName');
      
      // Create project directory
      final projectPath = await _repository.createProjectDirectory(name);
      print('Project path created: $projectPath');
      
      final project = Project(
        id: projectId,
        name: name,
        appName: appName,
        packageName: packageName,
        iconPath: iconPath,
        createdAt: now,
        modifiedAt: now,
        version: version ?? '1.0.0',
        versionCode: versionCode ?? 1,
        projectPath: projectPath,
      );

      // Generate project structure
      await _repository.generateProjectStructure(project);
      print('Project structure generated');
      
      // Save to repository
      await _repository.saveProject(project);
      print('Project saved to repository');
      
      // Add to local list
      _projects.add(project);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error creating project: $e');
      _error = 'Failed to create project: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteProject(String projectId) async {
    _setLoading(true);
    try {
      await _repository.deleteProject(projectId);
      _projects.removeWhere((project) => project.id == projectId);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete project: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProject(Project updatedProject) async {
    _setLoading(true);
    try {
      final updatedProjectWithTimestamp = updatedProject.copyWith(
        modifiedAt: DateTime.now(),
      );
      
      await _repository.saveProject(updatedProjectWithTimestamp);
      
      final index = _projects.indexWhere((p) => p.id == updatedProject.id);
      if (index != -1) {
        _projects[index] = updatedProjectWithTimestamp;
      }
      
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update project: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  List<Project> searchProjects(String query) {
    if (query.isEmpty) return _projects;
    
    return _projects.where((project) {
      return project.name.toLowerCase().contains(query.toLowerCase()) ||
             project.appName.toLowerCase().contains(query.toLowerCase()) ||
             project.packageName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 