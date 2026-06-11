import 'package:altrupets_ui/altrupets_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Default',
  type: SectionHeader,
  path: 'altrupets_ui/[molecules]',
)
Widget buildAltrupetsUiSectionHeaderUseCase(BuildContext context) {
  return SectionHeader(
    title: context.knobs.string(
      label: 'Título',
      initialValue: 'Hogares de paso',
    ),
    trailing: context.knobs.boolean(label: 'Con trailing', initialValue: true)
        ? TextButton(onPressed: () {}, child: const Text('Ver todos'))
        : null,
  );
}
