import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:altrupets/core/widgets/molecules/foster_home_header_card.dart';

@widgetbook.UseCase(name: 'Default', type: FosterHomeHeaderCard)
Widget buildFosterHomeHeaderCardUseCase(BuildContext context) {
  return SizedBox(
    width: 360,
    child: FosterHomeHeaderCard(
      name: context.knobs.string(
        label: 'Name',
        initialValue: 'Hogar AltruPets',
      ),
      location: context.knobs.string(
        label: 'Location',
        initialValue: 'Ciudad de México, CDMX',
      ),
    ),
  );
}
