import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/inventory_loss.dart';

class LossRepository {
  final Box<InventoryLoss> _box = Hive.box<InventoryLoss>('losses');
  final _uuid = const Uuid();

  //  READ 
  List<InventoryLoss> getAll() =>
      _box.values.toList()..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));

  //  WRITE 
  Future<void> add({
    required String productId,
    required String productName,
    required int quantity,
    required double valuationLoss,
    required String reason,
    String? unit,
  }) async {
    final loss = InventoryLoss()
      ..id            = _uuid.v4()
      ..productId     = productId
      ..productName   = productName
      ..quantity      = quantity
      ..valuationLoss = valuationLoss
      ..reason        = reason
      ..unit          = unit
      ..loggedAt      = DateTime.now();
    await _box.put(loss.id, loss);
  }

  Future<void> delete(String id) async => await _box.delete(id);

  Future<void> clear() async => await _box.clear();
}