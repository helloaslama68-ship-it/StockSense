import 'package:flutter/material.dart';
import '../models/app_notification.dart';
import '../repositories/notification_repository.dart';
import '../providers/product_provider.dart';
import '../providers/sale_provider.dart';
import '../providers/settings_provider.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repo;
  ProductProvider? _productProvider;
  SaleProvider? _saleProvider;
  SettingsProvider? _settings;

  List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider(this._repo);

  void update(ProductProvider pp, SaleProvider sp) {
    _productProvider = pp;
    _saleProvider = sp;
    rebuild();
  }

  void updateSettings(SettingsProvider settings) {
    _settings = settings;
    rebuild();
  }

  void rebuild() {
    if (_productProvider == null || _saleProvider == null) return;
    final List<AppNotification> notifs = [];

    final showLowStock = _settings?.lowStockAlerts ?? true;
    final showExpiry   = _settings?.expiryAlerts   ?? true;

    if (showLowStock) {
      for (final p in _productProvider!.lowStockProducts) {
        notifs.add(AppNotification(
          id: 'low_${p.id}',
          type: NotifType.lowStock,
          title: 'Low Stock Alert',
          subtitle: '${p.name} is running low (${p.quantity} units left)',
          time: DateTime.now().subtract(const Duration(minutes: 2)),
        ));
      }
    }

    if (showExpiry) {
      final now = DateTime.now();
      for (final p in _productProvider!.expiringProducts) {
        if (p.expiryDate == null) continue;
        final expiry = DateTime.tryParse(p.expiryDate!);
        if (expiry == null) continue;
        final daysLeft = expiry.difference(now).inDays;
        if (daysLeft >= 0) {
          notifs.add(AppNotification(
            id: 'expiry_${p.id}',
            type: NotifType.expiry,
            title: 'Expiry Warning',
            subtitle: '${p.name} expires in $daysLeft day${daysLeft == 1 ? '' : 's'}',
            time: DateTime.now().subtract(const Duration(hours: 1)),
          ));
        } else {
          notifs.add(AppNotification(
            id: 'expired_${p.id}',
            type: NotifType.expired,
            title: 'Item Expired',
            subtitle: '${p.name} expired ${(-daysLeft)} day${-daysLeft == 1 ? '' : 's'} ago',
            time: DateTime.now().subtract(const Duration(days: 1)),
          ));
        }
      }
    }

    final recentSales = _saleProvider!.allSales
        .where((s) => DateTime.now().difference(s.saleDate).inHours < 24)
        .toList();
    for (final s in recentSales.take(3)) {
      notifs.add(AppNotification(
        id: 'sale_${s.id}',
        type: NotifType.sale,
        title: 'Sale Recorded',
        subtitle: '₹${s.totalAmount.toStringAsFixed(0)} sale completed',
        time: s.saleDate,
      ));
    }

    notifs.sort((a, b) => b.time.compareTo(a.time));

    final readIds = _repo.getReadIds();
    for (final n in notifs) {
      if (readIds.contains(n.id)) n.isRead = true;
    }

    _notifications = notifs;
    notifyListeners();
  }

  void markRead(AppNotification notif) {
    notif.isRead = true;
    _repo.markRead(notif.id);
    notifyListeners();
  }

  void clearAll() {
    _repo.clearAll(_notifications.map((n) => n.id).toList());
    _notifications.clear();
    notifyListeners();
  }
}