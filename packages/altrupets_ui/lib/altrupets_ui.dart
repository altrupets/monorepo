/// Shared AltruPets UI package — Atomic Design widgets and unified theme.
library;

// Theme
export 'src/theme/altrupets_theme.dart';
export 'src/theme/altrupets_tokens.dart';

// Shared-core backend selector + token model (material/fluent).
export 'package:shared_ui_core/shared_ui_core.dart'
    show UiBackend, ChimeranextUi, TokensReader, DesignTokenModel;

// Atoms
export 'src/atoms/app_card.dart';
export 'src/atoms/app_chip.dart';
export 'src/atoms/app_dialog.dart';
export 'src/atoms/app_empty_state.dart';

// Molecules
export 'src/molecules/kpi_card.dart';
export 'src/molecules/section_header.dart';
export 'src/molecules/filter_chip_bar.dart';
