import 'package:flutter/material.dart';
import 'package:altrupets_ui/altrupets_ui.dart';
import '../disbursements/widgets/kpi_card.dart';
import 'models/campaign_model.dart';
import 'models/mock_data.dart';
import 'widgets/campaign_card.dart';
import 'widgets/campaign_detail_modal.dart';

/// Full Campanas de Castracion page: KPI bar + filter tabs + campaign list.
///
/// Uses MOCK DATA — GraphQL wiring is a separate follow-up ticket (Phase 6).
class CampaignsPage extends StatefulWidget {
  const CampaignsPage({super.key});

  @override
  State<CampaignsPage> createState() => _CampaignsPageState();
}

class _CampaignsPageState extends State<CampaignsPage> {
  int _selectedTab = 0;

  static const _tabLabels = [
    'Activas',
    'Completadas',
    'Borradores',
    'Metricas',
  ];

  List<CampaignModel> get _currentCampaigns {
    switch (_selectedTab) {
      case 0:
        return mockActiveCampaigns;
      case 1:
        return mockCompletedCampaigns;
      case 2:
        return mockDraftCampaigns;
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
                ? _buildMetricsView()
                : _buildCampaignList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Campanas de Castracion',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AltruPetsTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Municipalidad de Heredia \u00B7 Abril 2026',
                style: TextStyle(
                  fontSize: 11,
                  color: AltruPetsTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Nueva campana'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AltruPetsTokens.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiBar() {
    const m = mockCampaignMetrics;
    return Row(
      children: [
        Expanded(
          child: KpiCard(
            label: 'Animales esterilizados',
            value: '${m.totalSterilized}',
            valueColor: AltruPetsTokens.success,
            icon: '\uD83D\uDC3E', // paw
            iconBgColor: AltruPetsTokens.successBg,
            detail: '\u2191 12% vs trimestre anterior',
            detailColor: AltruPetsTokens.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: KpiCard(
            label: 'Costo promedio/animal',
            value: m.formattedAvgCost,
            icon: '\uD83D\uDCB0', // money bag
            iconBgColor: AltruPetsTokens.warningBg,
            detail: 'Presupuesto actual',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: KpiCard(
            label: 'Comunidades cubiertas',
            value: '${m.communitiesCovered}/${m.communitiesTotal}',
            icon: '\uD83C\uDFE0', // house
            iconBgColor: AltruPetsTokens.infoBg,
            detail: '${((m.communitiesCovered / m.communitiesTotal) * 100).toStringAsFixed(0)}% cobertura',
            progressPercent: (m.communitiesCovered / m.communitiesTotal) * 100,
            progressColor: AltruPetsTokens.info,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: KpiCard(
            label: 'Proxima campana',
            value: '${m.daysUntilNextCampaign}d',
            icon: '\uD83D\uDCC5', // calendar
            iconBgColor: AltruPetsTokens.infoBg,
            detail: 'San Rafael de Heredia',
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

  Widget _buildCampaignList() {
    final campaigns = _currentCampaigns;

    if (campaigns.isEmpty) {
      return const AppEmptyState(
        icon: Icons.event_busy_outlined,
        title: 'Sin campanas',
        subtitle: 'No hay campanas en esta categoria.',
      );
    }

    return ListView.separated(
      itemCount: campaigns.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final campaign = campaigns[index];
        return CampaignCard(
          campaign: campaign,
          onTap: () => CampaignDetailModal.show(context, campaign),
        );
      },
    );
  }

  Widget _buildMetricsView() {
    const m = mockCampaignMetrics;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Resumen general'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _metricBox(
                  '${m.totalCampaigns}',
                  'Total campanas',
                  AltruPetsTokens.textPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricBox(
                  '${m.activeCampaigns}',
                  'Activas',
                  AltruPetsTokens.info,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricBox(
                  '${m.completedCampaigns}',
                  'Completadas',
                  AltruPetsTokens.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _sectionTitle('Esterilizaciones por comunidad'),
          const SizedBox(height: 12),
          _communityRow('San Rafael de Heredia', 0, 40, true),
          _communityRow('Barrio Fatima', 35, 40, false),
          _communityRow('Mercedes Norte', 0, 50, true),
          _communityRow('Barva Centro', 22, 30, false),
          _communityRow('San Pablo', 18, 25, false),
          _communityRow('San Isidro', 15, 30, false),
          _communityRow('Santa Lucia', 20, 35, false),
          _communityRow('San Joaquin', 17, 25, false),
          const SizedBox(height: 20),
          _sectionTitle('Eficiencia presupuestaria'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AltruPetsTokens.surfaceCard,
              borderRadius: BorderRadius.circular(AltruPetsTokens.radiusMd),
              border: Border.all(color: AltruPetsTokens.surfaceBorder),
            ),
            child: Column(
              children: [
                _metricLine('Presupuesto total asignado', '\u20A14,550K'),
                _metricLine('Presupuesto ejecutado', '\u20A11,225K'),
                _metricLine('Ejecucion presupuestaria', '26.9%'),
                _metricLine('Costo promedio por esterilizacion', m.formattedAvgCost),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricBox(String value, String label, Color color) {
    return AppCard(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AltruPetsTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _communityRow(String name, int done, int target, bool isActive) {
    final percent = target > 0 ? (done / target * 100) : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: AltruPetsTokens.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: AltruPetsTokens.surfaceBorder,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (percent / 100).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isActive
                        ? AltruPetsTokens.info
                        : AltruPetsTokens.success,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: Text(
              '$done/$target',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AltruPetsTokens.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AltruPetsTokens.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AltruPetsTokens.textPrimary,
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
}
