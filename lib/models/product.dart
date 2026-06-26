import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)  late String id;
  @HiveField(1)  late String name;
  @HiveField(2)  late String category;
  @HiveField(3)  late double costPrice;
  @HiveField(4)  late double sellingPrice;
  @HiveField(5)  late int quantity;
  @HiveField(6)  late int lowStockThreshold;
  @HiveField(7)  String? expiryDate;
  @HiveField(8)  String? barcode;
  @HiveField(9)  String? unit;
  @HiveField(10) late DateTime createdAt;
  @HiveField(11) String? imagePath;
  @HiveField(12) String? brand;   
  @HiveField(13) String? description;
}