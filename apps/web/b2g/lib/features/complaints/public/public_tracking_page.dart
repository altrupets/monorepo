import 'package:flutter/material.dart';
import 'package:altrupets_ui/altrupets_ui.dart';
import '../models/abuse_report_model.dart';
import '../models/mock_data.dart';

/// Public page for tracking an abuse report status.
/// Accessible at `/denuncias/rastreo/{code}` WITHOUT authentication.
class PublicTrackingPage extends StatefulWidget {
  final String? trackingCode;

  const PublicTrackingPage({super.key, this.trackingCode});

  @override
  State<PublicTrackingPage> createState() => _PublicTrackingPageState();
}

class _PublicTrackingPageState extends State<PublicTrackingPage> {
  final _codeController = TextEditingController();
  AbuseReportModel? _foundReport;
  bool _searched = false;
  bool _notFound = false;

  @override
  void initState() {
    super.initState();
    if (widget.trackingCode != null && widget.trackingCode!.isNotEmpty) {
      _codeController.text = widget.trackingCode!;
      _search();
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _search() {
    final code = _codeController.text.trim().toUpperCase();
    final match = mockAbuseReports.where((r) => r.trackingCode == code).toList();
    setState(() {
      _searched = true;
      if (match.isNotEmpty) {
        _foundReport = match.first;
        _notFound = false;
      } else {
        _foundReport = null;
        _notFound = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AltruPetsTokens.surfaceContent,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBranding(),
                const SizedBox(height: 24),
                _buildSearchCard(),
                if (_searched && _foundReport != null) ...[
                  const SizedBox(height: 16),
                  _buildStatusCard(_foundReport!),
                ],
                if (_searched && _notFound) ...[
                  const SizedBox(height: 16),
                  _buildNotFoundCard(),
                ],
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
          'Rastreo de Denuncia',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AltruPetsTokens.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Consulte el estado de su denuncia',
          style: TextStyle(
            fontSize: 12,
            color: AltruPetsTokens.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AltruPetsTokens.surfaceCard,
        borderRadius: BorderRadius.circular(AltruPetsTokens.radiusXl),
        border: Border.all(color: AltruPetsTokens.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CODIGO DE RASTREO',
            style: TextStyle(
              fontSize: 10,
              color: AltruPetsTokens.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeController,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AltruPetsTokens.textPrimary,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'DEN-2026-0001',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: AltruPetsTokens.textSecondary,
                      letterSpacing: 1,
                    ),
                    filled: true,
                    fillColor: AltruPetsTokens.surfaceContent,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
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
                  textCapitalization: TextCapitalization.characters,
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _search,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AltruPetsTokens.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Buscar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(AbuseReportModel report) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AltruPetsTokens.surfaceCard,
        borderRadius: BorderRadius.circular(AltruPetsTokens.radiusXl),
        border: Border.all(color: AltruPetsTokens.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.trackingCode,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AltruPetsTokens.primary,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Registrada ${report.timeAgo}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AltruPetsTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AppChip(
                label: report.statusLabel,
                backgroundColor: _statusBgColor(report.status),
                textColor: _statusTextColor(report.status),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status timeline
          _buildTimeline(report),

          const SizedBox(height: 16),

          // Details
          _infoRow('Tipo(s)', report.abuseTypeSummary),
          _infoRow('Ubicacion', '${report.shortLocation}, ${report.locationProvince}'),
          _infoRow('Prioridad', report.priorityLabel),
          if (report.classifiedAs != null)
            _infoRow('Clasificacion', report.classifiedAs!),
          if (report.resolvedAt != null)
            _infoRow('Resolucion', report.resolutionNotes ?? 'Resuelta'),
        ],
      ),
    );
  }

  Widget _buildTimeline(AbuseReportModel report) {
    final steps = [
      _TimelineStep('Denuncia registrada', true),
      _TimelineStep(
        'Clasificada',
        report.status != AbuseReportStatus.filed,
      ),
      _TimelineStep(
        'En investigacion',
        report.status == AbuseReportStatus.underInvestigation ||
            report.status == AbuseReportStatus.resolved ||
            report.status == AbuseReportStatus.closed,
      ),
      _TimelineStep(
        'Resuelta',
        report.status == AbuseReportStatus.resolved ||
            report.status == AbuseReportStatus.closed,
      ),
    ];

    return Column(
      children: List.generate(steps.length, (i) {
        final step = steps[i];
        final isLast = i == steps.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step.completed
                        ? AltruPetsTokens.success
                        : AltruPetsTokens.surfaceBorder,
                  ),
                  alignment: Alignment.center,
                  child: step.completed
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 20,
                    color: step.completed
                        ? AltruPetsTokens.success
                        : AltruPetsTokens.surfaceBorder,
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                step.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: step.completed ? FontWeight.w600 : FontWeight.normal,
                  color: step.completed
                      ? AltruPetsTokens.textPrimary
                      : AltruPetsTokens.textSecondary,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildNotFoundCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AltruPetsTokens.surfaceCard,
        borderRadius: BorderRadius.circular(AltruPetsTokens.radiusXl),
        border: Border.all(color: AltruPetsTokens.error),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 36,
            color: AltruPetsTokens.error,
          ),
          const SizedBox(height: 10),
          const Text(
            'Denuncia no encontrada',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AltruPetsTokens.error,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No se encontro una denuncia con el codigo "${_codeController.text}".\n'
            'Verifique el codigo e intente nuevamente.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AltruPetsTokens.textSecondary,
            ),
          ),
        ],
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
            width: 110,
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

  Color _statusBgColor(AbuseReportStatus status) {
    switch (status) {
      case AbuseReportStatus.filed:
        return AltruPetsTokens.errorBg;
      case AbuseReportStatus.classified:
        return AltruPetsTokens.warningBg;
      case AbuseReportStatus.underInvestigation:
        return AltruPetsTokens.infoBg;
      case AbuseReportStatus.resolved:
        return AltruPetsTokens.successBg;
      case AbuseReportStatus.closed:
        return AltruPetsTokens.surfaceCard;
    }
  }

  Color _statusTextColor(AbuseReportStatus status) {
    switch (status) {
      case AbuseReportStatus.filed:
        return AltruPetsTokens.error;
      case AbuseReportStatus.classified:
        return AltruPetsTokens.warning;
      case AbuseReportStatus.underInvestigation:
        return AltruPetsTokens.info;
      case AbuseReportStatus.resolved:
        return AltruPetsTokens.success;
      case AbuseReportStatus.closed:
        return AltruPetsTokens.textSecondary;
    }
  }
}

class _TimelineStep {
  final String label;
  final bool completed;

  const _TimelineStep(this.label, this.completed);
}
