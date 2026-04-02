class FastingInfo {
  final String season;
  final String laymenLevel;

  const FastingInfo({
    required this.season,
    required this.laymenLevel,
  });

  /// Returnează true dacă ziua are restricții alimentare
  bool get isFasting =>
      laymenLevel != 'Dezlegare la toate' &&
      laymenLevel != 'Dezlegare la produse lactate';

  /// Returnează true dacă este post total (negru)
  bool get isTotalFast => laymenLevel == 'Post total';

  /// Returnează true dacă este post strict (pâine și apă)
  bool get isStrictFast => laymenLevel == 'Post aspru';
}
