import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:altrupets/core/widgets/molecules/app_nav_item.dart';

@widgetbook.UseCase(name: 'Selected', type: AppNavItem)
Widget buildAppNavItemSelectedUseCase(BuildContext context) {
  return AppNavItem(
    icon: Icons.home_rounded,
    label: context.knobs.string(
      label: 'Label',
      initialValue: 'Inicio',
    ),
    isSelected: context.knobs.boolean(
      label: 'Is Selected',
      initialValue: true,
    ),
    onTap: () {},
  );
}

@widgetbook.UseCase(name: 'Unselected', type: AppNavItem)
Widget buildAppNavItemUnselectedUseCase(BuildContext context) {
  return AppNavItem(
    icon: Icons.person_outline_rounded,
    label: 'Perfil',
    isSelected: false,
    onTap: () {},
  );
}
