import 'package:flutter/material.dart';
import 'package:altrupets_ui/altrupets_ui.dart';

/// Denuncias de Maltrato page: KPI bar + complaint list (mock data).
class ComplaintsPage extends StatelessWidget {
  const ComplaintsPage({super.key});

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
          Expanded(child: _buildComplaintList()),
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
                'Denuncias de Maltrato',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AltruPetsTokens.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '2 pendientes \u00B7 8 en investigacion \u00B7 Canton de Heredia',
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
        // ── Denuncias recibidas ──
        Expanded(
          child: KpiCard(
            label: 'Denuncias recibidas',
            value: '23',
            icon: '\uD83D\uDEA8',
            iconBgColor: AltruPetsTokens.errorBg,
            subtitle: 'Este mes',
          ),
        ),
        const SizedBox(width: 10),

        // ── Tiempo promedio respuesta (CRITICAL from ALT-62) ──
        Expanded(
          child: KpiCard(
            label: 'Tiempo promedio respuesta',
            value: '4.2h',
            icon: '\u23F1\uFE0F',
            iconBgColor: AltruPetsTokens.warningBg,
            target: 'Meta: <2h',
            trend: '\u2193 2h vs mes anterior',
            trendColor: AltruPetsTokens.success,
            status: KpiStatus.critical,
          ),
        ),
        const SizedBox(width: 10),

        // ── Casos resueltos ──
        Expanded(
          child: KpiCard(
            label: 'Casos resueltos',
            value: '13',
            valueColor: AltruPetsTokens.success,
            icon: '\u2705',
            iconBgColor: AltruPetsTokens.successBg,
            target: 'Meta: >80%',
            subtitle: '57% tasa de resolucion',
            progress: 13 / 23,
            progressColor: AltruPetsTokens.success,
            status: KpiStatus.critical,
          ),
        ),
        const SizedBox(width: 10),

        // ── Visitas programadas ──
        Expanded(
          child: KpiCard(
            label: 'Visitas programadas',
            value: '5',
            valueColor: AltruPetsTokens.info,
            icon: '\uD83D\uDDD3\uFE0F',
            iconBgColor: AltruPetsTokens.infoBg,
            subtitle: 'Proxima: manana 9am',
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return FilterChipBar(
      labels: const [
        'Nuevas (2)',
        'En investigacion (8)',
        'Resueltas (13)',
        'Mapa',
      ],
      selectedIndex: 0,
      onSelected: (_) {},
    );
  }

  Widget _buildComplaintList() {
    return ListView(
      children: [
        _complaintCard(
          emoji: '\u26A0\uFE0F',
          emojiBg: AltruPetsTokens.errorBg,
          title: 'Perros encadenados sin agua \u2014 Barrio Fatima',
          meta: 'Reportado por Andrea M. \u00B7 Hace 45 min \u00B7 GPS adjunto \u00B7 3 fotos',
          statusLabel: 'Requiere clasificacion',
          statusColor: AltruPetsTokens.error,
          statusBg: AltruPetsTokens.errorBg,
          actionLabel: 'Clasificar \u2192',
          actionColor: AltruPetsTokens.error,
        ),
        const SizedBox(height: 6),
        _complaintCard(
          emoji: '\u26A0\uFE0F',
          emojiBg: AltruPetsTokens.warningBg,
          title: 'Gato herido abandonado \u2014 Mercedes Norte',
          meta: 'Reportado por Carlos V. \u00B7 Hace 2h \u00B7 GPS adjunto \u00B7 1 foto',
          statusLabel: 'Requiere clasificacion',
          statusColor: AltruPetsTokens.warning,
          statusBg: AltruPetsTokens.warningBg,
          actionLabel: 'Clasificar \u2192',
          actionColor: AltruPetsTokens.warning,
        ),
      ],
    );
  }

  Widget _complaintCard({
    required String emoji,
    required Color emojiBg,
    required String title,
    required String meta,
    required String statusLabel,
    required Color statusColor,
    required Color statusBg,
    required String actionLabel,
    required Color actionColor,
  }) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: emojiBg,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AltruPetsTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  meta,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AltruPetsTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: statusBg,
              border: Border.all(color: actionColor),
            ),
            child: Text(
              actionLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: actionColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
