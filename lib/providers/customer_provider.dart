import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/customer.dart';
import '../models/credit_transaction.dart';

class CustomerProvider extends ChangeNotifier {
  Box<Customer> get _customerBox => Hive.box<Customer>('customers');
  Box<CreditTransaction> get _txnBox =>
      Hive.box<CreditTransaction>('credit_transactions');

  String _query = '';
  String _statusFilter = 'All';

  static const List<String> statusFilters = ['All', 'highDue', 'pending', 'noDue'];

  String get statusFilter => _statusFilter;

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
    var list = customers;
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((c) => c.name.toLowerCase().contains(q) || c.phone.contains(q)).toList();
    }
    if (_statusFilter != 'All') {
      list = list.where((c) => _statusKey(c.status) == _statusFilter).toList();
    }
    list.sort((a, b) {
      final ai = _statusOrder(a.status);
      final bi = _statusOrder(b.status);
      if (ai != bi) return ai.compareTo(bi);
      return computeBalance(b.id, b.amountDue).compareTo(computeBalance(a.id, a.amountDue));
    });
    return list;
  }

  String _statusKey(CreditStatus s) {
    switch (s) {
      case CreditStatus.highDue: return 'highDue';
      case CreditStatus.pending: return 'pending';
      case CreditStatus.noDue:   return 'noDue';
    }
  }

  int _statusOrder(CreditStatus s) {
    switch (s) {
      case CreditStatus.highDue: return 0;
      case CreditStatus.pending: return 1;
      case CreditStatus.noDue:   return 2;
    }
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void setStatusFilter(String f) {
    _statusFilter = f;
    notifyListeners();
  }

  Customer? findByName(String name) {
    final n = name.trim().toLowerCase();
    try {
      return customers.firstWhere((c) => c.name.trim().toLowerCase() == n);
    } catch (_) {
      return null;
    }
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