import 'package:flutter/material.dart';
import '../widgets/droppable_mobile_frame.dart';

enum HistoryActionType {
  add,
  update,
  remove,
  move,
  override,
}

class HistoryEntry {
  final HistoryActionType actionType;
  final String widgetId;
  final PlacedWidget? addedWidget;
  final PlacedWidget? removedWidget;
  final PlacedWidget? previousWidget;
  final PlacedWidget? currentWidget;
  final int? previousIndex;
  final int? currentIndex;
  final DateTime timestamp;

  HistoryEntry({
    required this.actionType,
    required this.widgetId,
    this.addedWidget,
    this.removedWidget,
    this.previousWidget,
    this.currentWidget,
    this.previousIndex,
    this.currentIndex,
    required this.timestamp,
  });
}

class HistoryManager extends ChangeNotifier {
  final List<HistoryEntry> _history = [];
  int _currentIndex = -1;
  static const int _maxHistorySize = 50;

  bool get canUndo => _currentIndex >= 0;
  bool get canRedo => _currentIndex < _history.length - 1;

  void addEntry(HistoryEntry entry) {
    // Remove any entries after current index (when user does new action after undo)
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }

    _history.add(entry);
    _currentIndex = _history.length - 1;

    // Limit history size
    if (_history.length > _maxHistorySize) {
      _history.removeAt(0);
      _currentIndex--;
    }

    notifyListeners();
  }

  HistoryEntry? undo() {
    if (!canUndo) return null;

    final entry = _history[_currentIndex];
    _currentIndex--;
    notifyListeners();
    return entry;
  }

  HistoryEntry? redo() {
    if (!canRedo) return null;

    _currentIndex++;
    final entry = _history[_currentIndex];
    notifyListeners();
    return entry;
  }

  void clear() {
    _history.clear();
    _currentIndex = -1;
    notifyListeners();
  }

  // Helper methods for common actions
  void addWidget(PlacedWidget widget) {
    addEntry(HistoryEntry(
      actionType: HistoryActionType.add,
      widgetId: widget.id,
      addedWidget: widget,
      timestamp: DateTime.now(),
    ));
  }

  void removeWidget(PlacedWidget widget, int index) {
    addEntry(HistoryEntry(
      actionType: HistoryActionType.remove,
      widgetId: widget.id,
      removedWidget: widget,
      previousIndex: index,
      timestamp: DateTime.now(),
    ));
  }

  void updateWidget(PlacedWidget previousWidget, PlacedWidget currentWidget) {
    addEntry(HistoryEntry(
      actionType: HistoryActionType.update,
      widgetId: currentWidget.id,
      previousWidget: previousWidget,
      currentWidget: currentWidget,
      timestamp: DateTime.now(),
    ));
  }

  void moveWidget(PlacedWidget widget, int fromIndex, int toIndex) {
    addEntry(HistoryEntry(
      actionType: HistoryActionType.move,
      widgetId: widget.id,
      currentWidget: widget,
      previousIndex: fromIndex,
      currentIndex: toIndex,
      timestamp: DateTime.now(),
    ));
  }
} 