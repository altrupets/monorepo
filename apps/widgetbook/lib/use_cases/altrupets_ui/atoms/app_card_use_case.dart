import 'package:altrupets_ui/altrupets_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Default',
  type: AppCard,
  path: 'altrupets_ui/[atoms]',
)
Widget buildAppCardUseCase(BuildContext context) {
  final withBorder = context.knobs.boolean(
    label: 'Con borde',
    initialValue: false,
  );
  return ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 360),
    child: AppCard(
      borderColor: withBorder
          ? context.knobs.color(
              label: 'Color de borde',
              initialValue: const Color(0xFF2B8CEE),
            )
          : null,
      onTap: context.knobs.boolean(label: 'Tappable', initialValue: true)
          ? () {}
          : null,
      child: Text(
        context.knobs.string(
          label: 'Contenido',
          initialValue: 'Contenido de la card',
        ),
      ),
    ),
  );
}
