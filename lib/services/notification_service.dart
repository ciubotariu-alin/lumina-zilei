import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/saint.dart';
import 'analytics_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const int _dailyNotificationId = 1001;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Guards against double-firing analytics on Android cold-start:
  // onDidReceiveNotificationResponse fires during initialize() for cold-starts,
  // and getNotificationAppLaunchDetails() also returns true — we want exactly one log.
  bool _coldStartChecked = false;

  Future<void> initialize() async {
    if (kIsWeb) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      ),
      onDidReceiveNotificationResponse: (_) {
        // On Android, this fires for both foreground taps AND cold-start taps.
        // Cold-start is handled via getNotificationAppLaunchDetails() below.
        // We suppress this callback during initialization to avoid double-logging.
        if (_coldStartChecked) {
          AnalyticsService().logAppOpenedFromNotification();
        }
      },
    );

    // Cold start: app was closed and user tapped the notification.
    // This is the authoritative source for cold-start detection on all platforms.
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      AnalyticsService().logAppOpenedFromNotification();
    }
    _coldStartChecked = true;
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) return;
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleDailyNotification({
    required CalendarDay? todayInfo,
    required DateTime date,
  }) async {
    if (kIsWeb) return;

    String body = 'Deschide aplicația pentru rugăciunile zilei';
    if (todayInfo != null) {
      if (todayInfo.sarbatoare.isNotEmpty) {
        body = todayInfo.sarbatoare;
      } else if (todayInfo.sfinti.isNotEmpty) {
        body = todayInfo.sfinti.first;
      }
    }

    const androidDetails = AndroidNotificationDetails(
      'lumina_zilei_daily',
      'Lumina Zilei',
      channelDescription: 'Notificări zilnice cu sfinții și rugăciunile zilei',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const darwinDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _plugin.cancel(id: _dailyNotificationId);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 8, 0, 0);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await _plugin.zonedSchedule(
        id: _dailyNotificationId,
        title: 'Lumina Zilei',
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e, st) {
      debugPrint('[NotificationService] zonedSchedule error: $e\n$st');
    }
  }

  Future<void> scheduleDaily(int hour, int minute) async {
    if (kIsWeb) return;

    const androidDetails = AndroidNotificationDetails(
      'lumina_zilei_daily',
      'Lumina Zilei',
      channelDescription: 'Notificări zilnice cu sfinții și rugăciunile zilei',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const darwinDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _plugin.cancel(id: _dailyNotificationId);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute, 0);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await _plugin.zonedSchedule(
        id: _dailyNotificationId,
        title: 'Lumina Zilei',
        body: 'Deschide aplicația pentru rugăciunile zilei',
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e, st) {
      debugPrint('[NotificationService] scheduleDaily error: $e\n$st');
    }
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }
}
