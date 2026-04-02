class BibleQuote {
  final String carte;
  final int capitol;
  final int verset;
  final String text;

  const BibleQuote({
    required this.carte,
    required this.capitol,
    required this.verset,
    required this.text,
  });

  factory BibleQuote.fromJson(Map<String, dynamic> json) {
    return BibleQuote(
      carte: json['carte'] as String? ?? '',
      capitol: (json['capitol'] as num?)?.toInt() ?? 0,
      verset: (json['verset'] as num?)?.toInt() ?? 0,
      text: json['text'] as String? ?? '',
    );
  }

  String get reference => '$carte $capitol:$verset';
}
