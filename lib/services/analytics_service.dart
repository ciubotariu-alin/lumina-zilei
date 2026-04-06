import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  Future<void> logPrayerOpened({
    required String prayerTitle,
    required String categoryName,
  }) async {
    await _analytics.logEvent(
      name: 'prayer_opened',
      parameters: {'prayer_title': prayerTitle, 'category_name': categoryName},
    );
  }

  Future<void> logAcatistOpened(String acatistTitle) async {
    await _analytics.logEvent(
      name: 'acatist_opened',
      parameters: {'acatist_title': acatistTitle},
    );
  }

  Future<void> logBibleQuoteNavigated() async {
    await _analytics.logEvent(name: 'bible_quote_navigated');
  }

  Future<void> logCalendarDateSelected(DateTime date) async {
    await _analytics.logEvent(
      name: 'calendar_date_selected',
      parameters: {'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'},
    );
  }

  Future<void> logNotificationEnabled() async {
    await _analytics.logEvent(name: 'notification_enabled');
  }

  Future<void> logNotificationDisabled() async {
    await _analytics.logEvent(name: 'notification_disabled');
  }

  Future<void> logNotificationTimeChanged(int hour, int minute) async {
    await _analytics.logEvent(
      name: 'notification_time_changed',
      parameters: {'hour': hour, 'minute': minute},
    );
  }

  Future<void> logDonationScreenOpened() async {
    await _analytics.logEvent(name: 'donation_screen_opened');
  }

  Future<void> logDonationInitiated(String provider) async {
    await _analytics.logEvent(
      name: 'donation_initiated',
      parameters: {'provider': provider},
    );
  }

  Future<void> logAppOpenedFromNotification() async {
    await _analytics.logEvent(name: 'app_opened_from_notification');
  }
}
