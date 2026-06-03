import 'package:hive/hive.dart';

part 'purchase.g.dart';

@HiveType(typeId: 4)
class Purchase extends HiveObject {
  @HiveField(0) late String id;
  @HiveField(1) late String productId;
  @HiveField(2) late String productName;
  @HiveField(3) late int quantityPurchased;
  @HiveField(4) late double costPrice;
  @HiveField(5) late double totalAmount;
  @HiveField(6) late DateTime purchaseDate;
  @HiveField(7) String? supplierName;
}