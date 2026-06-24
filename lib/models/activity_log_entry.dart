import 'package:hive/hive.dart';

part 'activity_log_entry.g.dart';

/// Source of the logged activity 
enum ActivityType { product, sale, loss, credit }

extension ActivityTypeX on ActivityType {
  String get value {
    switch (this) {
      case ActivityType.product: return 'product';
      case ActivityType.sale:    return 'sale';
      case ActivityType.loss:    return 'loss';
      case ActivityType.credit:  return 'credit';
    }
  }

  static ActivityType fromValue(String v) {
    switch (v) {
      case 'product': return ActivityType.product;
      case 'sale':    return ActivityType.sale;
      case 'loss':    return ActivityType.loss;
      case 'credit':  return ActivityType.credit;
      default:        return ActivityType.product;
    }
  }
}

@HiveType(typeId: 10)
class ActivityLogEntry extends HiveObject {
  @HiveField(0) late String id;
  @HiveField(1) late String type;     
  @HiveField(2) late String action;  
  @HiveField(3) late String title;
  @HiveField(4) late String subtitle;
  @HiveField(5) late DateTime timestamp;
  @HiveField(6) String? badge;

  ActivityType get activityType => ActivityTypeX.fromValue(type);
}