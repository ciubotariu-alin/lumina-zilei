class Prayer {
  final String id;
  final String titlu;
  final String text;

  const Prayer({
    required this.id,
    required this.titlu,
    required this.text,
  });

  factory Prayer.fromJson(Map<String, dynamic> json) {
    return Prayer(
      id: json['id'] as String? ?? '',
      titlu: json['titlu'] as String? ?? '',
      text: json['text'] as String? ?? '',
    );
  }
}

class PrayerCategory {
  final String id;
  final String nume;
  final String icon;
  final List<Prayer> rugaciuni;

  const PrayerCategory({
    required this.id,
    required this.nume,
    required this.icon,
    required this.rugaciuni,
  });

  factory PrayerCategory.fromJson(Map<String, dynamic> json) {
    final rugaciuniList = json['rugaciuni'] as List? ?? [];
    return PrayerCategory(
      id: json['id'] as String? ?? '',
      nume: json['nume'] as String? ?? '',
      icon: json['icon'] as String? ?? 'star',
      rugaciuni: rugaciuniList
          .whereType<Map<String, dynamic>>()
          .map((r) => Prayer.fromJson(r))
          .toList(),
    );
  }
}
