import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:altrupets/core/widgets/organisms/sticky_action_footer.dart';

@widgetbook.UseCase(name: 'Default', type: StickyActionFooter)
Widget buildStickyActionFooterUseCase(BuildContext context) {
  return SizedBox(
    width: 400,
    child: StickyActionFooter(
      cancelLabel: context.knobs.string(
        label: 'Cancel Label',
        initialValue: 'Cancelar',
      ),
      saveLabel: context.knobs.string(
        label: 'Save Label',
        initialValue: 'Guardar Cambios',
      ),
      onCancel: () {},
      onSave: () {},
    ),
  );
}
