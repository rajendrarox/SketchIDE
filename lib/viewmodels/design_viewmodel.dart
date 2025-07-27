import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/flutter_widget_bean.dart';
import '../models/sketchide_project.dart';
import '../services/project_service.dart';
import '../services/view_pane_service.dart';

/// Design Tab Enum
enum DesignTab {
  design,
  code,
  logic,
}

/// Design ViewModel - MVVM Pattern for Visual Editor
class DesignViewModel extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  final ViewPaneService _viewPaneService = ViewPaneService();

  // State
  SketchIDEProject? _project;
  List<FlutterWidgetBean> _widgets = [];
  FlutterWidgetBean? _selectedWidget;
  DesignTab _currentTab = DesignTab.design;
  bool _isLoading = false;
  String? _error;
  String? _projectName;

  // History for undo/redo
  final List<Map<String, dynamic>> _history = [];
  int _historyIndex = -1;
  static const int _maxHistorySize = 50;

  // Getters
  SketchIDEProject? get project => _project;
  List<FlutterWidgetBean> get widgets => _widgets;
  FlutterWidgetBean? get selectedWidget => _selectedWidget;
  DesignTab get currentTab => _currentTab;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get projectName => _projectName;
  bool get canUndo => _historyIndex > 0;
  bool get canRedo => _historyIndex < _history.length - 1;
  ViewPaneService get viewPaneService => _viewPaneService;

  /// Load project from storage
  Future<void> loadProject(String projectId) async {
    _setLoading(true);
    try {
      _project = await _projectService.loadProject(projectId);
      if (_project != null) {
        _projectName = _project!.projectInfo.appName;
        // TODO: Load widgets from project
        _widgets = _loadWidgetsFromProject(_project!);
        _saveToHistory();
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to load project: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Save project to storage
  Future<void> saveProject() async {
    if (_project == null) return;

    _setLoading(true);
    try {
      // TODO: Save widgets to project
      _saveWidgetsToProject(_project!, _widgets);
      await _projectService.saveProject(_project!);
      _error = null;
    } catch (e) {
      _error = 'Failed to save project: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Set current tab
  void setTab(DesignTab tab) {
    _currentTab = tab;
    notifyListeners();
  }

  /// Select a widget
  void selectWidget(FlutterWidgetBean widget) {
    _selectedWidget = widget;
    notifyListeners();
  }

  /// Add a new widget
  void addWidget(FlutterWidgetBean widget) {
    _widgets.add(widget);
    _selectedWidget = widget;
    _saveToHistory();
    notifyListeners();
  }

  /// Update widget properties with real-time ViewPane update
  void updateWidget(FlutterWidgetBean updatedWidget) {
    final index = _widgets.indexWhere((w) => w.id == updatedWidget.id);
    if (index != -1) {
      _widgets[index] = updatedWidget;
      if (_selectedWidget?.id == updatedWidget.id) {
        _selectedWidget = updatedWidget;
      }

      // Update widget in ViewPane for real-time changes
      _viewPaneService.updateWidget(updatedWidget.id, updatedWidget);

      _saveToHistory();
      notifyListeners();
    }
  }

  /// Move widget to new position with real-time ViewPane update
  void moveWidget(FlutterWidgetBean movedWidget) {
    final index = _widgets.indexWhere((w) => w.id == movedWidget.id);
    if (index != -1) {
      _widgets[index] = movedWidget;
      if (_selectedWidget?.id == movedWidget.id) {
        _selectedWidget = movedWidget;
      }

      // Update widget layout in ViewPane for real-time changes
      _viewPaneService.updateWidgetLayout(movedWidget.id, movedWidget);

      _saveToHistory();
      notifyListeners();
    }
  }

  /// Delete selected widget
  void deleteSelectedWidget() {
    if (_selectedWidget != null) {
      _widgets.removeWhere((w) => w.id == _selectedWidget!.id);
      _selectedWidget = null;
      _saveToHistory();
      notifyListeners();
    }
  }

  /// Duplicate selected widget
  void duplicateSelectedWidget() {
    if (_selectedWidget != null) {
      final duplicatedWidget = _selectedWidget!.copyWith(
        id: FlutterWidgetBean.generateId(),
        position: _selectedWidget!.position.copyWith(
          x: _selectedWidget!.position.x + 20,
          y: _selectedWidget!.position.y + 20,
        ),
      );
      _widgets.add(duplicatedWidget);
      _selectedWidget = duplicatedWidget;
      _saveToHistory();
      notifyListeners();
    }
  }

  /// Align widgets
  void alignWidgets(Alignment alignment) {
    if (_widgets.isEmpty) return;

    final selectedWidgets = _widgets.where((w) => w.isSelected).toList();
    if (selectedWidgets.isEmpty && _selectedWidget != null) {
      selectedWidgets.add(_selectedWidget!);
    }

    if (selectedWidgets.isEmpty) return;

    double targetX = 0;
    double targetY = 0;

    // Calculate target position based on alignment
    switch (alignment) {
      case Alignment.centerLeft:
        targetX = selectedWidgets
            .map((w) => w.position.x)
            .reduce((a, b) => a < b ? a : b);
        break;
      case Alignment.center:
        final minX = selectedWidgets
            .map((w) => w.position.x)
            .reduce((a, b) => a < b ? a : b);
        final maxX = selectedWidgets
            .map((w) => w.position.x + w.position.width)
            .reduce((a, b) => a > b ? a : b);
        targetX = minX + (maxX - minX) / 2;
        break;
      case Alignment.centerRight:
        targetX = selectedWidgets
            .map((w) => w.position.x + w.position.width)
            .reduce((a, b) => a > b ? a : b);
        break;
      default:
        return;
    }

    // Apply alignment to selected widgets
    for (final widget in selectedWidgets) {
      final index = _widgets.indexWhere((w) => w.id == widget.id);
      if (index != -1) {
        _widgets[index] = widget.copyWith(
          position: widget.position.copyWith(x: targetX),
        );
      }
    }

    _saveToHistory();
    notifyListeners();
  }

  /// Undo last action
  void undo() {
    if (canUndo) {
      _historyIndex--;
      _restoreFromHistory();
      notifyListeners();
    }
  }

  /// Redo last action
  void redo() {
    if (canRedo) {
      _historyIndex++;
      _restoreFromHistory();
      notifyListeners();
    }
  }

  /// Save current state to history
  void _saveToHistory() {
    // Remove any history after current index
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }

    // Add current state to history
    _history.add({
      'widgets': _widgets.map((w) => w.toJson()).toList(),
      'selectedWidgetId': _selectedWidget?.id,
    });

    // Limit history size
    if (_history.length > _maxHistorySize) {
      _history.removeAt(0);
    } else {
      _historyIndex++;
    }
  }

  /// Restore state from history
  void _restoreFromHistory() {
    if (_historyIndex >= 0 && _historyIndex < _history.length) {
      final state = _history[_historyIndex];

      _widgets = (state['widgets'] as List)
          .map((json) => FlutterWidgetBean.fromJson(json))
          .toList();

      final selectedWidgetId = state['selectedWidgetId'] as String?;
      _selectedWidget = selectedWidgetId != null
          ? _widgets.firstWhere((w) => w.id == selectedWidgetId)
          : null;
    }
  }

  /// Load widgets from project (placeholder)
  List<FlutterWidgetBean> _loadWidgetsFromProject(SketchIDEProject project) {
    // TODO: Implement loading widgets from project JSON
    // For now, return empty list
    return [];
  }

  /// Save widgets to project (placeholder)
  void _saveWidgetsToProject(
      SketchIDEProject project, List<FlutterWidgetBean> widgets) {
    // TODO: Implement saving widgets to project JSON
    // This will update the project's JSON structure with widget data
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Register a widget with ViewPane for real-time updates
  void registerWidgetWithViewPane(
      String widgetId, Widget widget, FlutterWidgetBean widgetBean) {
    _viewPaneService.registerWidget(widgetId, widget, widgetBean);
  }

  /// Unregister a widget from ViewPane
  void unregisterWidgetFromViewPane(String widgetId) {
    _viewPaneService.unregisterWidget(widgetId);
  }
}
