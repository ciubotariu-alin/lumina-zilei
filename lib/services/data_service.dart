import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/saint.dart';
import '../models/prayer.dart';
import '../models/bible_quote.dart';
import '../models/fasting_info.dart';
import '../models/acatist.dart';
import '../models/rugaciune_zilnica.dart';

/// URL-ul de unde se descarcă calendarul ortodox dinamic.
/// Pași pentru GitHub:
/// 1. Creează un repository public pe GitHub (ex: lumina-zilei-data)
/// 2. Adaugă fișierul calendar.json din assets/data/ în repository
/// 3. Înlocuiește YOUR_USERNAME și YOUR_REPO cu valorile tale
/// Ex: 'https://raw.githubusercontent.com/ionpopescu/lumina-zilei-data/main/calendar.json'
const String kCalendarRemoteUrl =
    'https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/calendar.json';

/// URL-ul de bază pentru OCMA-API (calendar liturgic ortodox cu date de post)
const String _kOcmaBaseUrl = 'https://ocma-api-e9870f.gitlab.io';

const String _kCalendarCacheKey = 'calendar_json_cache';
const String _kCalendarCacheTimestampKey = 'calendar_json_cache_timestamp';

/// Cât timp (în ore) este valid cache-ul local înainte de a reîncerca descărcarea.
const int _kCacheMaxAgeHours = 24;

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  // Cache în memorie
  Map<String, CalendarDay>? _calendarCache;
  List<PrayerCategory>? _prayersCache;
  List<BibleQuote>? _biblesCache;
  List<Acatist>? _acatisteCache;
  List<RugaciuneZilnica>? _rugaciuniZilniceCache;

  // Cache OCMA
  final Map<int, Map<String, dynamic>> _ocmaYearCache = {};
  Map<String, dynamic>? _ocmaI18nRo;

  Future<Map<String, CalendarDay>> loadCalendar() async {
    if (_calendarCache != null) return _calendarCache!;

    final jsonString = await _loadCalendarJson();
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final map = <String, CalendarDay>{};
    for (final entry in jsonData.entries) {
      map[entry.key] =
          CalendarDay.fromJson(entry.key, entry.value as Map<String, dynamic>);
    }

    _calendarCache = map;
    return map;
  }

  /// Încearcă să încarce calendarul în ordinea:
  /// 1. Cache local (shared_preferences) dacă nu a expirat
  /// 2. Remote URL (dacă URL-ul a fost configurat)
  /// 3. Fallback la asset-ul bunduit
  Future<String> _loadCalendarJson() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Verifică cache-ul local
    final cached = prefs.getString(_kCalendarCacheKey);
    final timestamp = prefs.getInt(_kCalendarCacheTimestampKey) ?? 0;
    final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
    final cacheExpired = cacheAge > _kCacheMaxAgeHours * 3600 * 1000;

    if (cached != null && !cacheExpired) {
      return cached;
    }

    // 2. Încearcă descărcarea remotă (dacă URL-ul este configurat)
    if (!kCalendarRemoteUrl.contains('YOUR_USERNAME')) {
      try {
        final response = await http
            .get(Uri.parse(kCalendarRemoteUrl))
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final jsonString = response.body;
          // Validare minimă: trebuie să fie un JSON valid
          json.decode(jsonString);
          // Salvează în cache local
          await prefs.setString(_kCalendarCacheKey, jsonString);
          await prefs.setInt(
            _kCalendarCacheTimestampKey,
            DateTime.now().millisecondsSinceEpoch,
          );
          return jsonString;
        }
      } catch (e, st) {
        debugPrint('[DataService] Error loading remote calendar: $e\n$st');
      }
    }

    // 3. Fallback: cache local expirat (dar prezent) sau asset bunduit
    if (cached != null) return cached;
    return rootBundle.loadString('assets/data/calendar.json');
  }

  Future<List<PrayerCategory>> loadPrayers() async {
    if (_prayersCache != null) return _prayersCache!;

    final jsonString = await rootBundle.loadString('assets/data/prayers.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final List<dynamic> categorii = jsonData['categorii'] as List;
    _prayersCache = categorii
        .map((c) => PrayerCategory.fromJson(c as Map<String, dynamic>))
        .toList();
    return _prayersCache!;
  }

  Future<List<BibleQuote>> loadBibleQuotes() async {
    if (_biblesCache != null) return _biblesCache!;

    final jsonString =
        await rootBundle.loadString('assets/data/bible_quotes.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    _biblesCache =
        jsonData.map((q) => BibleQuote.fromJson(q as Map<String, dynamic>)).toList();
    return _biblesCache!;
  }

  CalendarDay? getDayInfo(Map<String, CalendarDay> calendar, DateTime date) {
    final key =
        '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return calendar[key];
  }

  Future<List<Acatist>> loadAcatiste() async {
    if (_acatisteCache != null) return _acatisteCache!;

    try {
      final jsonString = await rootBundle.loadString('assets/data/acatiste.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> list = jsonData['acatiste'] as List? ?? [];
      _acatisteCache = list
          .map((a) => Acatist.fromJson(a as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      debugPrint('[DataService] Error loading acatiste: $e\n$st');
      _acatisteCache = [];
    }
    return _acatisteCache!;
  }

  Future<List<RugaciuneZilnica>> loadRugaciuniZilnice() async {
    if (_rugaciuniZilniceCache != null) return _rugaciuniZilniceCache!;

    try {
      final jsonString =
          await rootBundle.loadString('assets/data/rugaciuni_zilnice.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> list = jsonData['rugaciuni'] as List? ?? [];
      _rugaciuniZilniceCache = list
          .map((r) => RugaciuneZilnica.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      debugPrint('[DataService] Error loading rugaciuni zilnice: $e\n$st');
      _rugaciuniZilniceCache = [];
    }
    return _rugaciuniZilniceCache!;
  }

  /// Returns the acatist for today (by month/day), or cycles through all if no match.
  Acatist? getDailyAcatist(List<Acatist> acatiste, DateTime date) {
    if (acatiste.isEmpty) return null;

    // First try exact date match
    final match = acatiste.where(
      (a) => a.luna == date.month && a.zi == date.day,
    ).toList();
    if (match.isNotEmpty) return match.first;

    // Fallback: cycle through all acatiste by day of year
    final dayOfYear = _dayOfYear(date);
    final withText = acatiste.where((a) => a.text.isNotEmpty).toList();
    if (withText.isEmpty) return null;
    return withText[dayOfYear % withText.length];
  }

  /// Returns the prayer for today by exact month/day match only.
  /// Returns null if no prayer exists for this date.
  RugaciuneZilnica? getDailyRugaciune(
      List<RugaciuneZilnica> rugaciuni, DateTime date) {
    if (rugaciuni.isEmpty) return null;

    final match = rugaciuni
        .where((r) => r.luna == date.month && r.zi == date.day)
        .toList();
    return match.isNotEmpty ? match.first : null;
  }

  BibleQuote getDailyQuote(List<BibleQuote> quotes, DateTime date) {
    if (quotes.isEmpty) {
      return const BibleQuote(carte: '', capitol: 0, verset: 0, text: '');
    }
    final dayOfYear = _dayOfYear(date);
    return quotes[dayOfYear % quotes.length];
  }

  int _dayOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    return date.difference(startOfYear).inDays;
  }

  // ---------------------------------------------------------------------------
  // OCMA-API: informații despre post
  // ---------------------------------------------------------------------------

  /// Returnează informațiile de post pentru data dată, preluate din OCMA-API.
  /// Returnează null dacă datele nu sunt disponibile (offline, etc.)
  Future<FastingInfo?> getFastingInfo(DateTime date) async {
    try {
      final yearFuture = _loadOcmaYear(date.year);
      final i18nFuture = _loadOcmaI18nRo();
      final yearData = await yearFuture;
      final i18n = await i18nFuture;

      if (yearData == null || i18n == null) return null;

      // Structura OCMA: { "2026": { "1": { "1": { ... } } } }
      final yearMap =
          yearData[date.year.toString()] as Map<String, dynamic>?;
      final monthMap =
          yearMap?[date.month.toString()] as Map<String, dynamic>?;
      final dayData =
          monthMap?[date.day.toString()] as Map<String, dynamic>?;

      if (dayData == null) return null;

      final seasonIdx =
          dayData['fasting_season_index'] as String? ?? '';
      final laymenIdx =
          dayData['fasting_laymen_index'] as String? ?? '';

      final fastings = i18n['fastings'] as Map<String, dynamic>?;
      final seasons =
          fastings?['seasons'] as Map<String, dynamic>?;
      final levels = fastings?['levels'] as Map<String, dynamic>?;

      final season = seasonIdx.isNotEmpty
          ? (seasons?[seasonIdx] as String? ?? '')
          : '';
      final laymenLevel = laymenIdx.isNotEmpty
          ? (levels?[laymenIdx] as String? ?? '')
          : '';

      if (season.isEmpty && laymenLevel.isEmpty) return null;
      return FastingInfo(season: season, laymenLevel: laymenLevel);
    } catch (e, st) {
      debugPrint('[DataService] Error getting fasting info: $e\n$st');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _loadOcmaYear(int year) async {
    if (_ocmaYearCache.containsKey(year)) return _ocmaYearCache[year];

    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'ocma_year_$year';
      final cached = prefs.getString(cacheKey);

      if (cached != null) {
        final data = json.decode(cached) as Map<String, dynamic>;
        _ocmaYearCache[year] = data;
        return data;
      }

      final response = await http
          .get(Uri.parse('$_kOcmaBaseUrl/data/new/$year.json'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 &&
          response.body.trimLeft().startsWith('{')) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        await prefs.setString(cacheKey, response.body);
        _ocmaYearCache[year] = data;
        return data;
      }
    } catch (e, st) {
      debugPrint('[DataService] Error loading OCMA year data: $e\n$st');
    }
    return null;
  }

  Future<Map<String, dynamic>?> _loadOcmaI18nRo() async {
    if (_ocmaI18nRo != null) return _ocmaI18nRo;

    try {
      final prefs = await SharedPreferences.getInstance();
      const cacheKey = 'ocma_i18n_ro';
      final cached = prefs.getString(cacheKey);

      if (cached != null) {
        _ocmaI18nRo = json.decode(cached) as Map<String, dynamic>;
        return _ocmaI18nRo;
      }

      final response = await http
          .get(Uri.parse('$_kOcmaBaseUrl/i18n/ro.json'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 &&
          response.body.trimLeft().startsWith('{')) {
        _ocmaI18nRo = json.decode(response.body) as Map<String, dynamic>;
        await prefs.setString(cacheKey, response.body);
        return _ocmaI18nRo;
      }
    } catch (e, st) {
      debugPrint('[DataService] Error loading OCMA i18n data: $e\n$st');
    }
    return null;
  }
}
