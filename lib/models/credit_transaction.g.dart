part of 'credit_transaction.dart';

class CreditTransactionAdapter extends TypeAdapter<CreditTransaction> {
  @override
  final int typeId = 7;

  @override
  CreditTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreditTransaction()
      ..id = fields[0] as String
      ..customerId = fields[1] as String
      ..typeIndex = fields[2] as int
      ..amount = fields[3] as double
      ..date = fields[4] as DateTime
      ..notes = fields[5] as String?;
  }

  @override
  void write(BinaryWriter writer, CreditTransaction obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.typeIndex)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreditTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}