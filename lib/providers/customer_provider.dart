import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/customer.dart';
import '../models/credit_transaction.dart';

class CustomerProvider extends ChangeNotifier {
  Box<Customer> get _customerBox => Hive.box<Customer>('customers');
  Box<CreditTransaction> get _txnBox =>
      Hive.box<CreditTransaction>('credit_transactions');

  String _query = '';

  List<Customer> get customers => _customerBox.values.toList();

  double get totalDue =>
      customers.fold(0, (s, c) => s + computeBalance(c.id, c.amountDue));

  double computeBalance(String customerId, double initialDue) {
    final txns = _txnBox.values.where((t) => t.customerId == customerId);
    double balance = initialDue;
    for (final t in txns) {
      if (t.type == TransactionType.payment) {
        balance -= t.amount;
      } else {
        balance += t.amount;
      }
    }
    return balance < 0 ? 0 : balance;
  }

  List<Customer> get filtered {
    if (_query.isEmpty) return customers;
    final q = _query.toLowerCase();
    return customers
        .where((c) => c.name.toLowerCase().contains(q) || c.phone.contains(q))
        .toList();
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  Future<void> add(Customer c) async {
    await _customerBox.put(c.id, c);
    notifyListeners();
  }

  Future<void> remove(String id) async {
    await _customerBox.delete(id);
    final keys = _txnBox.values
        .where((t) => t.customerId == id)
        .map((t) => t.key)
        .toList();
    await _txnBox.deleteAll(keys);
    notifyListeners();
  }

  Future<void> update(Customer updated) async {
    await _customerBox.put(updated.id, updated);
    notifyListeners();
  }

  Future<void> addTransaction(CreditTransaction t) async {
    await _txnBox.put(t.id, t);
    notifyListeners();
  }

  Future<void> updateTransaction(CreditTransaction t) async {
    await _txnBox.put(t.id, t);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await _txnBox.delete(id);
    notifyListeners();
  }

  List<CreditTransaction> transactionsFor(String customerId) =>
      _txnBox.values.where((t) => t.customerId == customerId).toList();
}