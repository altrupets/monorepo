import 'package:altrupets_ui/altrupets_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Default',
  type: AppEmptyState,
  path: 'altrupets_ui/[atoms]',
)
Widget buildAppEmptyStateUseCase(BuildContext context) {
  return AppEmptyState(
    icon: Icons.pets,
    title: context.knobs.string(
      label: 'Título',
      initialValue: 'Sin rescates activos',
    ),
    subtitle: context.knobs.stringOrNull(
      label: 'Subtítulo',
      initialValue: 'Cuando reportes un rescate aparecerá acá',
    ),
  );
}
