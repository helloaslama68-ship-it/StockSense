

part of 'sale_item.dart';



class SaleItemAdapter extends TypeAdapter<SaleItem> {
  @override
  final int typeId = 3;

  @override
  SaleItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleItem()
      ..productId = fields[0] as String
      ..productName = fields[1] as String
      ..sku = fields[2] as String?
      ..quantity = fields[3] as int
      ..unitPrice = fields[4] as double
      ..subtotal = fields[5] as double;
  }

  @override
  void write(BinaryWriter writer, SaleItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.sku)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.unitPrice)
      ..writeByte(5)
      ..write(obj.subtotal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
