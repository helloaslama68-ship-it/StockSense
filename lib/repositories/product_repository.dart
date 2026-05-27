import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';

class ProductRepository {
  final Box<Product> _box = Hive.box<Product>('products');
  final _uuid = const Uuid();

  //  READ 
  List<Product> getAll() => _box.values.toList();

  Product? getByBarcode(String barcode) {
    try {
      return _box.values.firstWhere(
        (p) => p.barcode != null && p.barcode == barcode,
      );
    } catch (_) {
      return null;
    }
  }

  // WRITE 
  Future<void> add({
    required String name,
    required String category,
    required double costPrice,
    required double sellingPrice,
    required int quantity,
    required int lowStockThreshold,
    String? expiryDate,
    String? barcode,
    String? unit,
    String? imagePath,
    String? brand, // ← ADDED
  }) async {
    final p = Product()
      ..id = _uuid.v4()
      ..name = name
      ..category = category
      ..costPrice = costPrice
      ..sellingPrice = sellingPrice
      ..quantity = quantity
      ..lowStockThreshold = lowStockThreshold
      ..expiryDate = expiryDate
      ..barcode = barcode
      ..unit = unit
      ..imagePath = imagePath
      ..brand = brand // ← ADDED
      ..createdAt = DateTime.now();
    await _box.put(p.id, p);
  }

  Future<void> update(Product p) async => await p.save();

  Future<void> delete(String id) async => await _box.delete(id);
}