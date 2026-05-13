import 'package:hive/hive.dart';

part 'sale.g.dart';

@HiveType(typeId: 1)
class Sale extends HiveObject {
  @HiveField(0) late String id;
  @HiveField(1) late String productId;
  @HiveField(2) late String productName;
  @HiveField(3) late int quantitySold;
  @HiveField(4) late double salePrice;
  @HiveField(5) late double totalAmount;
  @HiveField(6) late DateTime saleDate;
}