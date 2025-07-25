import 'package:flutter/material.dart';
import '../../../domain/models/project.dart';
import '../widgets/draggable_widget_palette.dart' as palette;
import '../widgets/droppable_mobile_frame.dart';
import '../widgets/property_editor_panel.dart';
import '../widgets/dart_file_selector.dart';
import '../models/history_manager.dart';
import '../models/dart_file_bean.dart';
import '../models/widget_data.dart';
import '../services/dart_file_manager.dart';
import '../services/file_sync_service.dart' as sync;
import 'project_manager_screen.dart';
import 'dart_source_viewer_screen.dart';

class BuilderScreen extends StatefulWidget {
  final Project project;

  const BuilderScreen({
    super.key,
    required this.project,
  });

  @override
  State<BuilderScreen> createState() => _BuilderScreenState();
}

class _BuilderScreenState extends State<BuilderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  late HistoryManager _historyManager;
  int _selectedEventCategory = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  DartFileBean? _selectedFile;
  List<WidgetData> _currentFileWidgets = [];
  WidgetData? _selectedWidget;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    _historyManager = HistoryManager();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildViewTab(),
                _buildEventTab(),
                _buildComponentTab(),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
      endDrawer: _buildRightDrawer(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.project.name,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'ID: ${widget.project.id}',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.undo,
            color: _historyManager.canUndo ? Colors.black : Colors.grey.shade400,
          ),
          onPressed: _historyManager.canUndo ? _onUndo : null,
          tooltip: 'Undo',
        ),
        IconButton(
          icon: Icon(
            Icons.redo,
            color: _historyManager.canRedo ? Colors.black : Colors.grey.shade400,
          ),
          onPressed: _historyManager.canRedo ? _onRedo : null,
          tooltip: 'Redo',
        ),
        IconButton(
          icon: const Icon(Icons.save, color: Colors.black),
          onPressed: _onSave,
          tooltip: 'Save Project',
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onPressed: _showRightDrawer,
          tooltip: 'More Options',
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.grey.shade100,
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blue,
        tabs: const [
          Tab(text: 'View'),
          Tab(text: 'Event'),
          Tab(text: 'Component'),
        ],
      ),
    );
  }

  Widget _buildViewTab() {
    return Row(
      children: [
        Container(
          width: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              right: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: palette.DraggableWidgetPalette(
            onWidgetDragStarted: _onWidgetDragStarted,
            onWidgetSelected: _onWidgetSelected,
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.grey.shade50,
            child: DroppableMobileFrame(
              onWidgetPlaced: _onWidgetPlaced,
              onWidgetSelected: (PlacedWidget widget) => _onWidgetSelectedFromFrame(widget),
              onWidgetDeleted: _onWidgetDeleted,
              projectId: widget.project.id,
              project: widget.project,
              selectedFile: _selectedFile,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventTab() {
    return Row(
      children: [
        Container(
          width: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(
              right: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: _buildEventPalette(),
        ),
        Expanded(
          child: _buildEventList(),
        ),
      ],
    );
  }

  Widget _buildComponentTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.widgets, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Component Tab',
            style: TextStyle(fontSize: 24, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Custom components and reusable widgets will be here',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        PropertyEditorPanel(
          selectedWidget: _selectedWidget,
          widgets: _currentFileWidgets,
          onWidgetSelected: _onWidgetSelectedFromPropertyEditor,
          onWidgetDeleted: _onWidgetDeletedFromPropertyEditor,
          onPropertyChanged: _onPropertyChanged,
        ),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey.shade300),
            ),
          ),
                      child: Row(
              children: [
                Expanded(
                  child: DartFileSelector(
                    project: widget.project,
                    selectedFile: _selectedFile,
                    onFileSelected: _onFileSelected,
                  ),
                ),
                Container(
                width: 48,
                height: 48,
                child: IconButton(
                  onPressed: _onRunProject,
                  icon: const Icon(Icons.play_arrow),
                  tooltip: 'Run Project',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onUndo() {
    final entry = _historyManager.undo();
    if (entry != null) {
      _handleHistoryEntry(entry, isUndo: true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Undone: ${_getActionDescription(entry.actionType)}'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _onRedo() {
    final entry = _historyManager.redo();
    if (entry != null) {
      _handleHistoryEntry(entry, isUndo: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Redone: ${_getActionDescription(entry.actionType)}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _handleHistoryEntry(HistoryEntry entry, {required bool isUndo}) {
  }

  String _getActionDescription(HistoryActionType actionType) {
    switch (actionType) {
      case HistoryActionType.add:
        return 'Widget added';
      case HistoryActionType.remove:
        return 'Widget removed';
      case HistoryActionType.update:
        return 'Widget updated';
      case HistoryActionType.move:
        return 'Widget moved';
      case HistoryActionType.override:
        return 'Widget overridden';
    }
  }

  IconData _getWidgetIcon(String type) {
    switch (type) {
      case 'text':
        return Icons.text_fields;
      case 'button':
        return Icons.smart_button;
      case 'edittext':
        return Icons.edit;
      case 'image':
        return Icons.image;
      case 'checkbox':
        return Icons.check_box;
      case 'switch':
        return Icons.switch_right;
      case 'progressbar':
        return Icons.linear_scale;
      case 'appbar':
        return Icons.apps;
      case 'center':
        return Icons.center_focus_strong;
      case 'column':
        return Icons.view_column;
      case 'row':
        return Icons.view_agenda;
      case 'stack':
        return Icons.layers;
      default:
        return Icons.widgets;
    }
  }



  void _onSave() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Project saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _onMenuSelected(String value) {
    switch (value) {
      case 'settings':
        break;
      case 'export':
        break;
      case 'preview':
        break;
    }
  }

  void _onActivityChanged(String activityName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to $activityName activity'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _onAddActivity() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add activity functionality coming soon')),
    );
  }

  void _onRunProject() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Building and running project...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _onWidgetDragStarted(palette.WidgetData widget) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dragging ${widget.name}...'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _onWidgetSelected(palette.WidgetData widget) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: ${widget.name}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _onFileSelected(DartFileBean file) {
    setState(() {
      _selectedFile = file;
    });
    
    // Load widgets for the selected file
    _loadFileWidgets(file);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to ${file.displayName}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _loadFileWidgets(DartFileBean file) async {
    try {
      // Load widgets specifically for this file
      final fileWidgets = await sync.FileSyncService.loadWidgetsForFile(widget.project, file.fileName);
      
      setState(() {
        _currentFileWidgets = fileWidgets;
      });
      
    } catch (e) {
      setState(() {
        _currentFileWidgets = [];
      });
    }
  }

  void _onWidgetPlaced(PlacedWidget widget) {
    _historyManager.addWidget(widget);
    
    // Convert to WidgetData and add to current file
    final widgetData = WidgetData(
      id: widget.id,
      type: widget.type,
      properties: {
        ...widget.properties,
        'fileId': _selectedFile?.fileName ?? 'unknown',
      },
    );
    
    setState(() {
      _currentFileWidgets.add(widgetData);
    });
    
    // Update the selected file with new widgets
    if (_selectedFile != null) {
      _updateFileWithWidgets(_selectedFile!, _currentFileWidgets);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${widget.type} widget to ${_selectedFile?.displayName ?? 'current file'}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _updateFileWithWidgets(DartFileBean file, List<WidgetData> widgets) async {
    try {
      await DartFileManager.updateFileWithWidgets(widget.project, file, widgets);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onWidgetDeleted(PlacedWidget widget) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted ${widget.type} widget'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _onWidgetSelectedFromFrame(PlacedWidget widget) {
    // Find the existing WidgetData in the current file widgets list
    final existingWidgetIndex = _currentFileWidgets.indexWhere((w) => w.id == widget.id);
    
    WidgetData selectedWidgetData;
    
    if (existingWidgetIndex != -1) {
      // Widget exists in the list
      selectedWidgetData = _currentFileWidgets[existingWidgetIndex];
    } else {
      // Widget doesn't exist in the list, create it and add it
      selectedWidgetData = WidgetData(
        id: widget.id,
        type: widget.type,
        properties: widget.properties,
      );
      
      setState(() {
        _currentFileWidgets.add(selectedWidgetData);
      });
    }
    
    setState(() {
      _selectedWidget = selectedWidgetData;
    });
    

  }

  void _onWidgetSelectedFromPropertyEditor(WidgetData widget) {
    setState(() {
      _selectedWidget = widget;
    });
  }

  void _onPropertyChanged(WidgetData widget) {
    // Update the widget in the current file widgets list
    final index = _currentFileWidgets.indexWhere((w) => w.id == widget.id);
    if (index != -1) {
      setState(() {
        _currentFileWidgets[index] = widget;
      });
    }
    
    // Save changes
    _saveWidgetChanges();
  }

  void _onWidgetDeletedFromPropertyEditor(WidgetData widget) {
    setState(() {
      _currentFileWidgets.removeWhere((w) => w.id == widget.id);
      
      // Auto-select next widget if available
      if (_currentFileWidgets.isNotEmpty) {
        _selectedWidget = _currentFileWidgets.first;
      } else {
        _selectedWidget = null;
      }
    });
    
    // Save changes
    _saveWidgetChanges();
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${WidgetData.getDisplayName(widget.type)} deleted successfully'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _saveWidgetChanges() {
    if (_selectedFile != null) {
      // Save widgets to project
      sync.FileSyncService.saveWidgetsToProject(
        widget.project,
        _currentFileWidgets,
      );
    }
  }

  // Event Tab Methods
  Widget _buildEventPalette() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: const Text(
            'Events',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
        ),
        // Event Categories
        Expanded(
          child: ListView(
            children: [
              _buildEventCategory(
                icon: Icons.auto_awesome,
                title: 'Activity',
                isSelected: _selectedEventCategory == 0,
                onTap: () => _onEventCategorySelected(0),
              ),
              _buildEventCategory(
                icon: Icons.view_agenda,
                title: 'View',
                isSelected: _selectedEventCategory == 1,
                onTap: () => _onEventCategorySelected(1),
              ),
              _buildEventCategory(
                icon: Icons.widgets,
                title: 'Component',
                isSelected: _selectedEventCategory == 2,
                onTap: () => _onEventCategorySelected(2),
              ),
              _buildEventCategory(
                icon: Icons.menu,
                title: 'Drawer',
                isSelected: _selectedEventCategory == 3,
                onTap: () => _onEventCategorySelected(3),
              ),
              _buildEventCategory(
                icon: Icons.extension,
                title: 'More Block',
                isSelected: _selectedEventCategory == 4,
                onTap: () => _onEventCategorySelected(4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventCategory({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade50 : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.blue.shade300 : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? Colors.blue.shade600 : Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.blue.shade600 : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildEventList() {
    return Stack(
      children: [
        Column(
          children: [
            // Import More Block Button (only for More Block category)
            if (_selectedEventCategory == 4)
              Container(
                margin: const EdgeInsets.all(8),
                child: ElevatedButton.icon(
                  onPressed: _onImportMoreBlock,
                  icon: const Icon(Icons.file_download, size: 16),
                  label: const Text('Import More Block'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade700,
                    elevation: 0,
                  ),
                ),
              ),
            // Event List
            Expanded(
              child: _getEventListForCategory(),
            ),
          ],
        ),
        // Floating Action Button
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: _onAddEvent,
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _getEventListForCategory() {
    switch (_selectedEventCategory) {
      case 0: // Activity
        return _buildActivityEventsList();
      case 1: // View
        return _buildViewEventsList();
      case 2: // Component
        return _buildComponentEventsList();
      case 3: // Drawer
        return _buildDrawerEventsList();
      case 4: // More Block
        return _buildMoreBlockEventsList();
      default:
        return const Center(child: Text('Select a category'));
    }
  }

  Widget _buildActivityEventsList() {
    final activityEvents = [
      EventData(
        id: 'onCreate',
        name: 'onCreate',
        description: 'Called when the activity is first created',
        type: 'activity',
        icon: Icons.auto_awesome,
        isDefault: true,
      ),
      EventData(
        id: 'onStart',
        name: 'onStart',
        description: 'Called when the activity becomes visible',
        type: 'activity',
        icon: Icons.auto_awesome,
      ),
      EventData(
        id: 'onResume',
        name: 'onResume',
        description: 'Called when the activity starts interacting with the user',
        type: 'activity',
        icon: Icons.auto_awesome,
      ),
      EventData(
        id: 'onPause',
        name: 'onPause',
        description: 'Called when the activity is no longer visible',
        type: 'activity',
        icon: Icons.auto_awesome,
      ),
      EventData(
        id: 'onStop',
        name: 'onStop',
        description: 'Called when the activity is no longer visible',
        type: 'activity',
        icon: Icons.auto_awesome,
      ),
      EventData(
        id: 'onDestroy',
        name: 'onDestroy',
        description: 'Called when the activity is destroyed',
        type: 'activity',
        icon: Icons.auto_awesome,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: activityEvents.length,
      itemBuilder: (context, index) {
        return _buildEventItem(activityEvents[index]);
      },
    );
  }

  Widget _buildViewEventsList() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.view_agenda, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'View Events',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Events for UI widgets will appear here',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentEventsList() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.widgets, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Component Events',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Events for components will appear here',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerEventsList() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Drawer Events',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Events for navigation drawer will appear here',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreBlockEventsList() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.extension, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'More Block Events',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Custom blocks and functions will appear here',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(EventData event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 2,
        child: ListTile(
          leading: Icon(
            event.icon,
            color: event.isDefault ? Colors.blue.shade600 : Colors.grey.shade600,
          ),
          title: Text(
            event.name,
            style: TextStyle(
              fontWeight: event.isDefault ? FontWeight.w600 : FontWeight.normal,
              color: event.isDefault ? Colors.blue.shade600 : Colors.grey.shade800,
            ),
          ),
          subtitle: Text(
            event.description,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          trailing: event.isDefault
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Default',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : null,
          onTap: () => _onEventSelected(event),
        ),
      ),
    );
  }

  void _onEventCategorySelected(int category) {
    setState(() {
      _selectedEventCategory = category;
    });
  }

  void _onEventSelected(EventData event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected event: ${event.name}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _onAddEvent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add event functionality coming soon'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _onImportMoreBlock() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Import more block functionality coming soon'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Right Drawer Methods
  void _showRightDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  Widget _buildRightDrawer() {
    return Drawer(
      child: Container(
        color: Colors.grey.shade50,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Configuration',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
            // Drawer Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    icon: Icons.category,
                    title: 'Library Manager',
                    subtitle: 'Component settings',
                    onTap: () => _onDrawerItemSelected('library'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.view_agenda,
                    title: 'View Manager',
                    subtitle: 'Manage multiple screens',
                    onTap: () => _onDrawerItemSelected('view'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.image,
                    title: 'Image Manager',
                    subtitle: 'Import photos and icons',
                    onTap: () => _onDrawerItemSelected('image'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.music_note,
                    title: 'Sound Manager',
                    subtitle: 'Import music and sound effects',
                    onTap: () => _onDrawerItemSelected('sound'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.font_download,
                    title: 'Font Manager',
                    subtitle: 'Import different fonts',
                    onTap: () => _onDrawerItemSelected('font'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.code,
                    title: 'Java Manager',
                    subtitle: 'Manage Java files',
                    onTap: () => _onDrawerItemSelected('java'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.folder,
                    title: 'Project Manager',
                    subtitle: 'View project files and structure',
                    onTap: () => _onDrawerItemSelected('project_manager'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.folder_open,
                    title: 'Resource Editor',
                    subtitle: 'Edit resource files',
                    onTap: () => _onDrawerItemSelected('resource_editor'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.file_present,
                    title: 'Assets Manager',
                    subtitle: 'Manage project assets',
                    onTap: () => _onDrawerItemSelected('assets'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.security,
                    title: 'Permission Manager',
                    subtitle: 'Manage app permissions',
                    onTap: () => _onDrawerItemSelected('permission'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings_applications,
                    title: 'AppCompat Manager',
                    subtitle: 'Modify AppCompat layouts',
                    onTap: () => _onDrawerItemSelected('appcompat'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.android,
                    title: 'AndroidManifest Manager',
                    subtitle: 'Modify AndroidManifest',
                    onTap: () => _onDrawerItemSelected('manifest'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.extension,
                    title: 'Custom Blocks',
                    subtitle: 'See used custom blocks',
                    onTap: () => _onDrawerItemSelected('custom_blocks'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.lock,
                    title: 'Code Shrinking Manager',
                    subtitle: 'Minimize/obfuscate your app',
                    onTap: () => _onDrawerItemSelected('proguard'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.text_fields,
                    title: 'StringFog Manager',
                    subtitle: 'Encrypt strings in your app',
                    onTap: () => _onDrawerItemSelected('stringfog'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.source,
                    title: 'Show Source Code',
                    subtitle: 'View build-in Dart files',
                    onTap: () => _onDrawerItemSelected('source_code'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.code,
                    title: 'XML Command Manager',
                    subtitle: 'Modify built-in XML files',
                    onTap: () => _onDrawerItemSelected('xml_command'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.article,
                    title: 'Logcat Reader',
                    subtitle: 'Read logs from enabled projects',
                    onTap: () => _onDrawerItemSelected('logcat'),
                  ),
                  const Divider(),
                  _buildDrawerItem(
                    icon: Icons.bookmark,
                    title: 'Collection Manager',
                    subtitle: 'My saved collections',
                    onTap: () => _onDrawerItemSelected('collection'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onDrawerItemSelected(String item) {
    Navigator.of(context).pop(); // Close drawer
    
    if (item == 'project_manager') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProjectManagerScreen(project: widget.project),
        ),
      );
    } else if (item == 'source_code') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DartSourceViewerScreen(project: widget.project),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$item manager functionality coming soon'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}

class EventData {
  final String id;
  final String name;
  final String description;
  final String type;
  final IconData icon;
  final bool isDefault;

  EventData({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.icon,
    this.isDefault = false,
  });
} 