import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:altrupets/core/widgets/molecules/app_service_card.dart';

@widgetbook.UseCase(name: 'Default', type: AppServiceCard)
Widget buildAppServiceCardUseCase(BuildContext context) {
  return SizedBox(
    width: 360,
    child: AppServiceCard(
      title: context.knobs.string(
        label: 'Title',
        initialValue: 'Rescates',
      ),
      subtitle: context.knobs.string(
        label: 'Subtitle',
        initialValue: 'Reporta y gestiona rescates',
      ),
      icon: Icons.pets_rounded,
      gradientColors: const [Color(0xFF2563EB), Color(0xFF7C3AED)],
      onTap: () {},
    ),
  );
}

@widgetbook.UseCase(name: 'Warm Gradient', type: AppServiceCard)
Widget buildAppServiceCardWarmUseCase(BuildContext context) {
  return SizedBox(
    width: 360,
    child: AppServiceCard(
      title: 'Adopciones',
      subtitle: 'Encuentra un compañero',
      icon: Icons.favorite_rounded,
      gradientColors: const [Color(0xFFEA580C), Color(0xFFDB2777)],
      onTap: () {},
    ),
  );
}
