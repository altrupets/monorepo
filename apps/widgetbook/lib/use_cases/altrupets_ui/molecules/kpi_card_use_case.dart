import 'package:altrupets_ui/altrupets_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Default',
  type: KpiCard,
  path: 'altrupets_ui/[molecules]',
)
Widget buildKpiCardUseCase(BuildContext context) {
  return ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 320),
    child: KpiCard(
      label: context.knobs.string(
        label: 'Label',
        initialValue: 'Rescates del mes',
      ),
      value: context.knobs.string(
        label: 'Valor',
        initialValue: '42',
      ),
      target: context.knobs.stringOrNull(
        label: 'Meta',
        initialValue: 'Meta: 50',
      ),
      trend: context.knobs.stringOrNull(
        label: 'Tendencia',
        initialValue: '+12% vs. mes anterior',
      ),
      progress: context.knobs.doubleOrNull.slider(
        label: 'Progreso',
        initialValue: 0.84,
        min: 0,
        max: 1,
      ),
      icon: context.knobs.string(
        label: 'Ícono (emoji)',
        initialValue: '🐾',
      ),
      iconBgColor: context.knobs.color(
        label: 'Fondo del ícono',
        initialValue: const Color(0xFFE3F2FD),
      ),
      status: context.knobs.objectOrNull.dropdown(
        label: 'Status (semáforo)',
        options: KpiStatus.values,
        labelBuilder: (status) => status.name,
        initialOption: KpiStatus.onTarget,
      ),
      breakdown: KpiBreakdownRow(
        items: const [
          KpiBreakdownItem(count: 28, label: 'perros', color: Color(0xFF4CAF50)),
          KpiBreakdownItem(count: 14, label: 'gatos', color: Color(0xFFFF9800)),
        ],
      ),
    ),
  );
}
