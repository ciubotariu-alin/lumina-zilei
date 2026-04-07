class Parohie {
  final String id;
  final String denumire;
  final String hram;
  final String paroh;
  final String adresa;
  final String email;
  final String telefon;
  final String site;

  const Parohie({
    required this.id,
    required this.denumire,
    required this.hram,
    required this.paroh,
    required this.adresa,
    required this.email,
    required this.telefon,
    required this.site,
  });

  factory Parohie.fromJson(Map<String, dynamic> json) {
    return Parohie(
      id: json['id'] as String,
      denumire: json['denumire'] as String,
      hram: json['hram'] as String,
      paroh: json['paroh'] as String,
      adresa: json['adresa'] as String,
      email: json['email'] as String,
      telefon: json['telefon'] as String,
      site: json['site'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Parohie && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
