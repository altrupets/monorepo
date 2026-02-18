/// Countries supported by LATAM payment gateways
enum Country {
  costaRica('CR', 'Costa Rica'),
  panama('PA', 'Panamá'),
  colombia('CO', 'Colombia'),
  mexico('MX', 'México'),
  brazil('BR', 'Brasil'),
  argentina('AR', 'Argentina'),
  chile('CL', 'Chile'),
  peru('PE', 'Perú');

  final String code;
  final String displayName;

  const Country(this.code, this.displayName);

  @override
  String toString() => displayName;
}
