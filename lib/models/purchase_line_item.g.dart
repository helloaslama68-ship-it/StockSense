// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_line_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PurchaseLineItemAdapter extends TypeAdapter<PurchaseLineItem> {
  @override
  final int typeId = 9;

  @override
  PurchaseLineItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PurchaseLineItem(
      productName: fields[0] as String,
      imagePath: fields[1] as String?,
      costPrice: fields[2] as double,
      quantity: fields[3] as int,
      unit: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PurchaseLineItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.productName)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.costPrice)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseLineItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
