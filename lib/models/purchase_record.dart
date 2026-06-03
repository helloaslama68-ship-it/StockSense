import 'purchase_line_item.dart';

class PurchaseRecord {
  final String id;
  final String productName;
  final String supplierName;
  final int quantityPurchased;
  final double totalAmount;
  final double taxPercent;
  final DateTime purchaseDate;
  final String? imagePath;
  final List<PurchaseLineItem> lineItems;

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