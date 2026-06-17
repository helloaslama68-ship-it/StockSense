import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../providers/notification_provider.dart';
import '../../models/app_notification.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_confirm_dialog.dart';
import '../../widgets/empty_state.dart';
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

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Clear All?',
      message: 'Remove all notifications?',
      deleteLabel: 'Clear All',
    );
    if (confirmed && context.mounted) {
      context.read<NotificationProvider>().clearAll();
    }
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Center(child: AppBackButton()),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notifications',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
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
          ? const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'All caught up!',
              subtitle: 'No notifications right now',
            )
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
    final config = _notifConfig(context, notif.type);

    return GestureDetector(
      onTap: () => _onTap(context, notif),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead
    ? Theme.of(context).cardColor
    : config['bg'] as Color,
          borderRadius: BorderRadius.circular(14),
          border: notif.isRead
              ? Border.all(
  color: Theme.of(context).dividerColor,
  )
              : Border.all(
                  color: (config['color'] as Color).withOpacity(0.2)),
          boxShadow: [
  BoxShadow(
    color: Colors.black.withOpacity(
      Theme.of(context).brightness == Brightness.dark
          ? 0.25
          : 0.03,
    ),
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
                             color: Theme.of(context).colorScheme.onSurface)),
                      Text(_timeAgo(notif.time),
                          style: TextStyle(
                              fontSize: 10,
                              color: notif.isRead
    ? Theme.of(context).textTheme.bodySmall?.color
    : config['color'] as Color,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 3),
                 Text(
  notif.subtitle,
  style: TextStyle(
    fontSize: 12,
    color: Theme.of(context).textTheme.bodyMedium?.color,
    height: 1.3,
  ),
),
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

Map<String, dynamic> _notifConfig(
  BuildContext context,
  NotifType type,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  switch (type) {
    case NotifType.lowStock:
      return {
        'icon': Icons.inventory_2_rounded,
        'color': AppColors.red,
        'bg': isDark
            ? AppColors.darkNotificationRed
            : AppColors.backgroundBottom,
      };

    case NotifType.expiry:
      return {
        'icon': Icons.access_time_rounded,
        'color': AppColors.goldDark,
        'bg': isDark
            ? AppColors.darkGold
            : AppColors.backgroundBottom,
      };

    case NotifType.expired:
      return {
        'icon': Icons.cancel_rounded,
        'color': AppColors.deepOrange,
        'bg': isDark
            ? AppColors.darkOrange
            : AppColors.backgroundBottom,
      };

    case NotifType.sale:
      return {
        'icon': Icons.receipt_rounded,
        'color': AppColors.blue,
        'bg': isDark
            ? AppColors.darkBlue
            : AppColors.backgroundBottom,
      };

    case NotifType.credit:
      return {
        'icon': Icons.account_balance_wallet_rounded,
        'color': AppColors.purple,
        'bg': isDark
            ? AppColors.darkPurple
            : AppColors.backgroundBottom,
      };
  }
}
}