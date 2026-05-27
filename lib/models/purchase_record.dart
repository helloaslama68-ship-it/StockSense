class PurchaseRecord {
  final String id;
  final String productName;
  final String supplierName;
  final int quantityPurchased;
  final double totalAmount;
  final DateTime purchaseDate;
  final String? imagePath; // ← first item image

  PurchaseRecord({
    required this.id,
    required this.productName,
    required this.supplierName,
    required this.quantityPurchased,
    required this.totalAmount,
    required this.purchaseDate,
    this.imagePath,
  });
}