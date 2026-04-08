import 'package:flutter/material.dart';
import 'package:altrupets_ui/altrupets_ui.dart';
import '../models/subsidy_request_model.dart';

/// Modal dialog with 3-step stepper: Datos -> Verificacion -> Decision.
/// Matches the mockup design exactly.
class SubsidyDetailModal extends StatefulWidget {
  final SubsidyRequestModel request;

  const SubsidyDetailModal({super.key, required this.request});

  /// Show this modal as a dialog.
  static Future<void> show(BuildContext context, SubsidyRequestModel request) {
    return showDialog(
      context: context,
      builder: (_) => SubsidyDetailModal(request: request),
    );
  }

  @override
  State<SubsidyDetailModal> createState() => _SubsidyDetailModalState();
}

class _SubsidyDetailModalState extends State<SubsidyDetailModal> {
  int _currentStep = 1; // 0=Datos, 1=Verificacion, 2=Decision

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title:
          'Desembolso Veterinario \u2014 ${widget.request.requesterName}',
      subtitle:
          '${widget.request.trackingCode} \u00B7 ${widget.request.timeAgo}',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStepper(),
          const SizedBox(height: 18),
          if (_currentStep == 0) _buildDatosStep(),
          if (_currentStep == 1) _buildVerificacionStep(),
          if (_currentStep == 2) _buildDecisionStep(),
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
              _currentStep == 1
                  ? '\u2190 Datos del caso'
                  : '\u2190 Verificacion',
            ),
          ),
        if (_currentStep < 2)
          ElevatedButton(
            onPressed: () => setState(() => _currentStep++),
            style: ElevatedButton.styleFrom(
              backgroundColor: AltruPetsTokens.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(
              _currentStep == 0
                  ? 'Siguiente: Verificacion \u2192'
                  : 'Siguiente: Decision \u2192',
            ),
          ),
        if (_currentStep == 2) ...[
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AltruPetsTokens.error,
              side: const BorderSide(color: AltruPetsTokens.error),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            child: const Text('Rechazar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AltruPetsTokens.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(
              widget.request.urgency == RequestUrgency.autoEligible
                  ? 'Aprobar (Automatico) \u2713'
                  : 'Aprobar (Manual) \u2713',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStepper() {
    final steps = ['Datos del caso', 'Verificacion', 'Decision'];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            children: [
              for (int i = 0; i < steps.length; i++) ...[
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 3,
                      color: i <= _currentStep
                          ? (i < _currentStep
                              ? AltruPetsTokens.success
                              : AltruPetsTokens.info)
                          : AltruPetsTokens.surfaceBorder,
                    ),
                  ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _currentStep
                        ? AltruPetsTokens.success
                        : i == _currentStep
                            ? AltruPetsTokens.info
                            : AltruPetsTokens.surfaceBorder,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    i < _currentStep ? '\u2713' : '${i + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: i <= _currentStep
                          ? Colors.white
                          : AltruPetsTokens.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: steps.asMap().entries.map((e) {
              final color = e.key < _currentStep
                  ? AltruPetsTokens.success
                  : e.key == _currentStep
                      ? AltruPetsTokens.info
                      : AltruPetsTokens.textSecondary;
              return Text(
                e.value,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: e.key <= _currentStep
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: color,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDatosStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Informacion del caso'),
        const SizedBox(height: 10),
        _infoRow('Animal', '${widget.request.animalEmoji} ${widget.request.animalName}'),
        _infoRow('Diagnostico', widget.request.diagnosis),
        _infoRow('Solicitante', widget.request.requesterName),
        _infoRow('Veterinaria', widget.request.vetClinicName),
        _infoRow('Monto solicitado', widget.request.formattedAmount),
        _infoRow('Tipo de procedimiento', widget.request.procedureType.name),
        _infoRow('Codigo de seguimiento', widget.request.trackingCode),
      ],
    );
  }

  Widget _buildVerificacionStep() {
    final allPassed = widget.request.ruleResults.every((r) => r.passed);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Verificacion automatica de reglas'),
        const SizedBox(height: 10),
        ...widget.request.ruleResults.map(_buildRuleCheck),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: allPassed
                ? AltruPetsTokens.successBg
                : AltruPetsTokens.warningBg,
            border: Border.all(
              color: allPassed
                  ? AltruPetsTokens.success
                  : AltruPetsTokens.warning,
            ),
            borderRadius: BorderRadius.circular(AltruPetsTokens.radiusMd),
          ),
          child: Center(
            child: Text(
              allPassed
                  ? '\u2713 Todas las reglas cumplen \u2014 aprobacion automatica disponible'
                  : '\u26A0 Algunas reglas no se cumplen \u2014 revision manual requerida',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: allPassed
                    ? AltruPetsTokens.success
                    : AltruPetsTokens.warning,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDecisionStep() {
    final allPassed = widget.request.ruleResults.every((r) => r.passed);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Decision'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AltruPetsTokens.surfaceCard,
            border: Border.all(color: AltruPetsTokens.surfaceBorder),
            borderRadius: BorderRadius.circular(AltruPetsTokens.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                allPassed
                    ? 'Esta solicitud califica para aprobacion automatica.'
                    : 'Esta solicitud requiere revision manual.',
                style: const TextStyle(
                  fontSize: 13,
                  color: AltruPetsTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Monto: ${widget.request.formattedAmount}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AltruPetsTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Veterinaria: ${widget.request.vetClinicName}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AltruPetsTokens.textSecondary,
                ),
              ),
              if (!allPassed) ...[
                const SizedBox(height: 12),
                const Text(
                  'Reglas que no se cumplen:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AltruPetsTokens.warning,
                  ),
                ),
                const SizedBox(height: 4),
                ...widget.request.ruleResults
                    .where((r) => !r.passed)
                    .map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '\u2022 ${r.reason}${r.detail != null ? " \u2014 ${r.detail}" : ""}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AltruPetsTokens.textSecondary,
                            ),
                          ),
                        )),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRuleCheck(RuleResultModel rule) {
    final passed = rule.passed;
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(
        horizontal: AltruPetsTokens.spacing10,
        vertical: AltruPetsTokens.spacing8,
      ),
      decoration: BoxDecoration(
        color: passed ? AltruPetsTokens.successBg : AltruPetsTokens.errorBg,
        border: Border.all(
          color: passed
              ? const Color(0xFF1B5E20)
              : const Color(0xFF5E1B1B),
        ),
        borderRadius: BorderRadius.circular(AltruPetsTokens.radiusMd),
      ),
      child: Row(
        children: [
          Text(
            passed ? '\u2713' : '\u2717',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: passed ? AltruPetsTokens.success : AltruPetsTokens.error,
            ),
          ),
          const SizedBox(width: AltruPetsTokens.spacing10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.reason,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AltruPetsTokens.textPrimary,
                  ),
                ),
                if (rule.detail != null)
                  Text(
                    rule.detail!,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AltruPetsTokens.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
        children: [
          SizedBox(
            width: 160,
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
