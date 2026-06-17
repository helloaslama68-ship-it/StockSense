import 'package:hive/hive.dart';

part 'customer.g.dart';

enum CreditStatus { highDue, noDue, pending }

@HiveType(typeId: 6)
class Customer extends HiveObject {
  @HiveField(0) late String id;
  @HiveField(1) late String name;
  @HiveField(2) late String phone;
  @HiveField(3) late double amountDue;
  @HiveField(4) late int statusIndex; // CreditStatus.index

  CreditStatus get status => CreditStatus.values[statusIndex];
  set status(CreditStatus s) => statusIndex = s.index;

  Customer();

  Customer.create({
    required String id,
    required String name,
    required String phone,
    required double amountDue,
    required CreditStatus status,
  }) {
    this.id = id;
    this.name = name;
    this.phone = phone;
    this.amountDue = amountDue;
    this.statusIndex = status.index;
  }
}