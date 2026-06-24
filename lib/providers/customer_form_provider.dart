import 'package:flutter/material.dart';
import '../models/customer.dart';

class CustomerFormProvider extends ChangeNotifier {
  final nameCtrl    = TextEditingController();
  final phoneCtrl   = TextEditingController();
  final addressCtrl = TextEditingController();
  final amountCtrl  = TextEditingController();
  final notesCtrl   = TextEditingController();

  DateTime _creditDate = DateTime.now();
  DateTime get creditDate => _creditDate;

  bool _loading = false;
  bool get loading => _loading;

  final formKey = GlobalKey<FormState>();

  CustomerFormProvider({Customer? existing}) {
    if (existing != null) {
      nameCtrl.text    = existing.name;
      phoneCtrl.text   = existing.phone.replaceFirst('+91 ', '');
      amountCtrl.text  = existing.amountDue == 0 ? '' : existing.amountDue.toString();
    }
  }

  void setCreditDate(DateTime d) {
    _creditDate = d;
    notifyListeners();
  }

  String? validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Customer name is required';
    if (v.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required';
    final digits = v.trim().replaceAll(RegExp(r'\s'), '');
    if (!RegExp(r'^[0-9]{10}$').hasMatch(digits)) return 'Enter a valid 10-digit number';
    return null;
  }

  String? validateAmount(String? v) {
    if (v == null || v.trim().isEmpty) return 'Initial credit amount is required';
    final parsed = double.tryParse(v.trim());
    if (parsed == null) return 'Enter a valid number';
    if (parsed < 0) return 'Amount cannot be negative';
    if (parsed > 10000000) return 'Amount seems too large. Please verify';
    return null;
  }

  bool get isValid => formKey.currentState?.validate() ?? false;

  Future<bool> submit() async {
    if (!isValid) return false;
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _loading = false;
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    amountCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }
}