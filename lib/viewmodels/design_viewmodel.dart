import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/flutter_widget_bean.dart';
import '../models/sketchide_project.dart';
import '../services/project_service.dart';
import '../services/view_pane_service.dart';
import '../services/widget_storage_service.dart';
import '../services/flutter_code_generator_service.dart';
import '../services/widget_sizing_service.dart';
import '../services/view_info_service.dart';

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
  String _currentLayout = 'main';

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
  String get currentLayout => _currentLayout;
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

        // SKETCHWARE PRO STYLE: Clear registered widgets to prevent memory leaks
        ViewInfoService().clearAllRegisteredWidgets();

        // Load widgets from storage
        _widgets = await WidgetStorageService.loadWidgets(
          projectId,
          _currentLayout,
        );

        // SKETCHWARE PRO STYLE: Start with clean mobile frame (no default widgets)

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
      // Save widgets to storage
      await WidgetStorageService.saveWidgets(
        _project!.projectId,
        _currentLayout,
        _widgets,
      );

      // Generate Flutter code
      await FlutterCodeGeneratorService.generateAndSaveCode(
        _project!.projectId,
        _widgets,
        _project!,
        _currentLayout == 'main' ? 'MainScreen' : _currentLayout,
      );

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

  /// Set current layout
  void setCurrentLayout(String layoutName) {
    _currentLayout = layoutName;
    notifyListeners();
  }

  /// Select a widget
  void selectWidget(FlutterWidgetBean widget) {
    print('🎯 DESIGN VIEWMODEL: selectWidget called for ${widget.id}');
    print('🎯 BEFORE: _selectedWidget = ${_selectedWidget?.id}');
    _selectedWidget = widget;
    print('🎯 AFTER: _selectedWidget = ${_selectedWidget?.id}');
    notifyListeners();
    print('🎯 NOTIFIED LISTENERS - UI should rebuild now');
  }

  /// SKETCHWARE PRO STYLE: Clear widget selection (like ViewEditor.java:287)
  void clearSelection() {
    print('🎯 DESIGN VIEWMODEL: clearSelection called');
    print('🎯 BEFORE: _selectedWidget = ${_selectedWidget?.id}');
    _selectedWidget = null;
    print('🎯 AFTER: _selectedWidget = null - Property panel should hide');
    notifyListeners();
    print('🎯 NOTIFIED LISTENERS - Property panel should hide now');
  }

  /// SKETCHWARE PRO STYLE: Add widget with proper sizing
  Future<void> addWidget(FlutterWidgetBean widget,
      {Size? containerSize}) async {
    // SKETCHWARE PRO STYLE: Generate proper type-based ID if using simple ID
    FlutterWidgetBean widgetWithProperId = widget;
    if (widget.id.startsWith('widget_')) {
      // This is a simple ID, generate proper type-based ID
      final properId = FlutterWidgetBean.generateId(widget.type, _widgets);
      widgetWithProperId = widget.copyWith(id: properId);
      print('🆔 GENERATED PROPER ID: ${widget.id} -> $properId');
    }

    // SKETCHWARE PRO STYLE: Apply proper sizing based on widget type
    // Use same fixed content area as mobile frame (360x568dp after status bar and toolbar)
    final availableSize =
        containerSize ?? const Size(360, 568); // Fixed content area dimensions
    final sizedWidget = _applyProperSizing(widgetWithProperId, availableSize);

    _widgets.add(sizedWidget);
    _selectedWidget = sizedWidget;
    _saveToHistory();

    // SKETCHWARE PRO STYLE: Notify UI immediately for instant property panel feedback
    notifyListeners();

    // Save widget to storage and generate code in real-time
    if (_project != null) {
      await WidgetStorageService.saveWidget(
        _project!.projectId,
        _currentLayout ?? 'main',
        sizedWidget,
      );

      // Generate updated Flutter code
      await FlutterCodeGeneratorService.updateCodeFile(
        _project!.projectId,
        _widgets,
        _project!,
        _currentLayout ?? 'MainScreen',
      );
    }

    notifyListeners();
  }

  /// SKETCHWARE PRO STYLE: Apply proper sizing to widget (like ViewEditor.java:730-735)
  FlutterWidgetBean _applyProperSizing(
      FlutterWidgetBean widget, Size containerSize) {
    // SKETCHWARE PRO STYLE: Get proper layout bean based on widget type
    final layoutBean =
        WidgetSizingService.getLayoutBean(widget.type, containerSize);

    // SKETCHWARE PRO STYLE: Calculate proper position
    final widgetSize =
        WidgetSizingService.getWidgetSize(widget.type, containerSize);
    final dropPosition = widget.position;
    final calculatedPosition = WidgetSizingService.calculateDropPosition(
      Offset(dropPosition.x, dropPosition.y),
      widgetSize,
      containerSize,
      widgetType: widget.type, // Pass widget type for special positioning
    );

    // SKETCHWARE PRO STYLE: Update widget with proper sizing
    return widget.copyWith(
      layout: layoutBean,
      position: PositionBean(
        x: calculatedPosition.dx,
        y: calculatedPosition.dy,
        width: widgetSize.width,
        height: widgetSize.height,
      ),
    );
  }

  /// Update widget properties with real-time ViewPane update
  Future<void> updateWidget(FlutterWidgetBean updatedWidget) async {
    final index = _widgets.indexWhere((w) => w.id == updatedWidget.id);
    if (index != -1) {
      // SKETCHWARE PRO STYLE: Debug logging for widget updates
      print('🔄 WIDGET UPDATE: ${updatedWidget.type} (${updatedWidget.id})');
      print('🔄 OLD PROPERTIES: ${_widgets[index].properties}');
      print('🔄 NEW PROPERTIES: ${updatedWidget.properties}');

      // SKETCHWARE PRO STYLE: Update widget in the list
      _widgets[index] = updatedWidget;

      // SKETCHWARE PRO STYLE: Update selected widget if it's the same
      if (_selectedWidget?.id == updatedWidget.id) {
        _selectedWidget = updatedWidget;
      }

      // SKETCHWARE PRO STYLE: Trigger immediate UI update
      notifyListeners();

      // SKETCHWARE PRO STYLE: Save to history for undo/redo
      _saveToHistory();

      // SKETCHWARE PRO STYLE: Save updated widget to storage and regenerate code
      if (_project != null) {
        await WidgetStorageService.saveWidget(
          _project!.projectId,
          _currentLayout,
          updatedWidget,
        );

        await FlutterCodeGeneratorService.updateCodeFile(
          _project!.projectId,
          _widgets,
          _project!,
          _currentLayout == 'main' ? 'MainScreen' : _currentLayout,
        );
      }
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
        id: FlutterWidgetBean.generateSimpleId(),
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

  /// Get root widgets (widgets without parents) for hierarchical rendering
  List<FlutterWidgetBean> getRootWidgets() {
    return _widgets
        .where((widget) =>
            widget.parentId == null ||
            widget.parentId == 'root' ||
            widget.parent == 'root')
        .toList();
  }

  /// Get all widgets (for child widget rendering)
  List<FlutterWidgetBean> get allWidgets => _widgets;

  /// Get widget by ID
  FlutterWidgetBean? getWidgetById(String widgetId) {
    try {
      return _widgets.firstWhere((widget) => widget.id == widgetId);
    } catch (e) {
      return null;
    }
  }

  /// Check if widget has children
  bool hasChildren(FlutterWidgetBean widget) {
    return widget.children.isNotEmpty;
  }

  /// Get child widgets for a parent widget
  List<FlutterWidgetBean> getChildWidgets(FlutterWidgetBean parentWidget) {
    final childIds = parentWidget.children;
    final childWidgets = <FlutterWidgetBean>[];

    for (final childId in childIds) {
      final childWidget = _widgets.firstWhere(
        (widget) => widget.id == childId,
        orElse: () => FlutterWidgetBean(
          id: childId,
          type: 'Unknown',
          properties: {},
          children: [],
          position: PositionBean(x: 0, y: 0, width: 100, height: 100),
          events: {},
          layout: LayoutBean(),
        ),
      );
      childWidgets.add(childWidget);
    }

    // Sort children by index (like Sketchware Pro)
    childWidgets.sort((a, b) => a.index.compareTo(b.index));
    return childWidgets;
  }
}
