import 'package:flutter/material.dart';
import '../models/credit_transaction.dart';
import '../models/sale.dart';
import '../providers/customer_provider.dart';
import '../models/customer.dart';

class CustomerDetailProvider extends ChangeNotifier {
  final Customer customer;
  final List<Sale> _allSales;
  final CustomerProvider _customerProvider;

  CustomerDetailProvider({
    required this.customer,
    required List<Sale> allSales,
    required CustomerProvider customerProvider,
  })  : _allSales = allSales,
        _customerProvider = customerProvider;

  double get currentBalance =>
      _customerProvider.computeBalance(customer.id, customer.amountDue);

  List<Sale> get linkedSales => _allSales
      .where((s) =>
          s.customerName?.toLowerCase() == customer.name.toLowerCase())
      .toList()
    ..sort((a, b) => b.saleDate.compareTo(a.saleDate));

  List<CreditTransaction> get transactions =>
      _customerProvider.transactionsFor(customer.id)
        ..sort((a, b) => b.date.compareTo(a.date));

  Future<void> addTransaction(CreditTransaction t) async {
    await _customerProvider.addTransaction(t);
    notifyListeners();
  }

  Future<void> updateTransaction(CreditTransaction t) async {
    await _customerProvider.updateTransaction(t);
    notifyListeners();
  }
}