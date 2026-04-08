import 'campaign_model.dart';

/// Mock campaign metrics matching the HTML mockup KPI cards.
const mockCampaignMetrics = CampaignMetricsModel(
  totalSterilized: 127,
  avgCostPerAnimal: 35000,
  communitiesCovered: 8,
  communitiesTotal: 14,
  daysUntilNextCampaign: 7,
  totalCampaigns: 5,
  activeCampaigns: 2,
  completedCampaigns: 3,
);

// ─── Registrations for "San Rafael" campaign ──────────────────────

final _sanRafaelRegistrations = [
  CampaignRegistrationModel(
    id: 'reg-1',
    ownerName: 'Maria Fernandez',
    ownerPhone: '8888-1234',
    animalName: 'Luna',
    animalSpecies: AnimalSpecies.cat,
    animalBreed: 'Mestiza',
    animalAge: '2 anos',
    animalSex: AnimalSex.female,
    status: RegistrationStatus.registered,
    createdAt: DateTime(2026, 4, 1),
  ),
  CampaignRegistrationModel(
    id: 'reg-2',
    ownerName: 'Carlos Mora',
    ownerPhone: '8888-5678',
    animalName: 'Rocky',
    animalSpecies: AnimalSpecies.dog,
    animalBreed: 'Labrador mix',
    animalAge: '3 anos',
    animalSex: AnimalSex.male,
    status: RegistrationStatus.registered,
    createdAt: DateTime(2026, 4, 1),
  ),
  CampaignRegistrationModel(
    id: 'reg-3',
    ownerName: 'Ana Lopez',
    ownerPhone: '8888-9012',
    animalName: 'Michi',
    animalSpecies: AnimalSpecies.cat,
    animalAge: '1 ano',
    animalSex: AnimalSex.female,
    status: RegistrationStatus.registered,
    createdAt: DateTime(2026, 4, 2),
  ),
  CampaignRegistrationModel(
    id: 'reg-4',
    ownerName: 'Pedro Vargas',
    ownerPhone: '8888-3456',
    animalName: 'Max',
    animalSpecies: AnimalSpecies.dog,
    animalBreed: 'Pastor aleman',
    animalAge: '4 anos',
    animalSex: AnimalSex.male,
    status: RegistrationStatus.registered,
    createdAt: DateTime(2026, 4, 2),
  ),
  CampaignRegistrationModel(
    id: 'reg-5',
    ownerName: 'Sofia Herrera',
    ownerPhone: '8888-7890',
    animalName: 'Canela',
    animalSpecies: AnimalSpecies.dog,
    animalBreed: 'Criolla',
    animalAge: '2 anos',
    animalSex: AnimalSex.female,
    status: RegistrationStatus.registered,
    createdAt: DateTime(2026, 4, 3),
  ),
];

// Generate 23 more placeholder registrations for San Rafael (total 28/40)
final List<CampaignRegistrationModel> _sanRafaelExtraRegistrations =
    List.generate(
  23,
  (i) => CampaignRegistrationModel(
    id: 'reg-sr-${i + 6}',
    ownerName: 'Vecino ${i + 6}',
    ownerPhone: '8888-${(1000 + i).toString().padLeft(4, '0')}',
    animalName: i.isEven ? 'Perrito ${i + 6}' : 'Gatito ${i + 6}',
    animalSpecies: i.isEven ? AnimalSpecies.dog : AnimalSpecies.cat,
    animalSex: i.isEven ? AnimalSex.male : AnimalSex.female,
    status: RegistrationStatus.registered,
    createdAt: DateTime(2026, 4, 3),
  ),
);

// ─── Registrations for "Barrio Fatima" campaign (completed) ───────

final _fatimaRegistrations = [
  CampaignRegistrationModel(
    id: 'reg-f-1',
    ownerName: 'Rosa Martinez',
    ownerPhone: '8877-1111',
    animalName: 'Pelusa',
    animalSpecies: AnimalSpecies.cat,
    animalSex: AnimalSex.female,
    status: RegistrationStatus.completed,
    operatedByName: 'Dr. Carlos Vega',
    operatedAt: DateTime(2026, 3, 15),
    createdAt: DateTime(2026, 3, 1),
  ),
  CampaignRegistrationModel(
    id: 'reg-f-2',
    ownerName: 'Juan Ramirez',
    ownerPhone: '8877-2222',
    animalName: 'Bobby',
    animalSpecies: AnimalSpecies.dog,
    animalBreed: 'Mestizo',
    animalAge: '5 anos',
    animalSex: AnimalSex.male,
    status: RegistrationStatus.completed,
    operatedByName: 'Dra. Laura Solis',
    operatedAt: DateTime(2026, 3, 15),
    createdAt: DateTime(2026, 3, 1),
  ),
  CampaignRegistrationModel(
    id: 'reg-f-3',
    ownerName: 'Isabel Castro',
    ownerPhone: '8877-3333',
    animalName: 'Nieve',
    animalSpecies: AnimalSpecies.cat,
    animalAge: '1 ano',
    animalSex: AnimalSex.female,
    status: RegistrationStatus.completed,
    operatedByName: 'Dr. Carlos Vega',
    operatedAt: DateTime(2026, 3, 15),
    createdAt: DateTime(2026, 3, 2),
  ),
];

