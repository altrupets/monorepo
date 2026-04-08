import 'package:flutter/material.dart';
import 'package:altrupets_ui/altrupets_ui.dart';
import 'models/abuse_report_model.dart';
import 'models/mock_data.dart';
import 'widgets/complaint_card.dart';
import 'widgets/classify_modal.dart';

/// Denuncias de Maltrato page: KPI bar + filter tabs + complaint list.
///
/// Uses MOCK DATA — GraphQL wiring is a separate follow-up ticket.
class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({super.key});

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  int _selectedTab = 0;

  List<String> get _tabLabels => [
        'Nuevas (${mockComplaintMetrics.pendingClassification})',
        'En investigacion (${mockComplaintMetrics.underInvestigation})',
        'Resueltas (${mockComplaintMetrics.resolved})',
        'Mapa',
      ];

  List<AbuseReportModel> get _currentReports {
    switch (_selectedTab) {
      case 0:
        return mockFiledReports;
      case 1:
        return mockInvestigationReports;
      case 2:
        return mockResolvedReports;
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AltruPetsTokens.surfaceContent,
      padding: const EdgeInsets.all(AltruPetsTokens.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 14),
          _buildKpiBar(),
          const SizedBox(height: 16),
          _buildFilterTabs(),
          const SizedBox(height: 12),
          Expanded(
            child: _selectedTab == 3
                ? _buildMapPlaceholder()
                : _buildComplaintList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final m = mockComplaintMetrics;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Denuncias de Maltrato',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AltruPetsTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${m.pendingClassification} pendientes \u00B7 ${m.underInvestigation} en investigacion \u00B7 Canton de Heredia',
                style: const TextStyle(
                  fontSize: 11,
                  color: AltruPetsTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: AltruPetsTokens.surfaceCard,
            borderRadius: BorderRadius.circular(AltruPetsTokens.radiusMd),
            border: Border.all(color: AltruPetsTokens.surfaceBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _toggleBtn('Este mes', true),
              _toggleBtn('Trimestre', false),
              _toggleBtn('Anual', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _toggleBtn(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AltruPetsTokens.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          color: isActive ? Colors.white : AltruPetsTokens.textSecondary,
        ),
      ),
    );
  }

  Widget _buildKpiBar() {
    const m = mockComplaintMetrics;
    return Row(
      children: [
        // Denuncias recibidas
        Expanded(
          child: KpiCard(
            label: 'Denuncias recibidas',
            value: '${m.totalReports}',
            icon: '\uD83D\uDEA8',
            iconBgColor: AltruPetsTokens.errorBg,
            subtitle: 'Este mes',
          ),
        ),
        const SizedBox(width: 10),

        // Tiempo promedio respuesta (CRITICAL from ALT-62)
        Expanded(
          child: KpiCard(
            label: 'Tiempo promedio respuesta',
            value: m.formattedResponseTime,
            icon: '\u23F1\uFE0F',
            iconBgColor: AltruPetsTokens.warningBg,
            target: 'Meta: <2h',
            trend: '\u2193 2h vs mes anterior',
            trendColor: AltruPetsTokens.success,
            status: KpiStatus.critical,
          ),
        ),
        const SizedBox(width: 10),

        // Casos resueltos
        Expanded(
          child: KpiCard(
            label: 'Casos resueltos',
            value: '${m.resolved}',
            valueColor: AltruPetsTokens.success,
            icon: '\u2705',
            iconBgColor: AltruPetsTokens.successBg,
            target: 'Meta: >80%',
            subtitle: '${m.formattedResolutionRate} tasa de resolucion',
            progress: m.resolutionRate,
            progressColor: AltruPetsTokens.success,
            status: KpiStatus.critical,
          ),
        ),
        const SizedBox(width: 10),

        // Visitas programadas
        Expanded(
          child: KpiCard(
            label: 'Visitas programadas',
            value: '${m.scheduledVisits}',
            valueColor: AltruPetsTokens.info,
            icon: '\uD83D\uDDD3\uFE0F',
            iconBgColor: AltruPetsTokens.infoBg,
            subtitle: 'Proxima: manana 9am',
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return FilterChipBar(
      labels: _tabLabels,
      selectedIndex: _selectedTab,
      onSelected: (i) => setState(() => _selectedTab = i),
    );
  }

  Widget _buildComplaintList() {
    final reports = _currentReports;

    if (reports.isEmpty) {
      return const AppEmptyState(
        icon: Icons.assignment_outlined,
        title: 'Sin denuncias',
        subtitle: 'No hay denuncias en esta categoria.',
      );
    }

    return ListView.separated(
      itemCount: reports.length,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final report = reports[index];
        return ComplaintCard(
          report: report,
          onClassify: () => ClassifyModal.show(context, report),
          onTap: () => ClassifyModal.show(context, report),
        );
      },
    );
  }

  Widget _buildMapPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_outlined,
            size: 48,
            color: AltruPetsTokens.textSecondary,
          ),
          const SizedBox(height: 12),
          const Text(
            'Mapa de denuncias',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AltruPetsTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Vista de mapa con ubicaciones GPS de las denuncias.\nProximo: integracion con Google Maps.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: AltruPetsTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
