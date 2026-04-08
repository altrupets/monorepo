import 'package:flutter/material.dart';
import 'package:altrupets_ui/altrupets_ui.dart';
import 'models/subsidy_request_model.dart';
import 'models/mock_data.dart';
import 'widgets/kpi_card.dart';
import 'widgets/subsidy_request_card.dart';
import 'widgets/subsidy_detail_modal.dart';

/// Full Desembolsos Veterinarios page: KPI bar + filter tabs + request list.
///
/// Uses MOCK DATA — GraphQL wiring is a separate follow-up ticket (Phase 6).
class DisbursementsPage extends StatefulWidget {
  const DisbursementsPage({super.key});

  @override
  State<DisbursementsPage> createState() => _DisbursementsPageState();
}

class _DisbursementsPageState extends State<DisbursementsPage> {
  int _selectedTab = 0;
  int _selectedPeriod = 0;

  static const _tabLabels = [
    'Pendientes (7)',
    'Aprobadas (9)',
    'Rechazadas (1)',
    'Historial',
  ];

  static const _periodLabels = ['Este mes', 'Trimestre', 'Anual'];

  List<SubsidyRequestModel> get _currentRequests {
    switch (_selectedTab) {
      case 0:
        return mockPendingRequests;
      case 1:
        return mockApprovedRequests;
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
          Expanded(child: _buildRequestList()),
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
                'Desembolsos Veterinarios',
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
        _buildPeriodToggle(),
      ],
    );
  }

  Widget _buildPeriodToggle() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AltruPetsTokens.surfaceCard,
        borderRadius: BorderRadius.circular(AltruPetsTokens.radiusMd),
        border: Border.all(color: AltruPetsTokens.surfaceBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_periodLabels.length, (i) {
          final isActive = _selectedPeriod == i;
          return InkWell(
            onTap: () => setState(() => _selectedPeriod = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? AltruPetsTokens.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _periodLabels[i],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive
                      ? Colors.white
                      : AltruPetsTokens.textSecondary,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildKpiBar() {
    const b = mockBudgetStatus;
    return Row(
      children: [
        Expanded(
          child: KpiCard(
            label: 'Presupuesto mensual',
            value: '\u20A1500K',
            icon: '\uD83D\uDCB0',
            iconBgColor: AltruPetsTokens.successBg,
            detail: 'Aprobado por concejo',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: KpiCard(
            label: 'Desembolsado',
            value: '\u20A1${(b.disbursed / 1000).toStringAsFixed(0)}K',
            valueColor: AltruPetsTokens.warning,
            icon: '\uD83D\uDCC9',
            iconBgColor: AltruPetsTokens.warningBg,
            detail: '${b.usagePercent.toStringAsFixed(0)}% del presupuesto',
            progressPercent: b.usagePercent,
            progressColor: AltruPetsTokens.warning,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: KpiCard(
            label: 'Disponible',
            value: '\u20A1${(b.available / 1000).toStringAsFixed(0)}K',
            valueColor: AltruPetsTokens.success,
            icon: '\u2705',
            iconBgColor: AltruPetsTokens.successBg,
            detail: '${(100 - b.usagePercent).toStringAsFixed(0)}% restante \u00B7 ${b.daysRemainingInMonth} dias',
            progressPercent: 100 - b.usagePercent,
            progressColor: AltruPetsTokens.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: KpiCard(
            label: 'Solicitudes este mes',
            value: '${b.totalRequests}',
            icon: '\uD83D\uDCCB',
            iconBgColor: AltruPetsTokens.infoBg,
            detail: '\u2191 3 vs mes anterior',
            detailColor: AltruPetsTokens.success,
            breakdown: [
              KpiBreakdownItem(
                count: b.approvedCount,
                label: 'Aprobadas',
                color: AltruPetsTokens.success,
              ),
              KpiBreakdownItem(
                count: b.inReviewCount,
                label: 'En revision',
                color: AltruPetsTokens.info,
              ),
              KpiBreakdownItem(
                count: b.rejectedCount,
                label: 'Rechazada',
                color: AltruPetsTokens.error,
              ),
            ],
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

  Widget _buildRequestList() {
    final requests = _currentRequests;

    if (requests.isEmpty) {
      return const AppEmptyState(
        icon: Icons.inbox_outlined,
        title: 'Sin solicitudes',
        subtitle: 'No hay solicitudes en esta categoria.',
      );
    }

    return ListView.separated(
      itemCount: requests.length,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final request = requests[index];
        return SubsidyRequestCard(
          request: request,
          onTap: () => SubsidyDetailModal.show(context, request),
          onAction: () => SubsidyDetailModal.show(context, request),
        );
      },
    );
  }
}