// Generate 32 more completed registrations for Fatima (total 35/40)
final List<CampaignRegistrationModel> _fatimaExtraRegistrations =
    List.generate(
  32,
  (i) => CampaignRegistrationModel(
    id: 'reg-f-${i + 4}',
    ownerName: 'Vecino F${i + 4}',
    ownerPhone: '8877-${(4000 + i).toString().padLeft(4, '0')}',
    animalName: i.isEven ? 'Perrito F${i + 4}' : 'Gatito F${i + 4}',
    animalSpecies: i.isEven ? AnimalSpecies.dog : AnimalSpecies.cat,
    animalSex: i.isEven ? AnimalSex.male : AnimalSex.female,
    status: RegistrationStatus.completed,
    operatedByName: i.isEven ? 'Dr. Carlos Vega' : 'Dra. Laura Solis',
    operatedAt: DateTime(2026, 3, 15),
    createdAt: DateTime(2026, 3, 2),
  ),
);

/// 3 mock campaigns as specified.
final mockCampaigns = <CampaignModel>[
  // 1. REGISTRATION_OPEN — 28/40 inscritos, step 3 (Inscripcion) active
  CampaignModel(
    id: 'camp-1',
    code: 'CAM-2026-001',
    title: 'Castracion San Rafael de Heredia',
    location: 'San Rafael de Heredia',
    status: CampaignStatus.registrationOpen,
    maxCapacity: 40,
    surgeryDate: '2026-04-15',
    promotionDate: '2026-03-25',
    registrationOpenDate: '2026-04-01',
    registrationCloseDate: '2026-04-12',
    orientationDate: '2026-04-14',
    budgetAllocated: 1400000,
    budgetSpent: 0,
    registrations: [
      ..._sanRafaelRegistrations,
      ..._sanRafaelExtraRegistrations,
    ],
    notes: 'Coordinado con Clinica Dr. Carlos y Dra. Laura.',
    createdAt: DateTime(2026, 3, 15),
  ),
  // 2. DRAFT (EN PLANIFICACION) — step 1 (Plan) active
  CampaignModel(
    id: 'camp-2',
    code: 'CAM-2026-002',
    title: 'Castracion Mercedes Norte',
    location: 'Mercedes Norte',
    status: CampaignStatus.draft,
    maxCapacity: 50,
    surgeryDate: '2026-05-10',
    promotionDate: '2026-04-20',
    registrationOpenDate: '2026-04-25',
    registrationCloseDate: '2026-05-07',
    orientationDate: '2026-05-09',
    budgetAllocated: 1750000,
    budgetSpent: 0,
    registrations: [],
    notes: 'Pendiente confirmar veterinarios.',
    createdAt: DateTime(2026, 4, 1),
  ),
  // 3. COMPLETED — 35/40 operados, all steps green
  CampaignModel(
    id: 'camp-3',
    code: 'CAM-2026-003',
    title: 'Castracion Barrio Fatima',
    location: 'Barrio Fatima',
    status: CampaignStatus.completed,
    maxCapacity: 40,
    surgeryDate: '2026-03-15',
    promotionDate: '2026-03-01',
    registrationOpenDate: '2026-03-03',
    registrationCloseDate: '2026-03-12',
    orientationDate: '2026-03-14',
    budgetAllocated: 1400000,
    budgetSpent: 1225000,
    registrations: [
      ..._fatimaRegistrations,
      ..._fatimaExtraRegistrations,
    ],
    createdAt: DateTime(2026, 2, 15),
  ),
];

/// Convenience getters for tabs.
List<CampaignModel> get mockActiveCampaigns => mockCampaigns
    .where((c) =>
        c.status != CampaignStatus.completed &&
        c.status != CampaignStatus.archived &&
        c.status != CampaignStatus.draft)
    .toList();

List<CampaignModel> get mockCompletedCampaigns => mockCampaigns
    .where((c) =>
        c.status == CampaignStatus.completed ||
        c.status == CampaignStatus.archived)
    .toList();

List<CampaignModel> get mockDraftCampaigns =>
    mockCampaigns.where((c) => c.status == CampaignStatus.draft).toList();
