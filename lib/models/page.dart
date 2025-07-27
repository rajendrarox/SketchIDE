class Page {
  final String id;
  final String name;
  final String title;
  final List<String> uiComponentIds;
  final List<String> logicBlockIds;
  final Map<String, dynamic> properties;

  Page({
    required this.id,
    required this.name,
    required this.title,
    this.uiComponentIds = const [],
    this.logicBlockIds = const [],
    this.properties = const {},
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'ui_component_ids': uiComponentIds,
      'logic_block_ids': logicBlockIds,
      'properties': properties,
    };
  }

  // Create from JSON
  factory Page.fromJson(Map<String, dynamic> json) {
    return Page(
      id: json['id'],
      name: json['name'],
      title: json['title'],
      uiComponentIds: List<String>.from(json['ui_component_ids'] ?? []),
      logicBlockIds: List<String>.from(json['logic_block_ids'] ?? []),
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
    );
  }

  // Copy with updates
  Page copyWith({
    String? id,
    String? name,
    String? title,
    List<String>? uiComponentIds,
    List<String>? logicBlockIds,
    Map<String, dynamic>? properties,
  }) {
    return Page(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      uiComponentIds: uiComponentIds ?? this.uiComponentIds,
      logicBlockIds: logicBlockIds ?? this.logicBlockIds,
      properties: properties ?? this.properties,
    );
  }

  // Add UI component
  Page addUIComponent(String componentId) {
    final newComponentIds = List<String>.from(uiComponentIds);
    if (!newComponentIds.contains(componentId)) {
      newComponentIds.add(componentId);
    }
    return copyWith(uiComponentIds: newComponentIds);
  }

  // Remove UI component
  Page removeUIComponent(String componentId) {
    final newComponentIds =
        uiComponentIds.where((id) => id != componentId).toList();
    return copyWith(uiComponentIds: newComponentIds);
  }

  // Add logic block
  Page addLogicBlock(String blockId) {
    final newBlockIds = List<String>.from(logicBlockIds);
    if (!newBlockIds.contains(blockId)) {
      newBlockIds.add(blockId);
    }
    return copyWith(logicBlockIds: newBlockIds);
  }

  // Remove logic block
  Page removeLogicBlock(String blockId) {
    final newBlockIds = logicBlockIds.where((id) => id != blockId).toList();
    return copyWith(logicBlockIds: newBlockIds);
  }
}
