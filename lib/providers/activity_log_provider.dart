import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/activity_log_entry.dart';

/// Persisted log of destructive actions (deletes) across modules so the Home
/// "Recent Activity" feed can still show them after the underlying record
/// is gone. Live "created" events are derived directly from each module's
/// provider — this only needs to cover events that outlive their record.
class ActivityLogProvider extends ChangeNotifier {
  final Box<ActivityLogEntry> _box = Hive.box<ActivityLogEntry>('activity_log');
  static const _uuid = Uuid();

  List<ActivityLogEntry> get allEntries {
    final list = _box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  Future<void> logDeleted({
    required ActivityType type,
    required String title,
    required String subtitle,
    String? badge,
  }) async {
    final entry = ActivityLogEntry()
      ..id = _uuid.v4()
      ..type = type.value
      ..action = 'deleted'
      ..title = title
      ..subtitle = subtitle
      ..timestamp = DateTime.now()
      ..badge = badge;
    await _box.put(entry.id, entry);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _box.clear();
    notifyListeners();
  }
}