// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 0;

  @override
  Project read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Project(
      id: fields[0] as String,
      name: fields[1] as String,
      appName: fields[2] as String,
      packageName: fields[3] as String,
      iconPath: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      modifiedAt: fields[6] as DateTime,
      version: fields[7] as String,
      description: fields[8] as String,
      projectPath: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.appName)
      ..writeByte(3)
      ..write(obj.packageName)
      ..writeByte(4)
      ..write(obj.iconPath)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.modifiedAt)
      ..writeByte(7)
      ..write(obj.version)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.projectPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
