import 'package:hive/hive.dart';
import 'sale_item.dart';

part 'sale.g.dart';

@HiveType(typeId: 1)
class Sale extends HiveObject {
  @HiveField(0) late String id;
  @HiveField(1) late String? customerName;
  @HiveField(2) late List<SaleItem> items;
  @HiveField(3) late double subtotal;
  @HiveField(4) late double taxPercent;
  @HiveField(5) late double taxAmount;
  @HiveField(6) late double totalAmount;
  @HiveField(7) late DateTime saleDate;
  @HiveField(8) late int receiptNumber;
  @HiveField(9) late String status; // 'completed'  'pending'
  @HiveField(10) late String channel; // 'in-store' 'online'
}