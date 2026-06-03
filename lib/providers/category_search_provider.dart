import 'package:flutter/material.dart';

class CategorySearchProvider extends ChangeNotifier {
  final TextEditingController addController = TextEditingController();
  final TextEditingController controller = TextEditingController();
  String query = '';

  static const _iconMap = {
    'beverages': Icons.local_drink_outlined,
    'dairy': Icons.egg_outlined,
    'snacks': Icons.cookie_outlined,
    'spices': Icons.grass_outlined,
    'bakery': Icons.breakfast_dining_outlined,
    'frozen': Icons.ac_unit_outlined,
    'personal': Icons.person_outline,
    'cleaning': Icons.cleaning_services_outlined,
    'baby': Icons.child_care_outlined,
    'health': Icons.favorite_border_rounded,
  };

  List<String> filter(List<String> all) {
    if (query.isEmpty) return all;
    return all
        .where((c) => c.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  IconData iconFor(String category) {
    final key = category.toLowerCase();
    for (final entry in _iconMap.entries) {
      if (key.contains(entry.key)) return entry.value;
    }
    return Icons.label_outline_rounded;
  }

  void onChanged(String val) {
    query = val;
    notifyListeners();
  }

  void clear() {
    controller.clear();
    query = '';
    notifyListeners();
  }

  @override
  void dispose() {
    addController.dispose();
    controller.dispose();
    super.dispose();
  }
}