import 'package:flutter/material.dart';
import 'package:altrupets_ui/altrupets_ui.dart';
import '../models/campaign_model.dart';
import 'campaign_stepper.dart';

/// Modal dialog for a single campaign with a 5-step stepper.
/// Each step shows different content:
///   0=Plan, 1=Promo, 2=Inscripcion, 3=Cirugia, 4=Seguimiento
class CampaignDetailModal extends StatefulWidget {
  final CampaignModel campaign;

  const CampaignDetailModal({super.key, required this.campaign});

  /// Show this modal as a dialog.
  static Future<void> show(BuildContext context, CampaignModel campaign) {
    return showDialog(
      context: context,
      builder: (_) => CampaignDetailModal(campaign: campaign),
    );
  }

  @override
  State<CampaignDetailModal> createState() => _CampaignDetailModalState();
}

class _CampaignDetailModalState extends State<CampaignDetailModal> {
  late int _currentStep;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.campaign.activeStepIndex;
  }

  static const _stepLabels = [
    'Plan',
    'Promo',
    'Inscripcion',
    'Cirugia',
    'Seguimiento',
  ];

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      maxWidth: 620,
      title: widget.campaign.title,
      subtitle:
          '${widget.campaign.code} \u00B7 ${widget.campaign.statusLabel}',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Interactive stepper
          _buildInteractiveStepper(),
          const SizedBox(height: 18),
          // Step content
          if (_currentStep == 0) _buildPlanStep(),
          if (_currentStep == 1) _buildPromoStep(),
          if (_currentStep == 2) _buildInscripcionStep(),
          if (_currentStep == 3) _buildCirugiaStep(),
          if (_currentStep == 4) _buildSeguimientoStep(),
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
            child: Text('\u2190 ${_currentStep > 0 ? _stepLabels[_currentStep - 1] : ""}'),
          ),
        if (_currentStep < 4)
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
            child: Text('${_stepLabels[_currentStep + 1]} \u2192'),
          ),
      ],
    );
  }

  Widget _buildInteractiveStepper() {
    return GestureDetector(
      child: CampaignStepper(
        activeStep: _currentStep,
        completedSteps: widget.campaign.completedSteps,
        showLabels: true,
        nodeSize: 30,
        labelFontSize: 10,
      ),
    );
  }

  // ─── Step 0: Plan ────────────────────────────────────────────────

  Widget _buildPlanStep() {
    final c = widget.campaign;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Planificacion de campana'),
        const SizedBox(height: 10),
        _infoRow('Ubicacion', c.location),
        _infoRow('Fecha de cirugia', c.surgeryDate),
        _infoRow('Fecha de inscripcion', '${c.registrationOpenDate ?? "N/A"} a ${c.registrationCloseDate ?? "N/A"}'),
        _infoRow('Fecha de orientacion', c.orientationDate ?? 'N/A'),
        _infoRow('Capacidad maxima', '${c.maxCapacity} animales'),
        _infoRow('Presupuesto asignado', c.formattedBudget),
        if (c.budgetSpent > 0)
          _infoRow('Presupuesto gastado', '\u20A1${(c.budgetSpent / 1000).toStringAsFixed(0)}K'),
        if (c.notes != null && c.notes!.isNotEmpty) ...[
          const SizedBox(height: 8),
          _sectionTitle('Notas'),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AltruPetsTokens.surfaceContent,
              borderRadius: BorderRadius.circular(AltruPetsTokens.radiusMd),
            ),
            child: Text(
              c.notes!,
              style: const TextStyle(
                fontSize: 11,
                color: AltruPetsTokens.textPrimary,
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        // Map placeholder
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: AltruPetsTokens.surfaceContent,
            borderRadius: BorderRadius.circular(AltruPetsTokens.radiusMd),
            border: Border.all(color: AltruPetsTokens.surfaceBorder),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, color: AltruPetsTokens.textSecondary, size: 28),
              const SizedBox(height: 4),
              Text(
                'Mapa: ${c.location}',
                style: const TextStyle(
                  fontSize: 10,
                  color: AltruPetsTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Step 1: Promo ───────────────────────────────────────────────

  Widget _buildPromoStep() {
    final c = widget.campaign;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Promocion y perifoneo'),
        const SizedBox(height: 10),
        _infoRow('Fecha de perifoneo', c.promotionDate ?? 'No programado'),
        _infoRow('Ubicacion', c.location),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AltruPetsTokens.infoBg,
            border: Border.all(color: AltruPetsTokens.info),
            borderRadius: BorderRadius.circular(AltruPetsTokens.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Actividades de promocion',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AltruPetsTokens.info,
                ),
              ),
              const SizedBox(height: 6),
              _promoItem('Perifoneo en la comunidad'),
              _promoItem('Volantes en comercios locales'),
              _promoItem('Publicacion en redes sociales'),
              _promoItem('Coordinacion con lider comunal'),
            ],
          ),
        ),
        if (c.notes != null && c.notes!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _sectionTitle('Notas'),
          const SizedBox(height: 4),
          Text(
            c.notes!,
            style: const TextStyle(
              fontSize: 11,
              color: AltruPetsTokens.textPrimary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _promoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          const Text(
            '\u2022 ',
            style: TextStyle(fontSize: 11, color: AltruPetsTokens.info),
          ),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: AltruPetsTokens.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step 2: Inscripcion ─────────────────────────────────────────

  Widget _buildInscripcionStep() {
    final regs = widget.campaign.registrations;
    final count = regs.length;
    final max = widget.campaign.maxCapacity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Inscripciones ($count/$max)'),
        const SizedBox(height: 8),
        // Progress bar
        _buildProgressBar(count, max),
        const SizedBox(height: 12),
        // Registration list
        if (regs.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'No hay inscripciones aun.',
                style: TextStyle(
                  fontSize: 11,
                  color: AltruPetsTokens.textSecondary,
                ),
              ),
            ),
          )
        else
          ...regs.take(10).map(_buildRegistrationRow),
        if (regs.length > 10)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '... y ${regs.length - 10} inscripciones mas',
              style: const TextStyle(
                fontSize: 10,
                color: AltruPetsTokens.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRegistrationRow(CampaignRegistrationModel reg) {
    final canCheckIn = reg.status == RegistrationStatus.registered;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(
        horizontal: AltruPetsTokens.spacing10,
        vertical: AltruPetsTokens.spacing6,
      ),
      decoration: BoxDecoration(
        color: AltruPetsTokens.surfaceContent,
        borderRadius: BorderRadius.circular(AltruPetsTokens.radiusSm),
      ),
      child: Row(
        children: [
          Text(
            reg.speciesEmoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${reg.animalName} (${reg.ownerName})',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AltruPetsTokens.textPrimary,
                  ),
                ),
                Text(
                  '${reg.animalSpecies == AnimalSpecies.dog ? "Perro" : "Gato"} \u00B7 ${reg.animalSex == AnimalSex.male ? "M" : "H"}'
                  '${reg.animalBreed != null ? " \u00B7 ${reg.animalBreed}" : ""}',
                  style: const TextStyle(
                    fontSize: 9,
                    color: AltruPetsTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          AppChip(
            label: reg.statusLabel,
            backgroundColor: _regStatusBgColor(reg.status),
            textColor: _regStatusTextColor(reg.status),
          ),
          if (canCheckIn) ...[
            const SizedBox(width: 6),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                side: const BorderSide(color: AltruPetsTokens.info),
                foregroundColor: AltruPetsTokens.info,
                textStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Check-in'),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Step 3: Cirugia ─────────────────────────────────────────────

  Widget _buildCirugiaStep() {
    final regs = widget.campaign.registrations;
    final checkedIn = regs.where((r) =>
        r.status == RegistrationStatus.checkedIn ||
        r.status == RegistrationStatus.operated ||
        r.status == RegistrationStatus.followUp3d ||
        r.status == RegistrationStatus.followUp7d ||
        r.status == RegistrationStatus.followUp14d ||
        r.status == RegistrationStatus.completed).toList();
    final operated = regs.where((r) =>
        r.status == RegistrationStatus.operated ||
        r.status == RegistrationStatus.followUp3d ||
        r.status == RegistrationStatus.followUp7d ||
        r.status == RegistrationStatus.followUp14d ||
        r.status == RegistrationStatus.completed).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Dia de cirugia'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _statBox(
                '${checkedIn.length}',
                'Presentes',
                AltruPetsTokens.info,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statBox(
                '${operated.length}',
                'Operados',
                AltruPetsTokens.success,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statBox(
                '${regs.length - checkedIn.length}',
                'Pendientes',
                AltruPetsTokens.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (checkedIn.isEmpty && operated.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'La cirugia aun no ha comenzado.',
                style: TextStyle(
                  fontSize: 11,
                  color: AltruPetsTokens.textSecondary,
                ),
              ),
            ),
          )
        else
          ...checkedIn.take(10).map((reg) => _buildSurgeryRow(reg)),
      ],
    );
  }

  Widget _buildSurgeryRow(CampaignRegistrationModel reg) {
    final canOperate = reg.status == RegistrationStatus.checkedIn;
    final isOperated = reg.status != RegistrationStatus.checkedIn;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(
        horizontal: AltruPetsTokens.spacing10,
        vertical: AltruPetsTokens.spacing6,
      ),
      decoration: BoxDecoration(
        color: isOperated
            ? AltruPetsTokens.successBg
            : AltruPetsTokens.surfaceContent,
        borderRadius: BorderRadius.circular(AltruPetsTokens.radiusSm),
      ),
      child: Row(
        children: [
          Text(reg.speciesEmoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${reg.animalName} (${reg.ownerName})',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AltruPetsTokens.textPrimary,
                  ),
                ),
                if (isOperated && reg.operatedByName != null)
                  Text(
                    'Operado por ${reg.operatedByName}',
                    style: const TextStyle(
                      fontSize: 9,
                      color: AltruPetsTokens.success,
                    ),
                  ),
              ],
            ),
          ),
          AppChip(
            label: reg.statusLabel,
            backgroundColor: _regStatusBgColor(reg.status),
            textColor: _regStatusTextColor(reg.status),
          ),
          if (canOperate) ...[
            const SizedBox(width: 6),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                side: const BorderSide(color: AltruPetsTokens.success),
                foregroundColor: AltruPetsTokens.success,
                textStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Registrar cirugia'),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Step 4: Seguimiento ─────────────────────────────────────────

  Widget _buildSeguimientoStep() {
    final regs = widget.campaign.registrations;
    final operated = regs.where((r) =>
        r.status == RegistrationStatus.operated ||
        r.status == RegistrationStatus.followUp3d ||
        r.status == RegistrationStatus.followUp7d ||
        r.status == RegistrationStatus.followUp14d ||
        r.status == RegistrationStatus.completed).toList();
    final fullyCompleted = regs
        .where((r) => r.status == RegistrationStatus.completed)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Seguimiento post-operatorio'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _statBox(
                '${operated.length}',
                'Operados',
                AltruPetsTokens.success,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statBox(
                '$fullyCompleted',
                'Seguimiento completo',
                AltruPetsTokens.info,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statBox(
                '${operated.length - fullyCompleted}',
                'Pendientes',
                AltruPetsTokens.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (operated.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'No hay animales operados para seguimiento.',
                style: TextStyle(
                  fontSize: 11,
                  color: AltruPetsTokens.textSecondary,
                ),
              ),
            ),
          )
        else
          ...operated.take(10).map(_buildFollowUpRow),
        if (operated.length > 10)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '... y ${operated.length - 10} mas',
              style: const TextStyle(
                fontSize: 10,
                color: AltruPetsTokens.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFollowUpRow(CampaignRegistrationModel reg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(
        horizontal: AltruPetsTokens.spacing10,
        vertical: AltruPetsTokens.spacing6,
      ),
      decoration: BoxDecoration(
        color: reg.status == RegistrationStatus.completed
            ? AltruPetsTokens.successBg
            : AltruPetsTokens.surfaceContent,
        borderRadius: BorderRadius.circular(AltruPetsTokens.radiusSm),
      ),
      child: Row(
        children: [
          Text(reg.speciesEmoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${reg.animalName} (${reg.ownerName})',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AltruPetsTokens.textPrimary,
                  ),
                ),
                if (reg.operatedByName != null)
                  Text(
                    'Operado por ${reg.operatedByName}',
                    style: const TextStyle(
                      fontSize: 9,
                      color: AltruPetsTokens.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          // Follow-up status indicators
          _buildFollowUpIndicator('3d', reg.status.index >= RegistrationStatus.followUp3d.index),
          const SizedBox(width: 4),
          _buildFollowUpIndicator('7d', reg.status.index >= RegistrationStatus.followUp7d.index),
          const SizedBox(width: 4),
          _buildFollowUpIndicator('14d', reg.status.index >= RegistrationStatus.followUp14d.index),
        ],
      ),
    );
  }

  Widget _buildFollowUpIndicator(String label, bool done) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: done ? AltruPetsTokens.successBg : AltruPetsTokens.surfaceBorder,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: done ? AltruPetsTokens.success : AltruPetsTokens.surfaceBorder,
        ),
      ),
      child: Text(
        done ? '\u2713 $label' : label,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: done ? AltruPetsTokens.success : AltruPetsTokens.textSecondary,
        ),
      ),
    );
  }

  // ─── Shared helpers ──────────────────────────────────────────────

  Widget _buildProgressBar(int current, int max) {
    final percent = max > 0 ? (current / max * 100).clamp(0.0, 100.0) : 0.0;
    final color = percent >= 90
        ? AltruPetsTokens.warning
        : percent >= 50
            ? AltruPetsTokens.info
            : AltruPetsTokens.success;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$current de $max inscritos',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AltruPetsTokens.textPrimary,
              ),
            ),
            Text(
              '${percent.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: AltruPetsTokens.surfaceBorder,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (percent / 100).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statBox(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AltruPetsTokens.surfaceContent,
        borderRadius: BorderRadius.circular(AltruPetsTokens.radiusMd),
        border: Border.all(color: AltruPetsTokens.surfaceBorder),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: AltruPetsTokens.textSecondary,
            ),
            textAlign: TextAlign.center,
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

  Color _regStatusBgColor(RegistrationStatus status) {
    switch (status) {
      case RegistrationStatus.registered:
        return AltruPetsTokens.infoBg;
      case RegistrationStatus.checkedIn:
        return AltruPetsTokens.warningBg;
      case RegistrationStatus.operated:
      case RegistrationStatus.followUp3d:
      case RegistrationStatus.followUp7d:
      case RegistrationStatus.followUp14d:
        return AltruPetsTokens.successBg;
      case RegistrationStatus.completed:
        return AltruPetsTokens.successBg;
    }
  }

  Color _regStatusTextColor(RegistrationStatus status) {
    switch (status) {
      case RegistrationStatus.registered:
        return AltruPetsTokens.info;
      case RegistrationStatus.checkedIn:
        return AltruPetsTokens.warning;
      case RegistrationStatus.operated:
      case RegistrationStatus.followUp3d:
      case RegistrationStatus.followUp7d:
      case RegistrationStatus.followUp14d:
        return AltruPetsTokens.success;
      case RegistrationStatus.completed:
        return AltruPetsTokens.success;
    }
  }
}
