import 'package:flutter/material.dart';
import 'draggable_widget_palette.dart' as palette;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/widget_data.dart';
import '../models/dart_file_bean.dart';
import '../services/file_sync_service.dart';
import '../services/dart_file_manager.dart';
import '../screens/property_editor_screen.dart';
import '../../../domain/models/project.dart';

class DroppableMobileFrame extends StatefulWidget {
  final Function(PlacedWidget) onWidgetPlaced;
  final Function(PlacedWidget) onWidgetSelected;
  final Function(PlacedWidget) onWidgetDeleted;
  final String projectId;
  final Project project;
  final DartFileBean? selectedFile;

  const DroppableMobileFrame({
    super.key,
    required this.onWidgetPlaced,
    required this.onWidgetSelected,
    required this.onWidgetDeleted,
    required this.projectId,
    required this.project,
    this.selectedFile,
  });

  @override
  State<DroppableMobileFrame> createState() => _DroppableMobileFrameState();
}

class _DroppableMobileFrameState extends State<DroppableMobileFrame> {
  final List<PlacedWidget> _placedWidgets = [];
  PlacedWidget? _selectedWidget;
  bool _isDragOver = false;

  @override
  void initState() {
    super.initState();
    _loadWidgets();
  }

  @override
  void didUpdateWidget(DroppableMobileFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload widgets when selected file changes
    if (oldWidget.selectedFile?.fileName != widget.selectedFile?.fileName) {
      debugPrint('File changed from ${oldWidget.selectedFile?.fileName} to ${widget.selectedFile?.fileName}');
      _loadWidgets();
    }
  }



  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: DragTarget<palette.WidgetData>(
          onWillAccept: (data) => true,
          onAccept: (widgetData) {
            _addWidget(widgetData);
          },
          onMove: (details) {
            setState(() {
              _isDragOver = true;
            });
          },
          onLeave: (data) {
            setState(() {
              _isDragOver = false;
            });
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              width: 320,
              height: 640,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: _isDragOver ? Colors.blue : Colors.grey.shade400,
                  width: _isDragOver ? 3 : 2,
                ),
              ),
              child: Stack(
                children: [
                  // Status bar
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 25,
                      color: const Color(0xFF0084C2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text(
                              'main.xml',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.signal_cellular_4_bar, color: Colors.white, size: 12),
                              const SizedBox(width: 2),
                              Icon(Icons.wifi, color: Colors.white, size: 12),
                              const SizedBox(width: 2),
                              Icon(Icons.battery_full, color: Colors.white, size: 12),
                            ],
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                  // Toolbar
                  Positioned(
                    top: 25,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 48,
                      color: const Color(0xFF008DCD),
                      child: const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Text(
                              'Toolbar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Content area
                  Positioned(
                    top: 73,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      color: Colors.grey.shade50,
                      child: _placedWidgets.isEmpty ? _buildEmptyState() : _buildWidgetsList(),
                    ),
                  ),
                  // Drop indicator
                  if (_isDragOver)
                    Positioned.fill(
                      child: Container(
                        color: Colors.blue.withOpacity(0.1),
                        child: const Center(
                          child: Text(
                            'Drop here',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.phone_android,
            size: 48,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Drag widgets here',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _placedWidgets.length,
      itemBuilder: (context, index) {
        final widget = _placedWidgets[index];
        return _buildPlacedWidget(widget, index);
      },
    );
  }

  Widget _buildPlacedWidget(PlacedWidget widget, int index) {
    final isSelected = _selectedWidget == widget;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectWidget(widget),
          onLongPress: () => _showWidgetOptions(widget, index),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: _buildWidgetPreview(widget),
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetPreview(PlacedWidget widget) {
    switch (widget.type) {
      case 'text':
        return Text(
          widget.properties['text'] ?? 'Text',
          style: TextStyle(
            fontSize: widget.properties['fontSize']?.toDouble() ?? 16,
            color: _parseColor(widget.properties['color']),
          ),
        );
      case 'button':
        return ElevatedButton(
          onPressed: () {},
          child: Text(widget.properties['text'] ?? 'Button'),
        );
      case 'edittext':
        return TextField(
          decoration: InputDecoration(
            hintText: widget.properties['hintText'] ?? 'Enter text...',
            border: const OutlineInputBorder(),
          ),
        );
      case 'image':
        return Container(
          height: 100,
          color: Colors.grey.shade200,
          child: const Icon(Icons.image, size: 32),
        );
      case 'checkbox':
        return Row(
          children: [
            Checkbox(value: false, onChanged: (value) {}),
            Text(widget.properties['text'] ?? 'Checkbox'),
          ],
        );
      case 'switch':
        return Row(
          children: [
            Switch(value: false, onChanged: (value) {}),
            Text(widget.properties['text'] ?? 'Switch'),
          ],
        );
      case 'progressbar':
        return LinearProgressIndicator(
          value: widget.properties['value']?.toDouble() ?? 0.5,
        );
      case 'appbar':
        return Container(
          height: 56,
          color: Colors.blue,
          child: Row(
            children: [
              const SizedBox(width: 16),
              Text(
                widget.properties['title'] ?? 'App Title',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      case 'center':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'Center',
            style: TextStyle(color: Colors.blue, fontSize: 12),
          ),
        );
      case 'scaffold':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'Scaffold',
            style: TextStyle(color: Colors.green, fontSize: 12),
          ),
        );
      case 'materialapp':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.purple, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'MaterialApp',
            style: TextStyle(color: Colors.purple, fontSize: 12),
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(8),
          color: Colors.grey.shade200,
          child: Text('${widget.type} Widget'),
        );
    }
  }

  void _addWidget(palette.WidgetData widgetData) {
    // Generate unique ID like Sketchware Pro
    final widgetId = _generateWidgetId(widgetData.type);
    
    final placedWidget = PlacedWidget(
      id: widgetId,
      type: widgetData.type,
      properties: {
        ...Map<String, dynamic>.from(widgetData.defaultProperties),
        'fileId': widget.selectedFile?.fileName ?? 'unknown',
      },
    );
    
    setState(() {
      _placedWidgets.add(placedWidget);
      _selectedWidget = placedWidget;
      _isDragOver = false;
    });
    
    widget.onWidgetPlaced(placedWidget);
    _saveWidgets();
    
    // Debug information
    debugPrint('Added widget: ${widgetData.name} (${widgetData.type}) with ID: $widgetId to file: ${widget.selectedFile?.fileName}');
    debugPrint('Total widgets in frame: ${_placedWidgets.length}');
  }

  // Generate sequential widget ID like Sketchware Pro
  String _generateWidgetId(String widgetType) {
    final prefix = _getWidgetTypePrefix(widgetType);
    
    // Count existing widgets of the same type
    int count = 1;
    for (final widget in _placedWidgets) {
      if (widget.type == widgetType) {
        count++;
      }
    }
    
    return '${prefix}$count';
  }

  // Get widget type prefix like Sketchware Pro's wq.b() method
  String _getWidgetTypePrefix(String widgetType) {
    switch (widgetType) {
      case 'column':
        return 'column';
      case 'row':
        return 'row';
      case 'stack':
        return 'stack';
      case 'text':
        return 'text';
      case 'button':
        return 'button';
      case 'edittext':
        return 'edittext';
      case 'image':
        return 'image';
      case 'checkbox':
        return 'checkbox';
      case 'switch':
        return 'switch';
      case 'progressbar':
        return 'progressbar';
      case 'appbar':
        return 'appbar';
      case 'center':
        return 'center';
      case 'scaffold':
        return 'scaffold';
      case 'materialapp':
        return 'materialapp';
      default:
        return 'widget';
    }
  }

  void _selectWidget(PlacedWidget widget) {
    setState(() {
      _selectedWidget = widget;
    });
    this.widget.onWidgetSelected(widget);
  }

  void _openPropertyEditor(PlacedWidget widget) {
    // Convert PlacedWidget to WidgetData for property editor
    final widgetData = WidgetData(
      id: widget.id,
      type: widget.type,
      properties: widget.properties,
    );

    // Navigate to property editor screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyEditorScreen(
          widget: widgetData,
          project: this.widget.project,
          file: this.widget.selectedFile!,
          onPropertyChanged: (updatedWidget) {
            // Update the widget in the mobile frame
            setState(() {
              final widgetIndex = _placedWidgets.indexWhere((w) => w.id == updatedWidget.id);
              if (widgetIndex != -1) {
                _placedWidgets[widgetIndex] = PlacedWidget(
                  id: updatedWidget.id,
                  type: updatedWidget.type,
                  properties: updatedWidget.properties,
                );
                _selectedWidget = _placedWidgets[widgetIndex];
              }
            });
            
            // Save changes
            _saveWidgets();
            
            // Notify parent
            this.widget.onWidgetPlaced(_placedWidgets.firstWhere((w) => w.id == updatedWidget.id));
          },
        ),
      ),
    );
  }

  void _showWidgetOptions(PlacedWidget widget, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Properties'),
              onTap: () {
                Navigator.pop(context);
                _openPropertyEditor(widget);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Widget', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteWidget(index);
              },
            ),
          ],
        ),
      ),
    );
  }



  void _deleteWidget(int index) {
    final widget = _placedWidgets[index];
    setState(() {
      _placedWidgets.removeAt(index);
      
      // Auto-select next widget if available
      if (_selectedWidget == widget) {
        if (_placedWidgets.isNotEmpty) {
          _selectedWidget = _placedWidgets.first;
          // Notify parent about the new selection
          this.widget.onWidgetSelected(_selectedWidget!);
        } else {
          _selectedWidget = null;
        }
      }
    });
    
    this.widget.onWidgetDeleted(widget);
    _saveWidgets();
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_getWidgetDisplayName(widget.type)} deleted successfully'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Storage functions
  Future<void> _saveWidgets() async {
    try {
      if (widget.selectedFile == null) {
        debugPrint('No file selected, cannot save widgets');
        return;
      }

      debugPrint('Saving ${_placedWidgets.length} widgets to file: ${widget.selectedFile!.fileName}');

      // Convert PlacedWidgets to WidgetData
      final widgetDataList = _placedWidgets.map((placedWidget) => WidgetData(
        id: placedWidget.id,
        type: placedWidget.type,
        properties: placedWidget.properties,
      )).toList();
      
      // Save widgets to the selected file
      await DartFileManager.updateFileWithWidgets(
        widget.project, 
        widget.selectedFile!, 
        widgetDataList
      );
      
      // Also save to project storage for backup
      await FileSyncService.saveWidgetsToProject(widget.project, widgetDataList);
      
      debugPrint('✅ Successfully saved ${widgetDataList.length} widgets to ${widget.selectedFile!.fileName}');
    } catch (e) {
      debugPrint('❌ Error saving widgets: $e');
    }
  }

  Future<void> _loadWidgets() async {
    try {
      if (widget.selectedFile == null) {
        debugPrint('No file selected, cannot load widgets');
        return;
      }

      debugPrint('Loading widgets from file: ${widget.selectedFile!.fileName}');

      // Load widgets from the selected file
      final widgetDataList = await _loadWidgetsFromFile(widget.selectedFile!);
      
      setState(() {
        _placedWidgets.clear();
        for (final widgetData in widgetDataList) {
          _placedWidgets.add(PlacedWidget(
            id: widgetData.id,
            type: widgetData.type,
            properties: widgetData.properties,
          ));
        }
      });
      
      debugPrint('✅ Successfully loaded ${widgetDataList.length} widgets from ${widget.selectedFile!.fileName}');
    } catch (e) {
      debugPrint('❌ Error loading widgets: $e');
    }
  }

  Future<List<WidgetData>> _loadWidgetsFromFile(DartFileBean file) async {
    try {
      // Load widgets specifically for this file
      final fileWidgets = await FileSyncService.loadWidgetsForFile(widget.project, file.fileName);
      return fileWidgets;
    } catch (e) {
      debugPrint('Error loading widgets from file: $e');
      return [];
    }
  }

  Color? _parseColor(String? colorString) {
    if (colorString == null) return null;
    if (colorString.startsWith('#')) {
      try {
        return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  String _getWidgetDisplayName(String type) {
    switch (type) {
      case 'text':
        return 'Text';
      case 'button':
        return 'Button';
      case 'edittext':
        return 'TextField';
      case 'image':
        return 'Image';
      case 'checkbox':
        return 'Checkbox';
      case 'switch':
        return 'Switch';
      case 'progressbar':
        return 'ProgressBar';
      case 'appbar':
        return 'AppBar';
      case 'center':
        return 'Center';
      case 'scaffold':
        return 'Scaffold';
      case 'materialapp':
        return 'MaterialApp';
      case 'column':
        return 'Column';
      case 'row':
        return 'Row';
      case 'stack':
        return 'Stack';
      default:
        return type;
    }
  }
}

class PlacedWidget {
  final String id;
  final String type;
  final Map<String, dynamic> properties;

  PlacedWidget({
    required this.id,
    required this.type,
    required this.properties,
  });

  PlacedWidget copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? properties,
  }) {
    return PlacedWidget(
      id: id ?? this.id,
      type: type ?? this.type,
      properties: properties ?? this.properties,
    );
  }
} 