import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:altrupets/core/widgets/organisms/profile_header.dart';

@widgetbook.UseCase(name: 'Default', type: ProfileHeader)
Widget buildProfileHeaderUseCase(BuildContext context) {
  return SizedBox(
    width: 400,
    child: ProfileHeader(
      title: context.knobs.string(
        label: 'Title',
        initialValue: 'Mi Perfil',
      ),
      imageUrl: context.knobs.string(
        label: 'Image URL',
        initialValue: 'https://i.pravatar.cc/150?img=3',
      ),
      onBackTap: () {},
      onCameraTap: () {},
    ),
  );
}
