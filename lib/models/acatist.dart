class Acatist {
  final String id;
  final String titlu;
  final String text;
  final int? zi;
  final int? luna;
  final String url;

  const Acatist({
    required this.id,
    required this.titlu,
    required this.text,
    this.zi,
    this.luna,
    this.url = '',
  });

  factory Acatist.fromJson(Map<String, dynamic> json) {
    return Acatist(
      id: json['id'] as String? ?? '',
      titlu: json['titlu'] as String? ?? '',
      text: json['text'] as String? ?? '',
      zi: json['zi'] as int?,
      luna: json['luna'] as int?,
      url: json['url'] as String? ?? '',
    );
  }
}
