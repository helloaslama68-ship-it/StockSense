import 'package:hive/hive.dart';
import 'purchase_line_item.dart';

part 'purchase_record.g.dart';

@HiveType(typeId: 8)
class PurchaseRecord extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String productName;

  @HiveField(2)
  late String supplierName;

  @HiveField(3)
  late int quantityPurchased;

  @HiveField(4)
  late double totalAmount;

  @HiveField(5)
  double taxPercent;

  @HiveField(6)
  late DateTime purchaseDate;

  @HiveField(7)
  String? imagePath;

  @HiveField(8)
  List<PurchaseLineItem> lineItems;

  PurchaseRecord({
    required this.id,
    required this.productName,
    required this.supplierName,
    required this.quantityPurchased,
    required this.totalAmount,
    this.taxPercent = 0,
    required this.purchaseDate,
    this.imagePath,
    List<PurchaseLineItem>? lineItems,
  }) : lineItems = lineItems ?? [];

  String get invoiceId =>
      '#PR-${id.length >= 5 ? id.substring(id.length - 5) : id.padLeft(5, '0')}';

  double get subtotal => lineItems.isNotEmpty
      ? lineItems.fold(0, (s, i) => s + i.total)
      : totalAmount / (1 + taxPercent / 100);

  double get taxAmount => subtotal * taxPercent / 100;
}