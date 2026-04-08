import 'package:flutter/material.dart';
import 'package:altrupets_ui/altrupets_ui.dart';
import '../models/abuse_report_model.dart';

/// 3-step classification modal: Datos -> Clasificacion -> Asignacion.
class ClassifyModal extends StatefulWidget {
  final AbuseReportModel report;

  const ClassifyModal({super.key, required this.report});

  /// Show this modal as a dialog.
  static Future<void> show(BuildContext context, AbuseReportModel report) {
    return showDialog(
      context: context,
      builder: (_) => ClassifyModal(report: report),
    );
  }

  @override
  State<ClassifyModal> createState() => _ClassifyModalState();
}

class _ClassifyModalState extends State<ClassifyModal> {
  int _currentStep = 0;
  String? _selectedClassification;
  AbuseReportPriority _selectedPriority = AbuseReportPriority.medium;
  String? _selectedInspector;

  static const _stepLabels = ['Datos', 'Clasificacion', 'Asignacion'];

  static const _classificationOptions = [
    'Maltrato fisico directo',
    'Negligencia grave',
    'Abandono con lesiones',
    'Abandono sin lesiones',
    'Acumulacion compulsiva',
    'Condiciones insalubres',
    'Envenenamiento intencional',
    'Peleas organizadas',
    'Otro',
  ];

