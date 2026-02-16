import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:altrupets/core/widgets/molecules/profile_menu_option.dart';

@widgetbook.UseCase(name: 'Default', type: ProfileMenuOption)
Widget buildProfileMenuOptionUseCase(BuildContext context) {
  return SizedBox(
    width: 120,
    height: 120,
    child: ProfileMenuOption(
      icon: Icons.edit_rounded,
      label: context.knobs.string(
        label: 'Label',
        initialValue: 'Editar Perfil',
      ),
      iconColor: context.knobs.color(
        label: 'Icon Color',
        initialValue: const Color(0xFF2563EB),
      ),
      onTap: () {},
    ),
  );
}
