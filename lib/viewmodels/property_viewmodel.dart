import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/flutter_widget_bean.dart';
import '../services/property_service.dart';
import '../services/view_pane_service.dart';
import '../widgets/property_items/property_text_box.dart';
import '../widgets/property_items/property_color_box.dart';
import '../widgets/property_items/property_selector_box.dart';

/// Property ViewModel - MVVM Pattern for Property Panel
/// Handles state management and property updates with real-time widget updates
class PropertyViewModel extends ChangeNotifier {
  final PropertyService _propertyService = PropertyService();
  final ViewPaneService _viewPaneService = ViewPaneService();

  // State
  FlutterWidgetBean? _selectedWidget;
  List<PropertyDefinition> _propertyDefinitions = [];
  Map<String, dynamic> _propertyValues = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  FlutterWidgetBean? get selectedWidget => _selectedWidget;
  List<PropertyDefinition> get propertyDefinitions => _propertyDefinitions;
  Map<String, dynamic> get propertyValues => _propertyValues;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ViewPaneService get viewPaneService => _viewPaneService;

  /// Select a widget and load its properties
  void selectWidget(FlutterWidgetBean widget) {
    _selectedWidget = widget;
    _loadProperties();
    notifyListeners();
  }

  /// Load properties for the selected widget
  void _loadProperties() {
    if (_selectedWidget == null) return;

    _setLoading(true);
    try {
      // Get property definitions from service
      _propertyDefinitions =
          _propertyService.getPropertiesForWidget(_selectedWidget!);

      // Extract current property values
      _propertyValues =
          _propertyService.extractPropertyValues(_selectedWidget!);

      _error = null;
    } catch (e) {
      _error = 'Failed to load properties: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Update a property value with real-time widget update
  void updateProperty(String key, dynamic value) {
    if (_selectedWidget == null) return;

    try {
      // Update the property values
      _propertyValues[key] = value;

      // Update the widget's properties
      _updateWidgetProperties(key, value);

      // Update widget in ViewPane for real-time changes
      _updateWidgetInViewPane();

      // Notify listeners for real-time update
      notifyListeners();

      _error = null;
    } catch (e) {
      _error = 'Failed to update property: $e';
      notifyListeners();
    }
  }

  /// Update widget properties based on property key
  void _updateWidgetProperties(String key, dynamic value) {
    if (_selectedWidget == null) return;

    // Update existing property models
    switch (_selectedWidget!.type) {
      case 'Text':
        _updateTextProperties(key, value);
        break;
      case 'TextField':
        _updateTextFieldProperties(key, value);
        break;
      case 'Container':
        _updateContainerProperties(key, value);
        break;
      case 'Icon':
        _updateIconProperties(key, value);
        break;
      case 'Row':
      case 'Column':
        _updateLayoutProperties(key, value);
        break;
      case 'Stack':
        _updateStackProperties(key, value);
        break;
    }
  }

  /// Update text widget properties
  void _updateTextProperties(String key, dynamic value) {
    if (_selectedWidget == null) return;

    final textProperties = _selectedWidget!.properties['textProperties'] ?? {};

    switch (key) {
      case 'text':
        textProperties['text'] = value;
        break;
      case 'textSize':
        textProperties['textSize'] = int.tryParse(value.toString()) ?? 12;
        break;
      case 'textColor':
        textProperties['textColor'] =
            value is int ? value : int.parse(value.toString());
        break;
      case 'textType':
        textProperties['textType'] = int.tryParse(value.toString()) ?? 0;
        break;
    }

    _selectedWidget!.properties['textProperties'] = textProperties;
  }

  /// Update text field widget properties
  void _updateTextFieldProperties(String key, dynamic value) {
    if (_selectedWidget == null) return;

    final textFieldProperties =
        _selectedWidget!.properties['textFieldProperties'] ?? {};

    switch (key) {
      case 'text':
        textFieldProperties['text'] = value;
        break;
      case 'hint':
        textFieldProperties['hint'] = value;
        break;
      case 'textSize':
        textFieldProperties['textSize'] = int.tryParse(value.toString()) ?? 12;
        break;
      case 'textColor':
        textFieldProperties['textColor'] =
            value is int ? value : int.parse(value.toString());
        break;
      case 'hintColor':
        textFieldProperties['hintColor'] =
            value is int ? value : int.parse(value.toString());
        break;
      case 'inputType':
        textFieldProperties['inputType'] = value;
        break;
    }

    _selectedWidget!.properties['textFieldProperties'] = textFieldProperties;
  }

  /// Update container widget properties
  void _updateContainerProperties(String key, dynamic value) {
    if (_selectedWidget == null) return;

    final containerProperties =
        _selectedWidget!.properties['containerProperties'] ?? {};

    switch (key) {
      case 'width':
        containerProperties['width'] = _parseMeasureValue(value);
        break;
      case 'height':
        containerProperties['height'] = _parseMeasureValue(value);
        break;
      case 'backgroundColor':
        containerProperties['backgroundColor'] =
            value is String ? value : '#${value.toRadixString(16)}';
        break;
      case 'borderColor':
        containerProperties['borderColor'] =
            value is String ? value : '#${value.toRadixString(16)}';
        break;
      case 'borderWidth':
        containerProperties['borderWidth'] =
            double.tryParse(value.toString()) ?? 1.0;
        break;
      case 'borderRadius':
        containerProperties['borderRadius'] =
            double.tryParse(value.toString()) ?? 0.0;
        break;
    }

    _selectedWidget!.properties['containerProperties'] = containerProperties;
  }

  /// Update icon widget properties
  void _updateIconProperties(String key, dynamic value) {
    if (_selectedWidget == null) return;

    final iconProperties = _selectedWidget!.properties['iconProperties'] ?? {};

    switch (key) {
      case 'iconName':
        iconProperties['iconName'] = value;
        break;
      case 'iconSize':
        iconProperties['iconSize'] = int.tryParse(value.toString()) ?? 24;
        break;
      case 'iconColor':
        iconProperties['iconColor'] =
            value is int ? value : int.parse(value.toString());
        break;
    }

    _selectedWidget!.properties['iconProperties'] = iconProperties;
  }

  /// Update layout widget properties
  void _updateLayoutProperties(String key, dynamic value) {
    if (_selectedWidget == null) return;

    final layoutProperties =
        _selectedWidget!.properties['layoutProperties'] ?? {};

    switch (key) {
      case 'mainAxisAlignment':
        layoutProperties['mainAxisAlignment'] = value;
        break;
      case 'crossAxisAlignment':
        layoutProperties['crossAxisAlignment'] = value;
        break;
      case 'mainAxisSize':
        layoutProperties['mainAxisSize'] = value;
        break;
    }

    _selectedWidget!.properties['layoutProperties'] = layoutProperties;
  }

  /// Update stack widget properties
  void _updateStackProperties(String key, dynamic value) {
    if (_selectedWidget == null) return;

    final stackProperties =
        _selectedWidget!.properties['stackProperties'] ?? {};

    switch (key) {
      case 'alignment':
        stackProperties['alignment'] = value;
        break;
      case 'fit':
        stackProperties['fit'] = value;
        break;
      case 'clipBehavior':
        stackProperties['clipBehavior'] = value;
        break;
    }

    _selectedWidget!.properties['stackProperties'] = stackProperties;
  }

  /// Parse measure value (width/height)
  int _parseMeasureValue(dynamic value) {
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'wrap content':
          return -2; // WRAP_CONTENT
        case 'match parent':
          return -1; // MATCH_PARENT
        default:
          return int.tryParse(value) ?? -2;
      }
    }
    return value is int ? value : -2;
  }

  /// Update widget in ViewPane for real-time changes
  void _updateWidgetInViewPane() {
    if (_selectedWidget == null) return;

    // Update the widget in ViewPane service
    _viewPaneService.updateWidget(_selectedWidget!.id, _selectedWidget!);
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

  /// Create property widgets for the UI
  List<Widget> createPropertyWidgets(
      Function(String, dynamic) onPropertyChanged) {
    return _propertyService.createPropertyWidgets(
      _propertyDefinitions,
      _propertyValues,
      onPropertyChanged,
    );
  }

  /// Clear selection
  void clearSelection() {
    _selectedWidget = null;
    _propertyDefinitions = [];
    _propertyValues = {};
    _error = null;
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  /// Get updated widget (for real-time preview)
  FlutterWidgetBean? getUpdatedWidget() {
    return _selectedWidget;
  }
}
