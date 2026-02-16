import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:altrupets/core/widgets/atoms/app_circular_button.dart';

@widgetbook.UseCase(name: 'Default', type: AppCircularButton)
Widget buildAppCircularButtonUseCase(BuildContext context) {
  return AppCircularButton(
    icon: Icons.add,
    onTap: () {},
    size: context.knobs.double.slider(
      label: 'Size',
      initialValue: 56,
      min: 32,
      max: 80,
    ),
    iconColor: context.knobs.color(
      label: 'Icon Color',
      initialValue: Colors.white,
    ),
    iconSize: context.knobs.double.slider(
      label: 'Icon Size',
      initialValue: 24,
      min: 16,
      max: 40,
    ),
  );
}

@widgetbook.UseCase(name: 'With Gradient', type: AppCircularButton)
Widget buildAppCircularButtonGradientUseCase(BuildContext context) {
  return AppCircularButton(
    icon: Icons.home_rounded,
    onTap: () {},
    size: 56,
    iconSize: 30,
    gradient: LinearGradient(
      colors: [
        Theme.of(context).colorScheme.secondary,
        Theme.of(context).colorScheme.primary,
      ],
    ),
    boxShadow: [
      BoxShadow(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
