enum NotifType { lowStock, expiry, expired, sale, credit }

class AppNotification {
  final String id;
  final NotifType type;
  final String title;
  final String subtitle;
  final DateTime time;
  bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.time,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.index,
    'title': title,
    'subtitle': subtitle,
    'time': time.toIso8601String(),
    'isRead': isRead,
  };

  factory AppNotification.fromMap(Map<String, dynamic> m) => AppNotification(
    id: m['id'],
    type: NotifType.values[m['type']],
    title: m['title'],
    subtitle: m['subtitle'],
    time: DateTime.parse(m['time']),
    isRead: m['isRead'] ?? false,
  );
}