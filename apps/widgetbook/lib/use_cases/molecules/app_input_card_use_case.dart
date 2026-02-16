import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:altrupets/core/widgets/molecules/app_input_card.dart';

@widgetbook.UseCase(name: 'Default', type: AppInputCard)
Widget buildAppInputCardUseCase(BuildContext context) {
  return SizedBox(
    width: 360,
    child: AppInputCard(
      label: context.knobs.string(
        label: 'Label',
        initialValue: 'NOMBRE COMPLETO',
      ),
      initialValue: context.knobs.string(
        label: 'Initial Value',
        initialValue: 'Carlos Martínez',
      ),
      hint: context.knobs.string(
        label: 'Hint',
        initialValue: 'Ingresa tu nombre',
      ),
      enabled: context.knobs.boolean(
        label: 'Enabled',
        initialValue: true,
      ),
      isDropdown: context.knobs.boolean(
        label: 'Is Dropdown',
        initialValue: false,
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Disabled', type: AppInputCard)
Widget buildAppInputCardDisabledUseCase(BuildContext context) {
  return const SizedBox(
    width: 360,
    child: AppInputCard(
      label: 'CORREO ELECTRÓNICO',
      initialValue: 'carlos@email.com',
      hint: 'Ingresa tu correo',
      enabled: false,
    ),
  );
}

@widgetbook.UseCase(name: 'Dropdown', type: AppInputCard)
Widget buildAppInputCardDropdownUseCase(BuildContext context) {
  return const SizedBox(
    width: 360,
    child: AppInputCard(
      label: 'CIUDAD',
      initialValue: 'Ciudad de México',
      hint: 'Selecciona tu ciudad',
      isDropdown: true,
    ),
  );
}
