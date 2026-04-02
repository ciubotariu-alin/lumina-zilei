class RugaciuneZilnica {
  final String id;
  final String titlu;
  final String text;
  final String categorie;
  final int? zi;
  final int? luna;
  final String url;

  const RugaciuneZilnica({
    required this.id,
    required this.titlu,
    required this.text,
    this.categorie = 'generale',
    this.zi,
    this.luna,
    this.url = '',
  });

  factory RugaciuneZilnica.fromJson(Map<String, dynamic> json) {
    return RugaciuneZilnica(
      id: json['id'] as String? ?? '',
      titlu: json['titlu'] as String? ?? '',
      text: json['text'] as String? ?? '',
      categorie: json['categorie'] as String? ?? 'generale',
      zi: json['zi'] as int?,
      luna: json['luna'] as int?,
      url: json['url'] as String? ?? '',
    );
  }
}
