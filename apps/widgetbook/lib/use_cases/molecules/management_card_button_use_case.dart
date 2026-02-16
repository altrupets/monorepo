import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:altrupets/core/widgets/molecules/management_card_button.dart';

@widgetbook.UseCase(name: 'Default', type: ManagementCardButton)
Widget buildManagementCardButtonUseCase(BuildContext context) {
  return SizedBox(
    width: 120,
    height: 120,
    child: ManagementCardButton(
      emoji: context.knobs.string(
        label: 'Emoji',
        initialValue: '🐾',
      ),
      label: context.knobs.string(
        label: 'Label',
        initialValue: 'Mascotas',
      ),
      onTap: () {},
    ),
  );
}
