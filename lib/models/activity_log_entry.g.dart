

part of 'activity_log_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityLogEntryAdapter extends TypeAdapter<ActivityLogEntry> {
  @override
  final int typeId = 10;

  @override
  ActivityLogEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityLogEntry()
      ..id = fields[0] as String
      ..type = fields[1] as String
      ..action = fields[2] as String
      ..title = fields[3] as String
      ..subtitle = fields[4] as String
      ..timestamp = fields[5] as DateTime
      ..badge = fields[6] as String?;
  }

  @override
  void write(BinaryWriter writer, ActivityLogEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.action)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.subtitle)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.badge);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityLogEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}