import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:altrupets/core/widgets/molecules/foster_homes_management_card_button.dart';

@widgetbook.UseCase(name: 'Default', type: FosterHomesManagementCardButton)
Widget buildManagementCardButtonUseCase(BuildContext context) {
  return SizedBox(
    width: 120,
    height: 120,
    child: FosterHomesManagementCardButton(
      emoji: context.knobs.string(label: 'Emoji', initialValue: '🐾'),
      label: context.knobs.string(label: 'Label', initialValue: 'Mascotas'),
      onTap: () {},
    ),
  );
}
