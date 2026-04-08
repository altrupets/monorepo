import 'package:flutter/material.dart';
import 'package:altrupets_ui/altrupets_ui.dart';
import '../models/abuse_report_model.dart';

/// Costa Rica provinces, cantons, and districts for the location dropdowns.
const _provinces = [
  'San Jose',
  'Alajuela',
  'Cartago',
  'Heredia',
  'Guanacaste',
  'Puntarenas',
  'Limon',
];

const _herediaCantones = [
  'Heredia',
  'Barva',
  'Santo Domingo',
  'Santa Barbara',
  'San Rafael',
  'San Isidro',
  'Belen',
  'Flores',
  'San Pablo',
  'Sarapiqui',
];

const _herediaDistritos = [
  'Heredia',
  'Mercedes',
  'San Francisco',
  'Ulloa',
  'Varablanca',
];

/// Public multi-step form for reporting animal abuse.
/// Accessible at `/denuncias` WITHOUT authentication.
///
/// Steps:
///   1. Ubicacion (province/canton/district + address + GPS)
///   2. Tipo de maltrato (checkboxes + description + evidence)
///   3. Privacidad (mode selection + conditional identity fields)
///   4. Confirmacion (tracking code)
class PublicComplaintForm extends StatefulWidget {
  const PublicComplaintForm({super.key});

  @override
  State<PublicComplaintForm> createState() => _PublicComplaintFormState();
}

class _PublicComplaintFormState extends State<PublicComplaintForm> {
  int _currentStep = 0;
  bool _submitted = false;
  String? _trackingCode;

  // Step 1: Location
  String? _selectedProvince;
  String? _selectedCanton;
  String? _selectedDistrict;
  final _addressController = TextEditingController();
  bool _useGps = false;

  // Step 2: Abuse type
  final Set<AbuseType> _selectedAbuseTypes = {};
  final _descriptionController = TextEditingController();
  final List<String> _uploadedPhotos = [];

  // Step 3: Privacy
  PrivacyMode _privacyMode = PrivacyMode.anonymous;
  final _fullNameController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _consentGiven = false;

  static const _stepTitles = [
    'Ubicacion',
    'Tipo de maltrato',
    'Privacidad',
    'Confirmacion',
  ];

