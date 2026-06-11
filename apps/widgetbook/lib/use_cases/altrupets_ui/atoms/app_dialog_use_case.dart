import 'package:altrupets_ui/altrupets_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Default',
  type: AppDialog,
  path: 'altrupets_ui/[atoms]',
)
Widget buildAppDialogUseCase(BuildContext context) {
  return AppDialog(
    title: context.knobs.string(
      label: 'Título',
      initialValue: 'Confirmar rescate',
    ),
    subtitle: context.knobs.stringOrNull(
      label: 'Subtítulo',
      initialValue: 'Esta acción notificará al hogar de paso',
    ),
    maxWidth: context.knobs.double.slider(
      label: 'Max width',
      initialValue: 520,
      min: 280,
      max: 720,
    ),
    body: const Text('¿Querés confirmar el rescate de este animal?'),
    actions: [
      TextButton(onPressed: () {}, child: const Text('Cancelar')),
      FilledButton(onPressed: () {}, child: const Text('Confirmar')),
    ],
  );
}
