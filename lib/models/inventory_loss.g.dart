

part of 'inventory_loss.dart';



class InventoryLossAdapter extends TypeAdapter<InventoryLoss> {
  @override
  final int typeId = 5;

  @override
  InventoryLoss read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InventoryLoss()
      ..id = fields[0] as String
      ..productId = fields[1] as String
      ..productName = fields[2] as String
      ..quantity = fields[3] as int
      ..valuationLoss = fields[4] as double
      ..reason = fields[5] as String
      ..loggedAt = fields[6] as DateTime
      ..unit = fields[7] as String?;
  }

  @override
  void write(BinaryWriter writer, InventoryLoss obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.productName)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.valuationLoss)
      ..writeByte(5)
      ..write(obj.reason)
      ..writeByte(6)
      ..write(obj.loggedAt)
      ..writeByte(7)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryLossAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
