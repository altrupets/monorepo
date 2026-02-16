import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:altrupets/core/widgets/organisms/main_navigation_bar.dart';

@widgetbook.UseCase(name: 'Default', type: MainNavigationBar)
Widget buildMainNavigationBarUseCase(BuildContext context) {
  return SizedBox(
    width: 420,
    child: MainNavigationBar(
      currentIndex: context.knobs.int.slider(
        label: 'Current Index',
        initialValue: 2,
        min: 0,
        max: 4,
      ),
      onTap: (_) {},
    ),
  );
}
