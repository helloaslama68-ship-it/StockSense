import 'package:hive/hive.dart';
part 'inventory_loss.g.dart';



enum LossReason { damaged, spoiled, expired, other }

@HiveType(typeId: 5)
class InventoryLoss extends HiveObject {
  @HiveField(0) late String id;
  @HiveField(1) late String productId;
  @HiveField(2) late String productName;
  @HiveField(3) late int quantity;
  @HiveField(4) late double valuationLoss; // costPrice * quantity
  @HiveField(5) late String reason;        // 'damaged'  'spoiled' 'expired'  'other'
  @HiveField(6) late DateTime loggedAt;
  @HiveField(7) String? unit;
}