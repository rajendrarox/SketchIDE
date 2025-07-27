class UIComponent {
  final String id;
  final String type;
  final Map<String, dynamic> properties;
  final String? parentId;
  final int index;
  final List<UIComponent> children;

  UIComponent({
    required this.id,
    required this.type,
    required this.properties,
    this.parentId,
    this.index = 0,
    this.children = const [],
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'properties': properties,
      'parent_id': parentId,
      'index': index,
      'children': children.map((child) => child.toJson()).toList(),
    };
  }

  // Create from JSON
  factory UIComponent.fromJson(Map<String, dynamic> json) {
    return UIComponent(
      id: json['id'],
      type: json['type'],
      properties: Map<String, dynamic>.from(json['properties']),
      parentId: json['parent_id'],
      index: json['index'] ?? 0,
      children: (json['children'] as List?)
              ?.map((child) => UIComponent.fromJson(child))
              .toList() ??
          [],
    );
  }

  // Copy with updates
  UIComponent copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? properties,
    String? parentId,
    int? index,
    List<UIComponent>? children,
  }) {
    return UIComponent(
      id: id ?? this.id,
      type: type ?? this.type,
      properties: properties ?? this.properties,
      parentId: parentId ?? this.parentId,
      index: index ?? this.index,
      children: children ?? this.children,
    );
  }

  // Update property
  UIComponent updateProperty(String key, dynamic value) {
    final newProperties = Map<String, dynamic>.from(properties);
    newProperties[key] = value;
    return copyWith(properties: newProperties);
  }

  // Add child
  UIComponent addChild(UIComponent child) {
    final newChildren = List<UIComponent>.from(children);
    newChildren.add(child);
    return copyWith(children: newChildren);
  }

  // Remove child
  UIComponent removeChild(String childId) {
    final newChildren = children.where((child) => child.id != childId).toList();
    return copyWith(children: newChildren);
  }
}
