// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      title: fields[0] as String,
      isDone: fields[1] as bool,
      priority: fields[2] as TaskPriority,
      category: fields[3] as TaskCategory,
      dueDate: fields[4] as DateTime?,
      notes: fields[6] as String?,
    )..createdAt = fields[5] as DateTime;
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.isDone)
      ..writeByte(2)
      ..write(obj.priority)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.dueDate)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
