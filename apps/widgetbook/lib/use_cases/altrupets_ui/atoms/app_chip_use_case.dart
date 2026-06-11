import 'package:altrupets_ui/altrupets_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Default',
  type: AppChip,
  path: 'altrupets_ui/[atoms]',
)
Widget buildAppChipUseCase(BuildContext context) {
  return AppChip(
    label: context.knobs.string(
      label: 'Label',
      initialValue: 'En revisión',
    ),
    backgroundColor: context.knobs.colorOrNull(
      label: 'Background',
      initialValue: const Color(0xFFE3F2FD),
    ),
    textColor: context.knobs.colorOrNull(
      label: 'Texto',
      initialValue: const Color(0xFF1565C0),
    ),
  );
}
