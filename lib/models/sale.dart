import 'package:hive/hive.dart';
import 'enums.dart';
import 'sale_item.dart';

part 'sale.g.dart';

@HiveType(typeId: 1)
class Sale extends HiveObject {
  @HiveField(0) late String id;
  @HiveField(1) late String? customerName;
  @HiveField(2) late List<SaleItem> items;
  @HiveField(3) late double subtotal;
  @HiveField(4) late double taxPercent;
  @HiveField(5) late double taxAmount;
  @HiveField(6) late double totalAmount;
  @HiveField(7) late DateTime saleDate;
  @HiveField(8) late int receiptNumber;
  @HiveField(9) late String status; 
  @HiveField(10) late String channel; 
  @HiveField(11) late String paymentMode; 
  @HiveField(12) late double creditAmount;
  @HiveField(13) late double paidAmount;

  //returns the sale channel as enum
  SaleChannel get saleChannel => SaleChannelX.fromValue(channel);
  set saleChannel(SaleChannel c) => channel = c.value;

  SaleStatus get saleStatus => SaleStatusX.fromValue(status);
  set saleStatus(SaleStatus s) => status = s.value;

  SalePaymentMode get paymentModeEnum =>
      SalePaymentMode.values.firstWhere((e) => e.name == paymentMode,
          orElse: () => SalePaymentMode.paid);
  set paymentModeEnum(SalePaymentMode m) => paymentMode = m.name;
}