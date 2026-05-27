import 'package:flutter/material.dart';
import '../models/inventory_loss.dart';
import '../repositories/loss_repository.dart';

class LossProvider extends ChangeNotifier {
  final LossRepository _repo;
  LossProvider(this._repo);

  // GETTERS 
  List<InventoryLoss> get allLosses => _repo.getAll();

  List<InventoryLoss> get recentLosses => allLosses.take(5).toList();

  int get totalLossItems =>
      allLosses.fold(0, (sum, l) => sum + l.quantity);

  double get totalLossAmount =>
      allLosses.fold(0.0, (sum, l) => sum + l.valuationLoss);

  List<InventoryLoss> byReason(String reason) =>
      allLosses.where((l) => l.reason == reason).toList();

  // ACTIONS 
  Future<void> addLoss({
    required String productId,
    required String productName,
    required int quantity,
    required double valuationLoss,
    required String reason,
    String? unit,
  }) async {
    await _repo.add(
      productId:     productId,
      productName:   productName,
      quantity:      quantity,
      valuationLoss: valuationLoss,
      reason:        reason,
      unit:          unit,
    );
    notifyListeners();
  }

  Future<void> deleteLoss(String id) async {
    await _repo.delete(id);
    notifyListeners();
  }
}