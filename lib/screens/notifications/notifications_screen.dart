import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../providers/notification_provider.dart';
import '../../models/app_notification.dart';
import '../inventory/inventory_screen.dart';
import '../alerts/alerts_screen.dart';
import '../sales/sales_list_screen.dart';
import '../credit/customers_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  void _onTap(BuildContext context, AppNotification notif) {
    context.read<NotificationProvider>().markRead(notif);
    switch (notif.type) {
      case NotifType.lowStock:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen()));
        break;
      case NotifType.expiry:
      case NotifType.expired:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AlertsScreen()));
        break;
      case NotifType.sale:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesListScreen()));
        break;
      case NotifType.credit:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomersScreen()));
        break;
    }
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear All?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Remove all notifications?',
            style: TextStyle(color: AppColors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<NotificationProvider>().clearAll();
            },
            child: const Text('Clear All',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return 'Today';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final notifications = provider.notifications;
    final unread = provider.unreadCount;

    return Scaffold(
      backgroundColor: AppColors.backgroundTop,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundTop,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notifications',
                style: TextStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            if (unread > 0)
              Text('$unread unread',
                  style: TextStyle(
                      color: AppColors.goldDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
          ],
        ),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClearAll(context),
              child: Text('Clear All',
                  style: TextStyle(
                      color: AppColors.goldDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _emptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) =>
                  _notifTile(context, notifications[i]),
            ),
    );
  }

  Widget _notifTile(BuildContext context, AppNotification notif) {
    final config = _notifConfig(notif.type);

    return GestureDetector(
      onTap: () => _onTap(context, notif),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead ? AppColors.white : config['bg'] as Color,
          borderRadius: BorderRadius.circular(14),
          border: notif.isRead
              ? Border.all(color: AppColors.lightGrey.withOpacity(0.5))
              : Border.all(
                  color: (config['color'] as Color).withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (config['color'] as Color)
                    .withOpacity(notif.isRead ? 0.08 : 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                config['icon'] as IconData,
                color: config['color'] as Color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(notif.title,
                          style: TextStyle(
                              fontWeight: notif.isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.black)),
                      Text(_timeAgo(notif.time),
                          style: TextStyle(
                              fontSize: 10,
                              color: notif.isRead
                                  ? AppColors.grey
                                  : config['color'] as Color,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(notif.subtitle,
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                          height: 1.3)),
                ],
              ),
            ),
            if (!notif.isRead) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: config['color'] as Color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _notifConfig(NotifType type) {
    switch (type) {
      case NotifType.lowStock:
        return {
          'icon': Icons.inventory_2_rounded,
          'color': Colors.red,
          'bg': const Color(0xFFFFF0F0),
        };
      case NotifType.expiry:
        return {
          'icon': Icons.access_time_rounded,
          'color': AppColors.goldDark,
          'bg': const Color(0xFFFFF8E1),
        };
      case NotifType.expired:
        return {
          'icon': Icons.cancel_rounded,
          'color': Colors.deepOrange,
          'bg': const Color(0xFFFFF3E0),
        };
      case NotifType.sale:
        return {
          'icon': Icons.receipt_rounded,
          'color': Colors.blue,
          'bg': AppColors.backgroundBottom,
        };
      case NotifType.credit:
        return {
          'icon': Icons.account_balance_wallet_rounded,
          'color': AppColors.purple,
          'bg': AppColors.backgroundBottom,
        };
    }
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_none_rounded,
                size: 48, color: AppColors.grey),
          ),
          const SizedBox(height: 16),
          Text('All caught up!',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black)),
          const SizedBox(height: 6),
          Text('No notifications right now',
              style: TextStyle(fontSize: 13, color: AppColors.grey)),
        ],
      ),
    );
  }
}