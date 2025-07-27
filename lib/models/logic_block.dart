class LogicBlock {
  final String id;
  final String type;
  final Map<String, dynamic> parameters;
  final List<String> connections;
  final String? targetComponent;
  final String? targetEvent;

  LogicBlock({
    required this.id,
    required this.type,
    this.parameters = const {},
    this.connections = const [],
    this.targetComponent,
    this.targetEvent,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'parameters': parameters,
      'connections': connections,
      'target_component': targetComponent,
      'target_event': targetEvent,
    };
  }

  // Create from JSON
  factory LogicBlock.fromJson(Map<String, dynamic> json) {
    return LogicBlock(
      id: json['id'],
      type: json['type'],
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
      connections: List<String>.from(json['connections'] ?? []),
      targetComponent: json['target_component'],
      targetEvent: json['target_event'],
    );
  }

  // Copy with updates
  LogicBlock copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? parameters,
    List<String>? connections,
    String? targetComponent,
    String? targetEvent,
  }) {
    return LogicBlock(
      id: id ?? this.id,
      type: type ?? this.type,
      parameters: parameters ?? this.parameters,
      connections: connections ?? this.connections,
      targetComponent: targetComponent ?? this.targetComponent,
      targetEvent: targetEvent ?? this.targetEvent,
    );
  }

  // Update parameter
  LogicBlock updateParameter(String key, dynamic value) {
    final newParameters = Map<String, dynamic>.from(parameters);
    newParameters[key] = value;
    return copyWith(parameters: newParameters);
  }

  // Add connection
  LogicBlock addConnection(String connectionId) {
    final newConnections = List<String>.from(connections);
    if (!newConnections.contains(connectionId)) {
      newConnections.add(connectionId);
    }
    return copyWith(connections: newConnections);
  }

  // Remove connection
  LogicBlock removeConnection(String connectionId) {
    final newConnections =
        connections.where((id) => id != connectionId).toList();
    return copyWith(connections: newConnections);
  }
}
