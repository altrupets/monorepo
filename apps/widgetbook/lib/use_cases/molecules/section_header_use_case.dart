import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:altrupets/core/widgets/molecules/section_header.dart';

@widgetbook.UseCase(name: 'Default', type: SectionHeader)
Widget buildSectionHeaderUseCase(BuildContext context) {
  return SectionHeader(
    title: context.knobs.string(
      label: 'Title',
      initialValue: 'SERVICIOS',
    ),
    color: context.knobs.color(
      label: 'Color',
      initialValue: const Color(0xFF2B8CEE),
    ),
  );
}
