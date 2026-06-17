import 'package:flutter/material.dart';
import '../models/credit_transaction.dart';

class RecordPaymentProvider extends ChangeNotifier {
  final TransactionType type;
  final String? existingId;

  RecordPaymentProvider({
    this.type = TransactionType.payment,
    CreditTransaction? existing,
  }) : existingId = existing?.id {
    if (existing != null) {
      amountCtrl.text = existing.amount.toStringAsFixed(2);
      notesCtrl.text = existing.notes ?? '';
      _date = existing.date;
    }
  }

  final amountCtrl = TextEditingController();
  final notesCtrl  = TextEditingController();

  DateTime _date = DateTime.now();
  bool _loading = false;
  String? _amountError;

  DateTime get date => _date;
  bool get loading => _loading;
  String? get amountError => _amountError;
  bool get isEdit => existingId != null;

  void setDate(DateTime d) {
    _date = d;
    notifyListeners();
  }

  void validateAmount(double currentBalance) {
    final entered = double.tryParse(amountCtrl.text) ?? 0;
    if (type == TransactionType.payment && entered > currentBalance) {
      _amountError = 'Exceeds balance (₹${currentBalance.toStringAsFixed(2)})';
    } else {
      _amountError = null;
    }
    notifyListeners();
  }

  bool get isValid {
    final v = double.tryParse(amountCtrl.text) ?? 0;
    return v > 0 && _amountError == null;
  }

  Future<CreditTransaction?> submit(String customerId) async {
    if (!isValid) return null;
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    final t = CreditTransaction.create(
      id: existingId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      customerId: customerId,
      type: type,
      amount: double.parse(amountCtrl.text),
      date: _date,
      notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
    );
    _loading = false;
    notifyListeners();
    return t;
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }
}