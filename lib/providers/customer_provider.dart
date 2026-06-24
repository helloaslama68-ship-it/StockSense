import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/customer.dart';
import '../models/credit_transaction.dart';

class CustomerProvider extends ChangeNotifier {
  final Box<Customer> _customers = Hive.box<Customer>('customers');
  final Box<CreditTransaction> _txns = Hive.box<CreditTransaction>('credit_transactions');
  final _uuid = const Uuid();

  String _query = '';
  String _statusFilter = 'All';

  static const List<String> statusFilters = ['All', 'highDue', 'pending', 'noDue'];

  // ── READ ──────────────────────────────────────────────────────────────────

  List<Customer> get customers => _customers.values.toList();

  List<Customer> get filtered {
    var list = customers;
    if (_statusFilter != 'All') {
      final status = CreditStatus.values.firstWhere(
        (s) => s.name == _statusFilter,
        orElse: () => CreditStatus.pending,
      );
      list = list.where((c) => c.status == status).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where(
        (c) => c.name.toLowerCase().contains(q) || c.phone.contains(q),
      ).toList();
    }
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  String get statusFilter => _statusFilter;

  double get totalDue => customers.fold(
        0.0,
        (sum, c) => sum + computeBalance(c.id, c.amountDue),
      );

  /// Actual balance = initialAmount + credits − payments
  double computeBalance(String customerId, double initialAmount) {
    final txns = transactionsFor(customerId);
    double balance = initialAmount;
    for (final t in txns) {
      if (t.type == TransactionType.credit) {
        balance += t.amount;
      } else {
        balance -= t.amount;
      }
    }
    return balance < 0 ? 0 : balance;
  }

  List<CreditTransaction> transactionsFor(String customerId) =>
      _txns.values.where((t) => t.customerId == customerId).toList();

  Customer? findByName(String name) {
    try {
      return customers.firstWhere(
        (c) => c.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  // ── FILTERS ───────────────────────────────────────────────────────────────

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void setStatusFilter(String f) {
    _statusFilter = f;
    notifyListeners();
  }

  // ── WRITE ─────────────────────────────────────────────────────────────────

  Future<void> add(Customer customer) async {
    await _customers.put(customer.id, customer);
    notifyListeners();
  }

  Future<void> update(Customer customer) async {
    await _customers.put(customer.id, customer);
    notifyListeners();
  }

  Future<void> remove(String id) async {
    await _customers.delete(id);
    final keys = _txns.values
        .where((t) => t.customerId == id)
        .map((t) => t.key)
        .toList();
    await _txns.deleteAll(keys);
    notifyListeners();
  }

  Future<void> addTransaction(CreditTransaction t) async {
    final id = t.id.isEmpty ? _uuid.v4() : t.id;
    final txn = CreditTransaction.create(
      id: id,
      customerId: t.customerId,
      type: t.type,
      amount: t.amount,
      date: t.date,
      notes: t.notes,
    );
    await _txns.put(txn.id, txn);
    notifyListeners();
  }

  Future<void> updateTransaction(CreditTransaction t) async {
    await _txns.put(t.id, t);
    notifyListeners();
  }
}