  @override
  void dispose() {
    _addressController.dispose();
    _descriptionController.dispose();
    _fullNameController.dispose();
    _cedulaController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AltruPetsTokens.surfaceContent,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBranding(),
                const SizedBox(height: 24),
                _buildStepIndicator(),
                const SizedBox(height: 24),
                _buildCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBranding() {
    return Column(
      children: [
        // AltruPets logo placeholder
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AltruPetsTokens.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const Text(
            'AP',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Denuncia de Maltrato Animal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AltruPetsTokens.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Formulario publico \u00B7 No requiere cuenta',
          style: TextStyle(
            fontSize: 12,
            color: AltruPetsTokens.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(4, (i) {
        final isActive = i == _currentStep;
        final isCompleted = i < _currentStep || _submitted;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (i > 0)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isCompleted || isActive
                            ? AltruPetsTokens.primary
                            : AltruPetsTokens.surfaceBorder,
                      ),
                    ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? AltruPetsTokens.primary
                          : isCompleted
                              ? AltruPetsTokens.success
                              : AltruPetsTokens.surfaceBorder,
                    ),
                    alignment: Alignment.center,
                    child: isCompleted
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isActive
                                  ? Colors.white
                                  : AltruPetsTokens.textSecondary,
                            ),
                          ),
                  ),
                  if (i < 3)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isCompleted
                            ? AltruPetsTokens.primary
                            : AltruPetsTokens.surfaceBorder,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _stepTitles[i],
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive
                      ? AltruPetsTokens.primary
                      : AltruPetsTokens.textSecondary,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AltruPetsTokens.surfaceCard,
        borderRadius: BorderRadius.circular(AltruPetsTokens.radiusXl),
        border: Border.all(color: AltruPetsTokens.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_submitted) _buildConfirmationStep() else ...[
            if (_currentStep == 0) _buildLocationStep(),
            if (_currentStep == 1) _buildAbuseTypeStep(),
            if (_currentStep == 2) _buildPrivacyStep(),
            if (_currentStep == 3) _buildReviewStep(),
            const SizedBox(height: 20),
            _buildNavButtons(),
          ],
        ],
      ),
    );
  }

  // ─── Step 1: Ubicacion ─────────────────────────────────────────

  Widget _buildLocationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Ubicacion del incidente'),
        const SizedBox(height: 12),
        // Province
        _buildDropdown(
          label: 'Provincia',
          value: _selectedProvince,
          items: _provinces,
          onChanged: (v) => setState(() {
            _selectedProvince = v;
            _selectedCanton = null;
            _selectedDistrict = null;
          }),
        ),
        const SizedBox(height: 10),
        // Canton
        _buildDropdown(
          label: 'Canton',
          value: _selectedCanton,
          items: _selectedProvince == 'Heredia' ? _herediaCantones : ['(Seleccione provincia primero)'],
          onChanged: (v) => setState(() {
            _selectedCanton = v;
            _selectedDistrict = null;
          }),
        ),
        const SizedBox(height: 10),
        // District
        _buildDropdown(
          label: 'Distrito',
          value: _selectedDistrict,
          items: _selectedCanton == 'Heredia' ? _herediaDistritos : ['(Seleccione canton primero)'],
          onChanged: (v) => setState(() => _selectedDistrict = v),
        ),
        const SizedBox(height: 10),
        // Address
        _buildTextField(
          label: 'Direccion exacta o referencias',
          controller: _addressController,
          maxLines: 2,
          hint: 'Ej: 200m sur de la iglesia, casa color celeste',
        ),
        const SizedBox(height: 12),
        // GPS toggle
        GestureDetector(
          onTap: () => setState(() => _useGps = !_useGps),
          child: Row(
            children: [
              Icon(
                _useGps ? Icons.check_box : Icons.check_box_outline_blank,
                size: 18,
                color: _useGps
                    ? AltruPetsTokens.primary
                    : AltruPetsTokens.textSecondary,
              ),
              const SizedBox(width: 6),
              const Text(
                'Adjuntar ubicacion GPS automatica',
                style: TextStyle(
                  fontSize: 11,
                  color: AltruPetsTokens.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.gps_fixed,
                size: 14,
                color: AltruPetsTokens.textSecondary,
              ),
            ],
          ),
        ),
        if (_useGps) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AltruPetsTokens.successBg,
              borderRadius: BorderRadius.circular(AltruPetsTokens.radiusSm),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, size: 14, color: AltruPetsTokens.success),
                SizedBox(width: 6),
                Text(
                  'GPS capturado: 9.9981, -84.1198',
                  style: TextStyle(
                    fontSize: 10,
                    color: AltruPetsTokens.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ─── Step 2: Tipo de maltrato ──────────────────────────────────

  Widget _buildAbuseTypeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Tipo de maltrato observado'),
        const SizedBox(height: 4),
        const Text(
          'Seleccione uno o mas tipos de maltrato',
          style: TextStyle(
            fontSize: 10,
            color: AltruPetsTokens.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        // Abuse type checkboxes
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: AbuseType.values.map((type) {
            final isSelected = _selectedAbuseTypes.contains(type);
            return GestureDetector(
              onTap: () => setState(() {
                if (isSelected) {
                  _selectedAbuseTypes.remove(type);
                } else {
                  _selectedAbuseTypes.add(type);
                }
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AltruPetsTokens.primary.withValues(alpha: 0.15)
                      : AltruPetsTokens.surfaceContent,
                  borderRadius: BorderRadius.circular(AltruPetsTokens.radiusSm),
                  border: Border.all(
                    color: isSelected
                        ? AltruPetsTokens.primary
                        : AltruPetsTokens.surfaceBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 14,
                      color: isSelected
                          ? AltruPetsTokens.primary
                          : AltruPetsTokens.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      type.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: AltruPetsTokens.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        // Description
        _buildTextField(
          label: 'Descripcion detallada',
          controller: _descriptionController,
          maxLines: 4,
          hint: 'Describa lo que observo: condiciones del animal, ubicacion exacta, '
              'frecuencia del maltrato, etc.',
        ),
        const SizedBox(height: 14),
        // Photo upload area
        _sectionTitle('Evidencia fotografica (opcional)'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() {
            // Mock photo upload
            _uploadedPhotos.add('foto-${_uploadedPhotos.length + 1}.jpg');
          }),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: AltruPetsTokens.surfaceContent,
              borderRadius: BorderRadius.circular(AltruPetsTokens.radiusMd),
              border: Border.all(
                color: AltruPetsTokens.surfaceBorder,
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cloud_upload_outlined,
                  size: 24,
                  color: AltruPetsTokens.textSecondary,
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Subir fotos o videos',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AltruPetsTokens.primary,
                      ),
                    ),
                    Text(
                      _uploadedPhotos.isEmpty
                          ? 'JPG, PNG, MP4 \u00B7 Max 10MB'
                          : '${_uploadedPhotos.length} archivo(s) adjuntos',
                      style: const TextStyle(
                        fontSize: 9,
                        color: AltruPetsTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_uploadedPhotos.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            children: _uploadedPhotos.map((f) => AppChip(
              label: f,
              backgroundColor: AltruPetsTokens.successBg,
              textColor: AltruPetsTokens.success,
            )).toList(),
          ),
        ],
      ],
    );
  }

  // ─── Step 3: Privacidad ────────────────────────────────────────

  Widget _buildPrivacyStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Modo de privacidad'),
        const SizedBox(height: 4),
        const Text(
          'Seleccione como desea identificarse en esta denuncia',
          style: TextStyle(
            fontSize: 10,
            color: AltruPetsTokens.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        // Privacy mode options
        _privacyOption(
          mode: PrivacyMode.anonymous,
          title: 'Anonimo',
          description: 'Su identidad no sera registrada. La denuncia sera procesada '
              'pero no podra dar seguimiento personalizado.',
          icon: Icons.visibility_off,
        ),
        const SizedBox(height: 6),
        _privacyOption(
          mode: PrivacyMode.confidential,
          title: 'Confidencial',
          description: 'Sus datos se almacenan de forma separada y solo el oficial '
              'autorizado puede accederlos (Anexo D).',
          icon: Icons.lock,
        ),
        const SizedBox(height: 6),
        _privacyOption(
          mode: PrivacyMode.public_,
          title: 'Publico',
          description: 'Su nombre aparecera asociado a la denuncia como testigo.',
          icon: Icons.person,
        ),

        // Conditional identity fields
        if (_privacyMode != PrivacyMode.anonymous) ...[
          const SizedBox(height: 16),
          _sectionTitle('Datos del denunciante'),
          const SizedBox(height: 10),
          _buildTextField(
            label: 'Nombre completo *',
            controller: _fullNameController,
            hint: 'Nombre y apellidos',
          ),
          const SizedBox(height: 8),
          _buildTextField(
            label: 'Numero de cedula *',
            controller: _cedulaController,
            hint: 'Ej: 1-0234-0567',
          ),
          const SizedBox(height: 8),
          _buildTextField(
            label: 'Telefono (opcional)',
            controller: _phoneController,
            hint: 'Ej: 8888-1234',
          ),
          const SizedBox(height: 8),
          _buildTextField(
            label: 'Correo electronico (opcional)',
            controller: _emailController,
            hint: 'correo@ejemplo.com',
          ),
          const SizedBox(height: 12),
          // Consent checkbox
          GestureDetector(
            onTap: () => setState(() => _consentGiven = !_consentGiven),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _consentGiven ? Icons.check_box : Icons.check_box_outline_blank,
                  size: 18,
                  color: _consentGiven
                      ? AltruPetsTokens.primary
                      : AltruPetsTokens.textSecondary,
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Doy mi consentimiento para el almacenamiento de mis datos personales '
                    'con el fin exclusivo del procesamiento de esta denuncia, conforme '
                    'a la Ley de Proteccion de la Persona Frente al Tratamiento de sus Datos Personales.',
                    style: TextStyle(
                      fontSize: 10,
                      color: AltruPetsTokens.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _privacyOption({
    required PrivacyMode mode,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _privacyMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _privacyMode = mode),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AltruPetsTokens.primary.withValues(alpha: 0.1)
              : AltruPetsTokens.surfaceContent,
          borderRadius: BorderRadius.circular(AltruPetsTokens.radiusMd),
          border: Border.all(
            color: isSelected
                ? AltruPetsTokens.primary
                : AltruPetsTokens.surfaceBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: 18,
              color: isSelected
                  ? AltruPetsTokens.primary
                  : AltruPetsTokens.textSecondary,
            ),
            const SizedBox(width: 10),
            Icon(icon, size: 20, color: AltruPetsTokens.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: AltruPetsTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 9,
                      color: AltruPetsTokens.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Step 4: Review (before submit) ────────────────────────────

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Resumen de la denuncia'),
        const SizedBox(height: 12),
        _reviewRow('Ubicacion',
            '${_selectedDistrict ?? "?"}, ${_selectedCanton ?? "?"}, ${_selectedProvince ?? "?"}'),
        _reviewRow('Direccion', _addressController.text.isEmpty
            ? '(No especificada)'
            : _addressController.text),
        _reviewRow('GPS', _useGps ? '9.9981, -84.1198' : 'No adjunto'),
        _reviewRow('Tipo(s) de maltrato',
            _selectedAbuseTypes.isEmpty
                ? '(Ninguno seleccionado)'
                : _selectedAbuseTypes.map((t) => t.label).join(', ')),
        _reviewRow('Evidencia', '${_uploadedPhotos.length} archivo(s)'),
        _reviewRow('Privacidad', _privacyMode == PrivacyMode.anonymous
            ? 'Anonimo'
            : _privacyMode == PrivacyMode.public_
                ? 'Publico'
                : 'Confidencial'),
        if (_privacyMode != PrivacyMode.anonymous)
          _reviewRow('Denunciante', _fullNameController.text),
        const SizedBox(height: 12),
        _sectionTitle('Descripcion'),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AltruPetsTokens.surfaceContent,
            borderRadius: BorderRadius.circular(AltruPetsTokens.radiusMd),
          ),
          child: Text(
            _descriptionController.text.isEmpty
                ? '(Sin descripcion)'
                : _descriptionController.text,
            style: const TextStyle(
              fontSize: 11,
              color: AltruPetsTokens.textPrimary,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Legal disclaimer
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AltruPetsTokens.warningBg,
            border: Border.all(color: AltruPetsTokens.warning),
            borderRadius: BorderRadius.circular(AltruPetsTokens.radiusMd),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: AltruPetsTokens.warning),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Al enviar esta denuncia confirma que la informacion proporcionada '
                  'es veridica. Las denuncias falsas pueden tener consecuencias legales.',
                  style: TextStyle(
                    fontSize: 10,
                    color: AltruPetsTokens.textPrimary,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Confirmation (after submit) ───────────────────────────────

  Widget _buildConfirmationStep() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AltruPetsTokens.successBg,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.check_circle,
            size: 40,
            color: AltruPetsTokens.success,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Denuncia enviada',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AltruPetsTokens.success,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Su denuncia ha sido registrada exitosamente.\nGuarde su codigo de rastreo:',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: AltruPetsTokens.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        // Tracking code
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: AltruPetsTokens.surfaceContent,
            borderRadius: BorderRadius.circular(AltruPetsTokens.radiusMd),
            border: Border.all(color: AltruPetsTokens.primary),
          ),
          child: SelectableText(
            _trackingCode ?? 'DEN-2026-0001',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AltruPetsTokens.primary,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Puede consultar el estado de su denuncia en cualquier momento\n'
          'usando este codigo en la pagina de rastreo.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: AltruPetsTokens.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                // Navigate to tracking page
              },
              icon: const Icon(Icons.search, size: 14),
              label: const Text('Rastrear denuncia'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AltruPetsTokens.primary,
                side: const BorderSide(color: AltruPetsTokens.primary),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () => setState(() {
                _currentStep = 0;
                _submitted = false;
                _selectedAbuseTypes.clear();
                _descriptionController.clear();
                _uploadedPhotos.clear();
                _addressController.clear();
                _fullNameController.clear();
                _cedulaController.clear();
                _phoneController.clear();
                _emailController.clear();
                _consentGiven = false;
                _privacyMode = PrivacyMode.anonymous;
              }),
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Nueva denuncia'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AltruPetsTokens.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Navigation buttons ────────────────────────────────────────

  Widget _buildNavButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep > 0)
          OutlinedButton(
            onPressed: () => setState(() => _currentStep--),
            style: OutlinedButton.styleFrom(
              foregroundColor: AltruPetsTokens.textSecondary,
              side: const BorderSide(color: AltruPetsTokens.surfaceBorder),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: const TextStyle(fontSize: 12),
            ),
            child: Text('\u2190 ${_stepTitles[_currentStep - 1]}'),
          )
        else
          const SizedBox.shrink(),
        if (_currentStep < 3)
          ElevatedButton(
            onPressed: _canAdvanceStep
                ? () => setState(() => _currentStep++)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AltruPetsTokens.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text('${_stepTitles[_currentStep + 1]} \u2192'),
          ),
        if (_currentStep == 3)
          ElevatedButton.icon(
            onPressed: _canSubmit ? _submitForm : null,
            icon: const Icon(Icons.send, size: 14),
            label: const Text('Enviar denuncia'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AltruPetsTokens.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  bool get _canAdvanceStep {
    switch (_currentStep) {
      case 0:
        return _selectedProvince != null &&
            _selectedCanton != null &&
            _selectedDistrict != null;
      case 1:
        return _selectedAbuseTypes.isNotEmpty &&
            _descriptionController.text.isNotEmpty;
      case 2:
        if (_privacyMode == PrivacyMode.anonymous) return true;
        return _fullNameController.text.isNotEmpty &&
            _cedulaController.text.isNotEmpty &&
            _consentGiven;
      default:
        return true;
    }
  }

  bool get _canSubmit => true; // Review step is always submittable

  void _submitForm() {
    // Generate mock tracking code
    final year = DateTime.now().year;
    final seq = (DateTime.now().millisecond % 9999).toString().padLeft(4, '0');
    setState(() {
      _trackingCode = 'DEN-$year-$seq';
      _submitted = true;
    });
  }

  // ─── Shared widgets ────────────────────────────────────────────

  Widget _sectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        color: AltruPetsTokens.textSecondary,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AltruPetsTokens.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AltruPetsTokens.surfaceContent,
            borderRadius: BorderRadius.circular(AltruPetsTokens.radiusSm),
            border: Border.all(color: AltruPetsTokens.surfaceBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                'Seleccione $label',
                style: const TextStyle(
                  fontSize: 11,
                  color: AltruPetsTokens.textSecondary,
                ),
              ),
              isExpanded: true,
              dropdownColor: AltruPetsTokens.surfaceCard,
              style: const TextStyle(
                fontSize: 11,
                color: AltruPetsTokens.textPrimary,
              ),
              items: items.map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AltruPetsTokens.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 11,
            color: AltruPetsTokens.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 11,
              color: AltruPetsTokens.textSecondary,
            ),
            filled: true,
            fillColor: AltruPetsTokens.surfaceContent,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AltruPetsTokens.radiusSm),
              borderSide: const BorderSide(color: AltruPetsTokens.surfaceBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AltruPetsTokens.radiusSm),
              borderSide: const BorderSide(color: AltruPetsTokens.surfaceBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AltruPetsTokens.radiusSm),
              borderSide: const BorderSide(color: AltruPetsTokens.primary),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AltruPetsTokens.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AltruPetsTokens.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
