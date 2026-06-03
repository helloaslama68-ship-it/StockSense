import 'package:flutter/material.dart';

class BrandSearchProvider extends ChangeNotifier {
  final TextEditingController addController = TextEditingController(); 
  final TextEditingController controller = TextEditingController();
  String _query = '';

  String get query => _query;

  void onChanged(String value) {
    _query = value.trim().toLowerCase();
    notifyListeners();
  }

  void clear() {
    controller.clear();
    _query = '';
    notifyListeners();
  }

  List<String> filter(List<String> all) {
    if (_query.isEmpty) return all;
    return all.where((b) => b.toLowerCase().contains(_query)).toList();
  }

  @override
  void dispose() {
    addController.dispose(); 
    controller.dispose();
    super.dispose();
  }
}