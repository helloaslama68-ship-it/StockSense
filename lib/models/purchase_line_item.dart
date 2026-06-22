import 'package:hive/hive.dart';

part 'purchase_line_item.g.dart';

@HiveType(typeId: 9)
class PurchaseLineItem extends HiveObject {
  @HiveField(0)
  late String productName;

  @HiveField(1)
  String? imagePath;

  @HiveField(2)
  late double costPrice;

  @HiveField(3)
  late int quantity;

  @HiveField(4)
  late String unit;

  PurchaseLineItem({
    required this.productName,
    this.imagePath,
    required this.costPrice,
    required this.quantity,
    required this.unit,
  });

  double get total => costPrice * quantity;
}