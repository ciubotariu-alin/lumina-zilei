import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../models/saint.dart';
import '../models/prayer.dart';
import '../models/bible_quote.dart';
import '../models/fasting_info.dart';
import '../models/acatist.dart';
import '../models/rugaciune_zilnica.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/data_service.dart';
import '../services/notification_service.dart';

class AppProvider extends ChangeNotifier with WidgetsBindingObserver {
  final DataService _dataService = DataService();
  final NotificationService _notificationService = NotificationService();

  DateTime _selectedDate = DateTime.now();
  Map<String, CalendarDay> _calendar = {};
  List<PrayerCategory> _allPrayers = [];
  List<BibleQuote> _bibleQuotes = [];
  BibleQuote? _dailyQuote;
  CalendarDay? _todayInfo;
  Acatist? _dailyAcatist;
  RugaciuneZilnica? _dailyRugaciune;
  bool _isLoading = true;
  String? _error;

  // Current bible index for navigation
  int _currentBibleIndex = 0;

  DateTime? _loadedDate;
  bool _refreshing = false;
  bool _disposed = false;

  DateTime get selectedDate => _selectedDate;
  Map<String, CalendarDay> get calendar => _calendar;
  List<PrayerCategory> get allPrayers => _allPrayers;
  List<BibleQuote> get bibleQuotes => _bibleQuotes;
  BibleQuote? get dailyQuote => _dailyQuote;
  CalendarDay? get todayInfo => _todayInfo;
  Acatist? get dailyAcatist => _dailyAcatist;
  RugaciuneZilnica? get dailyRugaciune => _dailyRugaciune;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentBibleIndex => _currentBibleIndex;

  BibleQuote? get currentBibleQuote {
    if (_bibleQuotes.isEmpty) return null;
    return _bibleQuotes[_currentBibleIndex % _bibleQuotes.length];
  }

  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _calendar = await _dataService.loadCalendar();
      _allPrayers = await _dataService.loadPrayers();
      _bibleQuotes = await _dataService.loadBibleQuotes();
      final acatiste = await _dataService.loadAcatiste();
      final rugaciuniZilnice = await _dataService.loadRugaciuniZilnice();

      final today = DateTime.now();
      _loadedDate = DateTime(today.year, today.month, today.day);
      _todayInfo = _dataService.getDayInfo(_calendar, today);
      _dailyQuote = _dataService.getDailyQuote(_bibleQuotes, today);
      _dailyAcatist = _dataService.getDailyAcatist(acatiste, today);
      _dailyRugaciune = _dataService.getDailyRugaciune(rugaciuniZilnice, today);

      // Set initial bible index to daily quote
      if (_bibleQuotes.isNotEmpty) {
        final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
        _currentBibleIndex = dayOfYear % _bibleQuotes.length;
      }

      // Schedule daily notification only if user has enabled it
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
      if (notificationsEnabled) {
        final hour = prefs.getInt('notification_hour') ?? 8;
        final minute = prefs.getInt('notification_minute') ?? 0;
        await _notificationService.scheduleDaily(hour, minute);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (!_refreshing && _loadedDate != null && today.isAfter(_loadedDate!)) {
      _refreshing = true;
      _refreshDailyContent().whenComplete(() => _refreshing = false);
    }
  }

  Future<void> _refreshDailyContent() async {
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    // Optimistically advance _loadedDate to prevent concurrent calls from
    // didChangeAppLifecycleState. Reset to yesterday on failure to allow retry.
    _loadedDate = todayNormalized;
    _todayInfo = _dataService.getDayInfo(_calendar, today);
    _dailyQuote = _dataService.getDailyQuote(_bibleQuotes, today);
    try {
      final acatiste = await _dataService.loadAcatiste();
      final rugaciuniZilnice = await _dataService.loadRugaciuniZilnice();
      if (_disposed) return;
      _dailyAcatist = _dataService.getDailyAcatist(acatiste, today);
      _dailyRugaciune = _dataService.getDailyRugaciune(rugaciuniZilnice, today);
      final prefs = await SharedPreferences.getInstance();
      if (_disposed) return;
      final notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
      if (notificationsEnabled) {
        final hour = prefs.getInt('notification_hour') ?? 8;
        final minute = prefs.getInt('notification_minute') ?? 0;
        await _notificationService.scheduleDaily(hour, minute);
      }
    } catch (e) {
      debugPrint('[AppProvider] _refreshDailyContent error: $e');
      // Reset to yesterday so the next app resume will retry the failed load.
      _loadedDate = todayNormalized.subtract(const Duration(days: 1));
    }
    if (!_disposed) notifyListeners();
  }

  CalendarDay? getDayInfo(DateTime date) {
    return _dataService.getDayInfo(_calendar, date);
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void nextBibleQuote() {
    if (_bibleQuotes.isNotEmpty) {
      _currentBibleIndex = (_currentBibleIndex + 1) % _bibleQuotes.length;
      notifyListeners();
    }
  }

  void previousBibleQuote() {
    if (_bibleQuotes.isNotEmpty) {
      _currentBibleIndex =
          (_currentBibleIndex - 1 + _bibleQuotes.length) % _bibleQuotes.length;
      notifyListeners();
    }
  }

  List<String> getTodaySaintsNames() {
    final info = _todayInfo;
    if (info == null) return [];
    if (info.sarbatoare.isNotEmpty) return [info.sarbatoare];
    return info.sfinti;
  }

  /// Returneaz\u0103 informa\u021biile de post pentru data dat\u0103 din OCMA-API.
  Future<FastingInfo?> getFastingInfo(DateTime date) =>
      _dataService.getFastingInfo(date);
}
