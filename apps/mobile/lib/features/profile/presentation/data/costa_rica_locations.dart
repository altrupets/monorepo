const String costaRicaCountry = 'Costa Rica';

const List<String> costaRicaProvinces = [
  'San Jose',
  'Alajuela',
  'Cartago',
  'Heredia',
  'Guanacaste',
  'Puntarenas',
  'Limon',
];

const Map<String, List<String>> costaRicaCantonsByProvince = {
  'San Jose': ['San Jose', 'Escazu', 'Desamparados', 'Goicoechea'],
  'Alajuela': ['Alajuela', 'San Ramon', 'Grecia', 'San Carlos'],
  'Cartago': ['Cartago', 'Paraiso', 'La Union', 'Jimenez'],
  'Heredia': ['Heredia', 'Barva', 'Santo Domingo', 'San Rafael'],
  'Guanacaste': ['Liberia', 'Nicoya', 'Santa Cruz', 'Carrillo'],
  'Puntarenas': ['Puntarenas', 'Esparza', 'Buenos Aires', 'Osa'],
  'Limon': ['Limon', 'Pococi', 'Siquirres', 'Talamanca'],
};

const Map<String, List<String>> costaRicaDistrictsByCanton = {
  'San Jose|San Jose': ['Carmen', 'Merced', 'Hospital', 'Catedral'],
  'San Jose|Escazu': ['Escazu', 'San Antonio', 'San Rafael'],
  'San Jose|Desamparados': ['Desamparados', 'San Miguel', 'San Juan de Dios'],
  'San Jose|Goicoechea': ['Guadalupe', 'San Francisco', 'Calle Blancos'],
  'Alajuela|Alajuela': ['Alajuela', 'San Jose', 'Carrizal'],
  'Alajuela|San Ramon': ['San Ramon', 'Santiago', 'San Juan'],
  'Alajuela|Grecia': ['Grecia', 'San Isidro', 'San Jose'],
  'Alajuela|San Carlos': ['Quesada', 'Florencia', 'Buenavista'],
  'Cartago|Cartago': ['Oriental', 'Occidental', 'Carmen'],
  'Cartago|Paraiso': ['Paraiso', 'Santiago', 'Orosi'],
  'Cartago|La Union': ['Tres Rios', 'San Diego', 'San Juan'],
  'Cartago|Jimenez': ['Juan Vinas', 'Tucurrique', 'Penjamo'],
  'Heredia|Heredia': ['Heredia', 'Mercedes', 'San Francisco'],
  'Heredia|Barva': ['Barva', 'San Pedro', 'San Pablo'],
  'Heredia|Santo Domingo': ['Santo Domingo', 'San Vicente', 'San Miguel'],
  'Heredia|San Rafael': ['San Rafael', 'San Jose de la Montana'],
  'Guanacaste|Liberia': ['Liberia', 'Canas Dulces', 'Mayorga'],
  'Guanacaste|Nicoya': ['Nicoya', 'Mansion', 'San Antonio'],
  'Guanacaste|Santa Cruz': ['Santa Cruz', 'Bolson', 'Veintisiete de Abril'],
  'Guanacaste|Carrillo': ['Filadelfia', 'Palmira', 'Sardinal'],
  'Puntarenas|Puntarenas': ['Puntarenas', 'Pitahaya', 'Chomes'],
  'Puntarenas|Esparza': ['Espiritu Santo', 'San Juan Grande'],
  'Puntarenas|Buenos Aires': ['Buenos Aires', 'Volcan', 'Potrero Grande'],
  'Puntarenas|Osa': ['Puerto Cortes', 'Palmar', 'Sierpe'],
  'Limon|Limon': ['Limon', 'Valle La Estrella', 'Rita'],
  'Limon|Pococi': ['Guapiles', 'Jimenez', 'Rita'],
  'Limon|Siquirres': ['Siquirres', 'Pacuarito', 'Florida'],
  'Limon|Talamanca': ['Bratsi', 'Sixaola', 'Cahuita'],
};
