import 'package:flutter/foundation.dart';

class Saint {
  final String name;

  const Saint({required this.name});

  factory Saint.fromString(String name) => Saint(name: name);

  @override
  String toString() => name;
}

class CalendarDay {
  final String date; // "MM-DD"
  final String sarbatoare;
  final List<String> sfinti;
  final String apostol;     // Referința Apostolului zilei (ex: "Fap. 1, 1-8")
  final String evanghelie;  // Referința Evangheliei zilei (ex: "In 1, 1-17")

  const CalendarDay({
    required this.date,
    required this.sarbatoare,
    required this.sfinti,
    this.apostol = '',
    this.evanghelie = '',
  });

  factory CalendarDay.fromJson(String date, Map<String, dynamic> json) {
    return CalendarDay(
      date: date,
      sarbatoare: json['sarbatoare'] as String? ?? '',
      sfinti: (json['sfinti'] as List? ?? []).where((item) {
        if (item is! String) {
          debugPrint('[CalendarDay] Non-string in sfinti: $item');
          return false;
        }
        return true;
      }).cast<String>().toList(),
      apostol: (json['apostolul'] ?? json['apostol']) as String? ?? '',
      evanghelie: (json['evanghelia'] ?? json['evanghelie']) as String? ?? '',
    );
  }

  bool get hasFeast => sarbatoare.isNotEmpty;

  String get displayText {
    if (sarbatoare.isNotEmpty) return sarbatoare;
    return sfinti.join(', ');
  }

  String get shortDisplayText {
    if (sarbatoare.isNotEmpty) return sarbatoare;
    if (sfinti.isEmpty) return '';
    final first = sfinti.first;
    if (first.length > 40) return '${first.substring(0, 38)}...';
    return first;
  }
}
