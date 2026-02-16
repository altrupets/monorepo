import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:altrupets/core/widgets/organisms/profile_main_header.dart';

@widgetbook.UseCase(name: 'Default', type: ProfileMainHeader)
Widget buildProfileMainHeaderUseCase(BuildContext context) {
  return SizedBox(
    width: 400,
    child: ProfileMainHeader(
      name: context.knobs.string(
        label: 'Name',
        initialValue: 'Carlos Martínez',
      ),
      location: context.knobs.string(
        label: 'Location',
        initialValue: 'Ciudad de México',
      ),
      role: context.knobs.string(
        label: 'Role',
        initialValue: 'Rescatista',
      ),
      imageUrl: context.knobs.string(
        label: 'Image URL',
        initialValue: 'https://i.pravatar.cc/150?img=3',
      ),
    ),
  );
}
