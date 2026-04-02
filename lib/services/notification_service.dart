import 'package:flutter/foundation.dart';

import '../models/saint.dart';

// Notifications are only supported on mobile platforms
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const int _dailyNotificationId = 1001;

  Future<void> initialize() async {
    if (kIsWeb) return;
    await _initializeMobile();
  }

  Future<void> _initializeMobile() async {
    // Mobile-only initialization handled via conditional import pattern
    // flutter_local_notifications does not support web
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) return;
  }

  Future<void> scheduleDailyNotification({
    required CalendarDay? todayInfo,
    required DateTime date,
  }) async {
    if (kIsWeb) return;
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
  }
}
