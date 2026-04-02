import 'package:flutter/foundation.dart';

import '../models/saint.dart';
import '../models/prayer.dart';
import '../models/bible_quote.dart';
import '../models/fasting_info.dart';
import '../services/data_service.dart';
import '../services/notification_service.dart';

class AppProvider extends ChangeNotifier {
  final DataService _dataService = DataService();
  final NotificationService _notificationService = NotificationService();

  DateTime _selectedDate = DateTime.now();
  Map<String, CalendarDay> _calendar = {};
  List<PrayerCategory> _allPrayers = [];
  List<BibleQuote> _bibleQuotes = [];
  BibleQuote? _dailyQuote;
  CalendarDay? _todayInfo;
  bool _isLoading = true;
  String? _error;

  // Current bible index for navigation
  int _currentBibleIndex = 0;

  DateTime get selectedDate => _selectedDate;
  Map<String, CalendarDay> get calendar => _calendar;
  List<PrayerCategory> get allPrayers => _allPrayers;
  List<BibleQuote> get bibleQuotes => _bibleQuotes;
  BibleQuote? get dailyQuote => _dailyQuote;
  CalendarDay? get todayInfo => _todayInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentBibleIndex => _currentBibleIndex;

  BibleQuote? get currentBibleQuote {
    if (_bibleQuotes.isEmpty) return null;
    return _bibleQuotes[_currentBibleIndex % _bibleQuotes.length];
  }

  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _calendar = await _dataService.loadCalendar();
      _allPrayers = await _dataService.loadPrayers();
      _bibleQuotes = await _dataService.loadBibleQuotes();

      final today = DateTime.now();
      _todayInfo = _dataService.getDayInfo(_calendar, today);
      _dailyQuote = _dataService.getDailyQuote(_bibleQuotes, today);

      // Set initial bible index to daily quote
      if (_bibleQuotes.isNotEmpty) {
        final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
        _currentBibleIndex = dayOfYear % _bibleQuotes.length;
      }

      // Schedule daily notification
      await _notificationService.scheduleDailyNotification(
        todayInfo: _todayInfo,
        date: today,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    if (_todayInfo == null) return [];
    if (_todayInfo!.sarbatoare.isNotEmpty) return [_todayInfo!.sarbatoare];
    return _todayInfo!.sfinti;
  }

  /// Returneaz\u0103 informa\u021biile de post pentru data dat\u0103 din OCMA-API.
  Future<FastingInfo?> getFastingInfo(DateTime date) =>
      _dataService.getFastingInfo(date);
}
