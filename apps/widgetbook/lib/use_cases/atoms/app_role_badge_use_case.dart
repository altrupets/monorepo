import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:altrupets/core/widgets/atoms/app_role_badge.dart';

@widgetbook.UseCase(name: 'Default', type: AppRoleBadge)
Widget buildAppRoleBadgeUseCase(BuildContext context) {
  return AppRoleBadge(
    label: context.knobs.string(
      label: 'Label',
      initialValue: 'RESCATISTA',
    ),
    color: context.knobs.color(
      label: 'Color',
      initialValue: const Color(0xFFEC5B13),
    ),
  );
}
