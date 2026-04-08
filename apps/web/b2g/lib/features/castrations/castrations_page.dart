import 'package:flutter/material.dart';
import 'package:altrupets_ui/altrupets_ui.dart';

/// Campanas de Castracion page: KPI bar + campaign list (mock data).
class CastrationsPage extends StatelessWidget {
  const CastrationsPage({super.key});

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
          _buildTabs(),
          const SizedBox(height: 12),
          Expanded(child: _buildCampaignList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Campanas de Castracion',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AltruPetsTokens.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '3 campanas activas \u00B7 Proxima: 15 abril, San Rafael',
                style: TextStyle(
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
    return Row(
      children: [
        Expanded(
          child: KpiCard(
            label: 'Animales esterilizados',
            value: '127',
            valueColor: AltruPetsTokens.success,
            icon: '\u2702\uFE0F',
            iconBgColor: AltruPetsTokens.successBg,
            target: 'Meta: 150/trimestre',
            trend: '\u2191 18% vs trimestre anterior',
            trendColor: AltruPetsTokens.success,
            status: KpiStatus.warning,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: KpiCard(
            label: 'Costo promedio/animal',
            value: '\u20A135K',
            icon: '\uD83D\uDCB2',
            iconBgColor: AltruPetsTokens.warningBg,
            target: 'Meta: <\u20A140K',
            subtitle: 'Perro: \u20A142K \u00B7 Gato: \u20A128K',
            status: KpiStatus.onTarget,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: KpiCard(
            label: 'Comunidades cubiertas',
            value: '8',
            valueColor: AltruPetsTokens.info,
            icon: '\uD83D\uDCCD',
            iconBgColor: AltruPetsTokens.infoBg,
            target: 'Meta: 14/14 distritos',
            subtitle: 'de 14 distritos del canton',
            progress: 8 / 14,
            progressColor: AltruPetsTokens.info,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: KpiCard(
            label: 'Proxima campana',
            value: '7d',
            valueColor: AltruPetsTokens.warning,
            icon: '\uD83D\uDCC5',
            iconBgColor: AltruPetsTokens.warningBg,
            subtitle: 'San Rafael \u00B7 28/40 inscritos',
            progress: 28 / 40,
            progressColor: AltruPetsTokens.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return FilterChipBar(
      labels: const [
        'Activas (3)',
        'Completadas (5)',
        'Borradores',
        'Metricas',
      ],
      selectedIndex: 0,
      onSelected: (_) {},
    );
  }

  Widget _buildCampaignList() {
    return ListView(
      children: [
        _campaignCard(
          status: 'INSCRIPCION ABIERTA',
          statusColor: AltruPetsTokens.success,
          statusBg: AltruPetsTokens.successBg,
          code: 'CAM-2026-003',
          title: 'Castracion San Rafael de Heredia',
          detail: '15 abril \u00B7 Salon Comunal \u00B7 Cap: 40 animales',
          enrolled: 28,
          capacity: 40,
          currentStep: 3,
        ),
      ],
    );
  }

  Widget _campaignCard({
    required String status,
    required Color statusColor,
    required Color statusBg,
    required String code,
    required String title,
    required String detail,
    required int enrolled,
    required int capacity,
    required int currentStep,
  }) {
    const steps = ['Planif.', 'Promo', 'Inscripcion', 'Cirugia', 'Seguimiento'];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          code,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AltruPetsTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AltruPetsTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      detail,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AltruPetsTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    '$enrolled/$capacity',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AltruPetsTokens.textPrimary,
                    ),
                  ),
                  const Text(
                    'inscritos',
                    style: TextStyle(
                      fontSize: 10,
                      color: AltruPetsTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Stepper
          Row(
            children: [
              for (int i = 0; i < steps.length; i++) ...[
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i < currentStep
                          ? AltruPetsTokens.success
                          : AltruPetsTokens.surfaceBorder,
                    ),
                  ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < currentStep - 1
                        ? AltruPetsTokens.success
                        : i == currentStep - 1
                            ? AltruPetsTokens.info
                            : AltruPetsTokens.surfaceBorder,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    i < currentStep - 1 ? '\u2713' : '${i + 1}',
                    style: TextStyle(
                      fontSize: 10,
                      color: i < currentStep
                          ? Colors.white
                          : AltruPetsTokens.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: steps.asMap().entries.map((e) {
              final i = e.key;
              final label = e.value;
              return Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight:
                      i == currentStep - 1 ? FontWeight.w600 : FontWeight.normal,
                  color: i == currentStep - 1
                      ? AltruPetsTokens.info
                      : AltruPetsTokens.textSecondary,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
