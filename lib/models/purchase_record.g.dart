// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PurchaseRecordAdapter extends TypeAdapter<PurchaseRecord> {
  @override
  final int typeId = 8;

  @override
  PurchaseRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PurchaseRecord(
      id: fields[0] as String,
      productName: fields[1] as String,
      supplierName: fields[2] as String,
      quantityPurchased: fields[3] as int,
      totalAmount: fields[4] as double,
      taxPercent: fields[5] as double,
      purchaseDate: fields[6] as DateTime,
      imagePath: fields[7] as String?,
      lineItems: (fields[8] as List?)?.cast<PurchaseLineItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, PurchaseRecord obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.supplierName)
      ..writeByte(3)
      ..write(obj.quantityPurchased)
      ..writeByte(4)
      ..write(obj.totalAmount)
      ..writeByte(5)
      ..write(obj.taxPercent)
      ..writeByte(6)
      ..write(obj.purchaseDate)
      ..writeByte(7)
      ..write(obj.imagePath)
      ..writeByte(8)
      ..write(obj.lineItems);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
