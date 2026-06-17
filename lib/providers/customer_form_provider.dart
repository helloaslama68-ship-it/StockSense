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

  bool get isValid => nameCtrl.text.trim().isNotEmpty;

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