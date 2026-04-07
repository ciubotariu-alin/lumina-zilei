enum DurataAcatist {
  oSaptamana('O săptămână'),
  oLuna('O lună'),
  treiLuni('3 luni'),
  unAn('Un an');

  final String label;
  const DurataAcatist(this.label);
}

class AcatistRequest {
  final String parohieId;
  final String parohieDenumire;
  final String parohieEmail;
  final String intentie;
  final DurataAcatist durata;
  final String numeExpeditor;
  final String telefonExpeditor;
  final String emailExpeditor;

  const AcatistRequest({
    required this.parohieId,
    required this.parohieDenumire,
    required this.parohieEmail,
    required this.intentie,
    required this.durata,
    required this.numeExpeditor,
    required this.telefonExpeditor,
    required this.emailExpeditor,
  });
}
