import 'package:hive/hive.dart';

part 'sale_item.g.dart';

@HiveType(typeId: 3)
class SaleItem extends HiveObject {
  @HiveField(0) late String productId;
  @HiveField(1) late String productName;
  @HiveField(2) late String? sku;
  @HiveField(3) late int quantity;
  @HiveField(4) late double unitPrice;
  @HiveField(5) late double subtotal;
}