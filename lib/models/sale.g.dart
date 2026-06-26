// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaleAdapter extends TypeAdapter<Sale> {
  @override
  final int typeId = 1;

  @override
  Sale read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sale()
      ..id = fields[0] as String
      ..customerName = fields[1] as String?
      ..items = (fields[2] as List).cast<SaleItem>()
      ..subtotal = fields[3] as double
      ..taxPercent = fields[4] as double
      ..taxAmount = fields[5] as double
      ..totalAmount = fields[6] as double
      ..saleDate = fields[7] as DateTime
      ..receiptNumber = fields[8] as int
      ..status = fields[9] as String
      ..channel = fields[10] as String
      ..paymentMode = fields[11] as String
      ..creditAmount = fields[12] as double
      ..paidAmount = fields[13] as double;
  }

  @override
  void write(BinaryWriter writer, Sale obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerName)
      ..writeByte(2)
      ..write(obj.items)
      ..writeByte(3)
      ..write(obj.subtotal)
      ..writeByte(4)
      ..write(obj.taxPercent)
      ..writeByte(5)
      ..write(obj.taxAmount)
      ..writeByte(6)
      ..write(obj.totalAmount)
      ..writeByte(7)
      ..write(obj.saleDate)
      ..writeByte(8)
      ..write(obj.receiptNumber)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.channel)
      ..writeByte(11)
      ..write(obj.paymentMode)
      ..writeByte(12)
      ..write(obj.creditAmount)
      ..writeByte(13)
      ..write(obj.paidAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
