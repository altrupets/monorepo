import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:altrupets/core/widgets/molecules/home_welcome_header.dart';

@widgetbook.UseCase(name: 'Default', type: HomeWelcomeHeader)
Widget buildHomeWelcomeHeaderUseCase(BuildContext context) {
  return Container(
    width: 400,
    color: const Color(0xFF0F172A),
    child: HomeWelcomeHeader(
      onNotificationTap: () {},
    ),
  );
}