  static const _inspectors = [
    'Inspector Rodriguez',
    'Inspector Mora',
    'Inspector Jimenez',
    'Inspector Vargas',
  ];

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      maxWidth: 580,
      title: 'Clasificar Denuncia',
      subtitle:
          '${widget.report.trackingCode} \u00B7 Paso ${_currentStep + 1} de 3',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Step indicator
          _buildStepIndicator(),
          const SizedBox(height: 18),
          // Step content
          if (_currentStep == 0) _buildDatosStep(),
          if (_currentStep == 1) _buildClasificacionStep(),
          if (_currentStep == 2) _buildAsignacionStep(),
        ],
      ),
      actions: [
        if (_currentStep > 0)
          OutlinedButton(
            onPressed: () => setState(() => _currentStep--),
            style: OutlinedButton.styleFrom(
              foregroundColor: AltruPetsTokens.textSecondary,
              side: const BorderSide(color: AltruPetsTokens.surfaceBorder),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: const TextStyle(fontSize: 12),
            ),
            child: Text(
                '\u2190 ${_currentStep > 0 ? _stepLabels[_currentStep - 1] : ""}'),
          ),
        if (_currentStep < 2)
          ElevatedButton(
            onPressed: _canAdvance
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
            child: Text('${_stepLabels[_currentStep + 1]} \u2192'),
          ),
        if (_currentStep == 2)
          ElevatedButton(
            onPressed: _selectedInspector != null
                ? () => Navigator.of(context).pop()
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AltruPetsTokens.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Asignar y clasificar'),
          ),
      ],
    );
  }

  bool get _canAdvance {
    switch (_currentStep) {
      case 0:
        return true; // Data step is read-only
      case 1:
        return _selectedClassification != null;
      default:
        return true;
    }
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(3, (i) {
        final isActive = i == _currentStep;
        final isCompleted = i < _currentStep;
        return Expanded(
          child: Row(
            children: [
              if (i > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted
                        ? AltruPetsTokens.primary
                        : AltruPetsTokens.surfaceBorder,
                  ),
                ),
              Container(
                width: 26,
                height: 26,
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
              if (i < 2)
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
        );
      }),
    );
  }

  // ─── Step 0: Datos ─────────────────────────────────────────────

  Widget _buildDatosStep() {
    final r = widget.report;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Datos de la denuncia'),
        const SizedBox(height: 10),
        _infoRow('Codigo', r.trackingCode),
        _infoRow('Tipo(s)', r.abuseTypeSummary),
        _infoRow('Ubicacion', '${r.locationAddress}\n${r.shortLocation}, ${r.locationProvince}'),
        _infoRow('Privacidad', r.privacyMode == PrivacyMode.anonymous
            ? 'Anonimo'
            : r.privacyMode == PrivacyMode.public_
                ? 'Publico'
                : 'Confidencial'),
        _infoRow('GPS', r.hasGps ? '${r.latitude}, ${r.longitude}' : 'No disponible'),
        _infoRow('Evidencia', '${r.evidenceCount} archivo(s)'),
        const SizedBox(height: 10),
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
            r.description,
            style: const TextStyle(
              fontSize: 11,
              color: AltruPetsTokens.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Step 1: Clasificacion ─────────────────────────────────────

  Widget _buildClasificacionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Clasificacion del caso'),
        const SizedBox(height: 10),
        ...List.generate(_classificationOptions.length, (i) {
          final option = _classificationOptions[i];
          final isSelected = _selectedClassification == option;
          return GestureDetector(
            onTap: () => setState(() => _selectedClassification = option),
            child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 16,
                    color: isSelected
                        ? AltruPetsTokens.primary
                        : AltruPetsTokens.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    option,
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
        }),
        const SizedBox(height: 14),
        _sectionTitle('Prioridad'),
        const SizedBox(height: 8),
        Row(
          children: AbuseReportPriority.values.map((p) {
            final isSelected = _selectedPriority == p;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedPriority = p),
                child: Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _priorityColor(p).withValues(alpha: 0.15)
                        : AltruPetsTokens.surfaceContent,
                    borderRadius:
                        BorderRadius.circular(AltruPetsTokens.radiusSm),
                    border: Border.all(
                      color: isSelected
                          ? _priorityColor(p)
                          : AltruPetsTokens.surfaceBorder,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _priorityLabel(p),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? _priorityColor(p)
                          : AltruPetsTokens.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── Step 2: Asignacion ────────────────────────────────────────

  Widget _buildAsignacionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Asignar inspector'),
        const SizedBox(height: 10),
        // Summary of classification
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AltruPetsTokens.infoBg,
            border: Border.all(color: AltruPetsTokens.info),
            borderRadius: BorderRadius.circular(AltruPetsTokens.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resumen de clasificacion',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AltruPetsTokens.info,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Clasificado como: $_selectedClassification',
                style: const TextStyle(
                  fontSize: 10,
                  color: AltruPetsTokens.textPrimary,
                ),
              ),
              Text(
                'Prioridad: ${_priorityLabel(_selectedPriority)}',
                style: const TextStyle(
                  fontSize: 10,
                  color: AltruPetsTokens.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Inspector list
        ...List.generate(_inspectors.length, (i) {
          final inspector = _inspectors[i];
          final isSelected = _selectedInspector == inspector;
          return GestureDetector(
            onTap: () => setState(() => _selectedInspector = inspector),
            child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 16,
                    color: isSelected
                        ? AltruPetsTokens.primary
                        : AltruPetsTokens.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AltruPetsTokens.surfaceBorder,
                    child: Text(
                      inspector.split(' ').last[0],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AltruPetsTokens.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inspector,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: AltruPetsTokens.textPrimary,
                          ),
                        ),
                        Text(
                          i == 0
                              ? '3 casos activos'
                              : i == 1
                                  ? '2 casos activos'
                                  : i == 2
                                      ? '1 caso activo'
                                      : '0 casos activos',
                          style: const TextStyle(
                            fontSize: 9,
                            color: AltruPetsTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ─── Shared helpers ────────────────────────────────────────────

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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  Color _priorityColor(AbuseReportPriority p) {
    switch (p) {
      case AbuseReportPriority.low:
        return AltruPetsTokens.info;
      case AbuseReportPriority.medium:
        return AltruPetsTokens.warning;
      case AbuseReportPriority.high:
        return AltruPetsTokens.error;
      case AbuseReportPriority.critical:
        return AltruPetsTokens.error;
    }
  }

  String _priorityLabel(AbuseReportPriority p) {
    switch (p) {
      case AbuseReportPriority.low:
        return 'Baja';
      case AbuseReportPriority.medium:
        return 'Media';
      case AbuseReportPriority.high:
        return 'Alta';
      case AbuseReportPriority.critical:
        return 'Critica';
    }
  }
}
