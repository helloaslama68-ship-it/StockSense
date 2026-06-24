import 'package:hive/hive.dart';

part 'credit_transaction.g.dart';

enum TransactionType { credit, payment }

@HiveType(typeId: 7)
class CreditTransaction extends HiveObject {
  @HiveField(0) late String id;
  @HiveField(1) late String customerId;
  @HiveField(2) late int typeIndex; 
  @HiveField(3) late double amount;
  @HiveField(4) late DateTime date;
  @HiveField(5) String? notes;

  TransactionType get type => TransactionType.values[typeIndex];
  set type(TransactionType t) => typeIndex = t.index;

  CreditTransaction();

  CreditTransaction.create({
    required String id,
    required String customerId,
    required TransactionType type,
    required double amount,
    required DateTime date,
    String? notes,
  }) {
    this.id = id;
    this.customerId = customerId;
    this.typeIndex = type.index;
    this.amount = amount;
    this.date = date;
    this.notes = notes;
  }
}