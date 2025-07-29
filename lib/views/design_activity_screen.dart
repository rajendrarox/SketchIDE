import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/design_viewmodel.dart';
import '../widgets/widget_palette.dart';
import '../widgets/flutter_device_frame.dart';
import '../widgets/property_panel.dart';
import '../widgets/design_drawer.dart';
import '../controllers/drag_controller.dart';
import '../models/flutter_widget_bean.dart';

/// Design Activity Screen - Main visual editor screen
class DesignActivityScreen extends StatefulWidget {
  final String projectId;

  const DesignActivityScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<DesignActivityScreen> createState() => _DesignActivityScreenState();
}

class _DesignActivityScreenState extends State<DesignActivityScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  late DesignViewModel _viewModel;
  late DragController _sharedDragController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();
    _viewModel = DesignViewModel();
    _sharedDragController = DragController();

    // Load project
    _viewModel.loadProject(widget.projectId);

    // Setup shared drag controller
    _setupSharedDragController();
  }

  void _setupSharedDragController() {
    _sharedDragController.setCallbacks(
      onWidgetMoved: (widget) => _viewModel.moveWidget(widget),
      onWidgetDeleted: (widget) => _viewModel.deleteSelectedWidget(),
      onWidgetAdded: (widget, {Size? containerSize}) =>
          _viewModel.addWidget(widget, containerSize: containerSize),
      onDragStateChanged: (isDragging) {
        // Handle global drag state changes
      },
      onDeleteZoneActive: (isActive) {
        // Handle delete zone activation
      },
      onViewPaneActive: (isActive) {
        // Handle view pane activation
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _sharedDragController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<DesignViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: _buildAppBar(viewModel),
            body: _buildBody(viewModel),
            endDrawer: _buildRightDrawer(),
            bottomNavigationBar: _buildBottomBar(viewModel),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(DesignViewModel viewModel) {
    return AppBar(
      title: Text(viewModel.projectName ?? 'Design'),
      actions: [
        IconButton(
          icon: const Icon(Icons.undo),
          onPressed: viewModel.canUndo ? viewModel.undo : null,
        ),
        IconButton(
          icon: const Icon(Icons.redo),
          onPressed: viewModel.canRedo ? viewModel.redo : null,
        ),
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: viewModel.saveProject,
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          viewModel.setTab(DesignTab.values[index]);
        },
        tabs: const [
          Tab(text: 'View'),
          Tab(text: 'Event'),
          Tab(text: 'Component'),
        ],
      ),
    );
  }

  Widget _buildBody(DesignViewModel viewModel) {
    // SKETCHWARE PRO STYLE: Fixed mobile frame position - no up/down movement
    const double propertyPanelHeight = 170.0;
    final bool isPropertyPanelVisible = viewModel.selectedWidget != null;

    return Stack(
      children: [
        // Main content area - SKETCHWARE PRO STYLE: Fixed position at top
        Positioned.fill(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              _tabController.animateTo(index);
              viewModel.setTab(DesignTab.values[index]);
            },
            children: [
              _buildViewTab(viewModel),
              _buildEventTab(),
              _buildComponentTab(),
            ],
          ),
        ),
        // Property panel - SKETCHWARE PRO STYLE: Slides up from bottom (overlays mobile frame)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedSwitcher(
            duration: const Duration(
                milliseconds: 300), // SKETCHWARE PRO: 300ms AutoTransition
            switchInCurve:
                Curves.decelerate, // SKETCHWARE PRO: DecelerateInterpolator
            switchOutCurve:
                Curves.easeIn, // SKETCHWARE PRO: Smooth hide animation
            transitionBuilder: (Widget child, Animation<double> animation) {
              // SKETCHWARE PRO STYLE: Slide up from bottom animation
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 1.0), // Start below screen
                  end: const Offset(0.0, 0.0), // End at normal position
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves
                      .decelerate, // SKETCHWARE PRO: DecelerateInterpolator
                )),
                child: child,
              );
            },
            child: isPropertyPanelVisible
                ? _buildPropertyPanel(viewModel)
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _buildViewTab(DesignViewModel viewModel) {
    return Row(
      children: [
        // Left palette - fixed 120dp width
        Container(
          width: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: WidgetPalette(
            onWidgetSelected: (widget) {
              viewModel.addWidget(widget);
            },
            onWidgetDragged: (widget, position) {
              // Start drag from palette using shared drag controller
              _sharedDragController.startDragFromPalette(widget, position);
            },
          ),
        ),
        // Center mobile frame
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: FlutterDeviceFrame(
              widgets: viewModel.widgets,
              selectedWidget: viewModel.selectedWidget,
              onWidgetSelected: (widget) => viewModel.selectWidget(widget),
              onWidgetMoved: (widget) => viewModel.moveWidget(widget),
              onWidgetAdded: (widget, {Size? containerSize}) =>
                  viewModel.addWidget(widget, containerSize: containerSize),
              onBackgroundTapped: () => viewModel
                  .clearSelection(), // SKETCHWARE PRO: Clear selection on background tap
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventTab() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.code, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Event Editor',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Logic blocks and event handling',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentTab() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.widgets, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Component Manager',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Manage custom components and libraries',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyPanel(DesignViewModel viewModel) {
    return AnimatedContainer(
      duration: const Duration(
          milliseconds: 300), // SKETCHWARE PRO: 300ms like AutoTransition
      curve: Curves
          .decelerate, // SKETCHWARE PRO: DecelerateInterpolator equivalent
      height: 170,
      transform: Matrix4.identity(), // SKETCHWARE PRO: Ensure smooth transform
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        // SKETCHWARE PRO STYLE: Add subtle shadow like property panels
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: PropertyPanel(
        selectedWidget: viewModel.selectedWidget ??
            FlutterWidgetBean(
              id: '',
              type: 'Text',
              properties: {},
              children: [],
              position: PositionBean(x: 0, y: 0, width: 100, height: 50),
              events: {},
              layout: LayoutBean(
                marginLeft: 0,
                marginTop: 0,
                marginRight: 0,
                marginBottom: 0,
                width: 100,
                height: 50,
                paddingLeft: 0,
                paddingTop: 0,
                paddingRight: 0,
                paddingBottom: 0,
                backgroundColor: 0xFFFFFFFF,
                layoutGravity: 0,
              ),
            ),
        allWidgets: viewModel.widgets,
        onPropertyChanged: (widget) {
          viewModel.updateWidget(widget);
        },
        onWidgetDeleted: (widget) {
          viewModel.deleteSelectedWidget();
        },
        onWidgetSelected: (widget) {
          viewModel.selectWidget(widget);
        },
      ),
    );
  }

  Widget _buildRightDrawer() {
    return DesignDrawer(
      onItemSelected: (item) {
        // Handle drawer item selection
        Scaffold.of(context).closeEndDrawer();
        // TODO: Navigate to appropriate screen
      },
    );
  }

  Widget _buildBottomBar(DesignViewModel viewModel) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // File selector
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              child: Material(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    // TODO: Show file selector
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.screen_rotation,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'main',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Run button
          Container(
            margin: const EdgeInsets.only(right: 4),
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Build and run project
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Run'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          // Options button
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () {
                // TODO: Show options menu
              },
              icon: const Icon(Icons.tune),
              tooltip: 'Options',
            ),
          ),
        ],
      ),
    );
  }
}
