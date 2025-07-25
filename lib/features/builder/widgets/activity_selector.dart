import 'package:flutter/material.dart';

class ActivitySelector extends StatefulWidget {
  final Function(ActivityData) onActivityChanged;
  final Function() onAddActivity;

  const ActivitySelector({
    super.key,
    required this.onActivityChanged,
    required this.onAddActivity,
  });

  @override
  State<ActivitySelector> createState() => _ActivitySelectorState();
}

class _ActivitySelectorState extends State<ActivitySelector> {
  String _selectedActivity = 'main';
  
  final List<ActivityData> _activities = [
    ActivityData(id: 'main', name: 'Main', icon: Icons.home, isDefault: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          // Activity Selector (Spinner-like)
          Expanded(
            child: InkWell(
              onTap: _showActivitySelector,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone_android,
                      size: 20,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedActivity,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Add Activity Button
          Container(
            width: 48,
            height: 48,
            child: IconButton(
              onPressed: widget.onAddActivity,
              icon: Icon(
                Icons.add,
                color: Colors.blue.shade600,
              ),
              tooltip: 'Add Activity',
            ),
          ),
        ],
      ),
    );
  }

  void _showActivitySelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Activity'),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ..._activities.map((activity) => _buildActivityItem(activity)).toList(),
              const Divider(),
              ListTile(
                leading: Icon(Icons.add, color: Colors.blue.shade600),
                title: const Text('Add New Activity'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onAddActivity();
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(ActivityData activity) {
    final isSelected = _selectedActivity == activity.id;
    return ListTile(
      leading: Icon(
        activity.icon,
        color: isSelected ? Colors.blue.shade600 : Colors.grey.shade600,
      ),
      title: Text(
        activity.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? Colors.blue.shade600 : Colors.grey.shade800,
        ),
      ),
      trailing: isSelected 
        ? Icon(Icons.check, color: Colors.blue.shade600)
        : null,
      onTap: () {
        setState(() {
          _selectedActivity = activity.id;
        });
        widget.onActivityChanged(activity);
        Navigator.pop(context);
      },
    );
  }

  void addActivity(String name) {
    final newActivity = ActivityData(
      id: name.toLowerCase().replaceAll(' ', '_'),
      name: name,
      icon: Icons.phone_android,
      isDefault: false,
    );
    setState(() {
      _activities.add(newActivity);
      _selectedActivity = newActivity.id;
    });
    widget.onActivityChanged(newActivity);
  }

  void _onActivityChanged(ActivityData activity) {
    setState(() {
      _selectedActivity = activity.id;
    });
    widget.onActivityChanged(activity);
  }
}

class ActivityData {
  final String id;
  final String name;
  final IconData icon;
  final bool isDefault;

  ActivityData({
    required this.id,
    required this.name,
    required this.icon,
    required this.isDefault,
  });
} 