import 'package:flutter/material.dart';
import 'package:altrupets_ui/altrupets_ui.dart';

/// Emergencias page: KPI bar (5 cards) + morning digest (mock data).
class EmergenciesPage extends StatelessWidget {
  const EmergenciesPage({super.key});

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
          Expanded(child: _buildDigest()),
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
                'Emergencias',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AltruPetsTokens.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Sistema de guardia nocturna \u00B7 Horario activo: 4pm - 7am',
                style: TextStyle(
                  fontSize: 11,
                  color: AltruPetsTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AltruPetsTokens.success,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Guardia activa \u2014 Diego R. (auxiliar)',
              style: TextStyle(
                fontSize: 11,
                color: AltruPetsTokens.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiBar() {
    return Row(
      children: [
        // ── Emergencias semanales ──
        Expanded(
          child: KpiCard(
            label: 'Emergencias esta semana',
            value: '4',
            icon: '\uD83D\uDE91',
            iconBgColor: AltruPetsTokens.errorBg,
            subtitle: '3 resueltas \u00B7 1 pendiente',
          ),
        ),
        const SizedBox(width: 10),

        // ── Tiempo respuesta ──
        Expanded(
          child: KpiCard(
            label: 'Tiempo respuesta promedio',
            value: '12min',
            valueColor: AltruPetsTokens.success,
            icon: '\u26A1',
            iconBgColor: AltruPetsTokens.successBg,
            target: 'Meta: <15 min',
            status: KpiStatus.onTarget,
          ),
        ),
        const SizedBox(width: 10),

        // ── Centinelas en guardia ──
        Expanded(
          child: KpiCard(
            label: 'Centinelas en guardia',
            value: '5',
            valueColor: AltruPetsTokens.success,
            icon: '\uD83D\uDC41\uFE0F',
            iconBgColor: AltruPetsTokens.successBg,
            target: 'Meta: >5',
            subtitle: 'Radio: 10km',
            status: KpiStatus.onTarget,
          ),
        ),
        const SizedBox(width: 10),

        // ── Auxiliares conectados ──
        Expanded(
          child: KpiCard(
            label: 'Auxiliares conectados',
            value: '3',
            valueColor: AltruPetsTokens.info,
            icon: '\uD83D\uDC65',
            iconBgColor: AltruPetsTokens.infoBg,
            target: 'Meta: >3',
            subtitle: 'Disponibles ahora',
            status: KpiStatus.onTarget,
          ),
        ),
        const SizedBox(width: 10),

        // ── Escalamientos ──
        Expanded(
          child: KpiCard(
            label: 'Escalamientos a Marcela',
            value: '0',
            valueColor: AltruPetsTokens.success,
            icon: '\uD83D\uDEE1\uFE0F',
            iconBgColor: AltruPetsTokens.successBg,
            target: 'Meta: 0',
            subtitle: 'Esta semana sin escalar',
            status: KpiStatus.onTarget,
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return FilterChipBar(
      labels: const [
        'Digest de hoy',
        'Historial',
        'Calendario guardia',
      ],
      selectedIndex: 0,
      onSelected: (_) {},
    );
  }

  Widget _buildDigest() {
    return ListView(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '\uD83D\uDCCB Resumen nocturno \u2014 7 abril 2026',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AltruPetsTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              _digestEntry(
                icon: '\u2713',
                iconColor: AltruPetsTokens.success,
                text:
                    '9:23pm \u2014 Perro herido en Barva. Diego R. respondio en 8 min. Trasladado a Vet. Santa Rosa.',
              ),
              const SizedBox(height: 4),
              _digestEntry(
                icon: '\u2713',
                iconColor: AltruPetsTokens.success,
                text:
                    '10:45pm \u2014 Gato atrapado en alcantarilla. Maria P. respondio en 14 min. Rescatado.',
              ),
              const SizedBox(height: 4),
              _digestEntry(
                icon: '\u2139',
                iconColor: AltruPetsTokens.info,
                text:
                    '11:30pm \u2014 Reporte informativo: colonia de gatos en San Pablo. Agendado para visita manana.',
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AltruPetsTokens.successBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '0 escalamientos \u2014 todo fue manejado por auxiliares',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AltruPetsTokens.success,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _digestEntry({
    required String icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          icon,
          style: TextStyle(color: iconColor, fontSize: 12),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AltruPetsTokens.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
