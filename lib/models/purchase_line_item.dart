class PurchaseLineItem {
  String productName;
  String? imagePath;
  double costPrice;
  int quantity;
  String unit;

  PurchaseLineItem({
    required this.productName,
    this.imagePath,
    required this.costPrice,
    required this.quantity,
    required this.unit,
  });

  double get total => costPrice * quantity;
}