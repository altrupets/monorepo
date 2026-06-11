// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:widgetbook/widgetbook.dart' as _widgetbook;
import 'package:widgetbook_workspace/use_cases/altrupets_ui/atoms/app_card_use_case.dart'
    as _widgetbook_workspace_use_cases_altrupets_ui_atoms_app_card_use_case;
import 'package:widgetbook_workspace/use_cases/altrupets_ui/atoms/app_chip_use_case.dart'
    as _widgetbook_workspace_use_cases_altrupets_ui_atoms_app_chip_use_case;
import 'package:widgetbook_workspace/use_cases/altrupets_ui/atoms/app_dialog_use_case.dart'
    as _widgetbook_workspace_use_cases_altrupets_ui_atoms_app_dialog_use_case;
import 'package:widgetbook_workspace/use_cases/altrupets_ui/atoms/app_empty_state_use_case.dart'
    as _widgetbook_workspace_use_cases_altrupets_ui_atoms_app_empty_state_use_case;
import 'package:widgetbook_workspace/use_cases/altrupets_ui/molecules/filter_chip_bar_use_case.dart'
    as _widgetbook_workspace_use_cases_altrupets_ui_molecules_filter_chip_bar_use_case;
import 'package:widgetbook_workspace/use_cases/altrupets_ui/molecules/kpi_card_use_case.dart'
    as _widgetbook_workspace_use_cases_altrupets_ui_molecules_kpi_card_use_case;
import 'package:widgetbook_workspace/use_cases/altrupets_ui/molecules/section_header_use_case.dart'
    as _widgetbook_workspace_use_cases_altrupets_ui_molecules_section_header_use_case;
import 'package:widgetbook_workspace/use_cases/atoms/app_accent_bar_use_case.dart'
    as _widgetbook_workspace_use_cases_atoms_app_accent_bar_use_case;
import 'package:widgetbook_workspace/use_cases/atoms/app_circular_button_use_case.dart'
    as _widgetbook_workspace_use_cases_atoms_app_circular_button_use_case;
import 'package:widgetbook_workspace/use_cases/molecules/foster_home_header_card_use_case.dart'
    as _widgetbook_workspace_use_cases_molecules_foster_home_header_card_use_case;
import 'package:widgetbook_workspace/use_cases/molecules/home_welcome_header_use_case.dart'
    as _widgetbook_workspace_use_cases_molecules_home_welcome_header_use_case;
import 'package:widgetbook_workspace/use_cases/molecules/management_card_button_use_case.dart'
    as _widgetbook_workspace_use_cases_molecules_management_card_button_use_case;
import 'package:widgetbook_workspace/use_cases/molecules/profile_menu_option_use_case.dart'
    as _widgetbook_workspace_use_cases_molecules_profile_menu_option_use_case;
import 'package:widgetbook_workspace/use_cases/organisms/profile_header_use_case.dart'
    as _widgetbook_workspace_use_cases_organisms_profile_header_use_case;
import 'package:widgetbook_workspace/use_cases/organisms/sticky_action_footer_use_case.dart'
    as _widgetbook_workspace_use_cases_organisms_sticky_action_footer_use_case;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'altrupets_ui',
    children: [
      _widgetbook.WidgetbookCategory(
        name: 'atoms',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'AppCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder:
                    _widgetbook_workspace_use_cases_altrupets_ui_atoms_app_card_use_case
                        .buildAppCardUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'AppChip',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder:
                    _widgetbook_workspace_use_cases_altrupets_ui_atoms_app_chip_use_case
                        .buildAppChipUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'AppDialog',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder:
                    _widgetbook_workspace_use_cases_altrupets_ui_atoms_app_dialog_use_case
                        .buildAppDialogUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'AppEmptyState',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder:
                    _widgetbook_workspace_use_cases_altrupets_ui_atoms_app_empty_state_use_case
                        .buildAppEmptyStateUseCase,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookCategory(
        name: 'molecules',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'FilterChipBar',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder:
                    _widgetbook_workspace_use_cases_altrupets_ui_molecules_filter_chip_bar_use_case
                        .buildFilterChipBarUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'KpiCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder:
                    _widgetbook_workspace_use_cases_altrupets_ui_molecules_kpi_card_use_case
                        .buildKpiCardUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'SectionHeader',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder:
                    _widgetbook_workspace_use_cases_altrupets_ui_molecules_section_header_use_case
                        .buildAltrupetsUiSectionHeaderUseCase,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookFolder(
    name: 'core',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'widgets',
        children: [
          _widgetbook.WidgetbookFolder(
            name: 'atoms',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'AppAccentBar',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder:
                        _widgetbook_workspace_use_cases_atoms_app_accent_bar_use_case
                            .buildAppAccentBarUseCase,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'AppCircularButton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder:
                        _widgetbook_workspace_use_cases_atoms_app_circular_button_use_case
                            .buildAppCircularButtonUseCase,
                  ),
                  _widgetbook.WidgetbookUseCase(
                    name: 'With Gradient',
                    builder:
                        _widgetbook_workspace_use_cases_atoms_app_circular_button_use_case
                            .buildAppCircularButtonGradientUseCase,
                  ),
                ],
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'molecules',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'FosterHomeHeaderCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder:
                        _widgetbook_workspace_use_cases_molecules_foster_home_header_card_use_case
                            .buildFosterHomeHeaderCardUseCase,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'FosterHomesManagementCardButton',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder:
                        _widgetbook_workspace_use_cases_molecules_management_card_button_use_case
                            .buildManagementCardButtonUseCase,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'HomeWelcomeHeader',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder:
                        _widgetbook_workspace_use_cases_molecules_home_welcome_header_use_case
                            .buildHomeWelcomeHeaderUseCase,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'ProfileMenuOption',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder:
                        _widgetbook_workspace_use_cases_molecules_profile_menu_option_use_case
                            .buildProfileMenuOptionUseCase,
                  ),
                ],
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'organisms',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'ProfileHeader',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder:
                        _widgetbook_workspace_use_cases_organisms_profile_header_use_case
                            .buildProfileHeaderUseCase,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'StickyActionFooter',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder:
                        _widgetbook_workspace_use_cases_organisms_sticky_action_footer_use_case
                            .buildStickyActionFooterUseCase,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
