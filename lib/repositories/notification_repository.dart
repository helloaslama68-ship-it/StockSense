import '../services/storage_service.dart';


// NOTIFICATION REPOSITORY
// All notification read/unread DB operations 
class NotificationRepository {
  final StorageService _storage;

  NotificationRepository(this._storage);

  // READ
  List<String> getReadIds() => _storage.getReadNotificationIds();

  // WRITE 
  void markRead(String id)              => _storage.markNotificationRead(id);
  void clearAll(List<String> ids)       => _storage.clearAllNotifications(ids);
}