import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:altrupets/core/widgets/atoms/app_accent_bar.dart';

@widgetbook.UseCase(name: 'Default', type: AppAccentBar)
Widget buildAppAccentBarUseCase(BuildContext context) {
  return AppAccentBar(
    color: context.knobs.color(
      label: 'Color',
      initialValue: const Color(0xFF2B8CEE),
    ),
    width: context.knobs.double.slider(
      label: 'Width',
      initialValue: 4,
      min: 2,
      max: 16,
    ),
    height: context.knobs.double.slider(
      label: 'Height',
      initialValue: 18,
      min: 8,
      max: 40,
    ),
  );
}
