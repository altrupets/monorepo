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
import 'package:widgetbook_workspace/use_cases/atoms/app_accent_bar_use_case.dart'
    as _widgetbook_workspace_use_cases_atoms_app_accent_bar_use_case;
import 'package:widgetbook_workspace/use_cases/atoms/app_circular_button_use_case.dart'
    as _widgetbook_workspace_use_cases_atoms_app_circular_button_use_case;
import 'package:widgetbook_workspace/use_cases/atoms/app_role_badge_use_case.dart'
    as _widgetbook_workspace_use_cases_atoms_app_role_badge_use_case;
import 'package:widgetbook_workspace/use_cases/molecules/app_input_card_use_case.dart'
    as _widgetbook_workspace_use_cases_molecules_app_input_card_use_case;
import 'package:widgetbook_workspace/use_cases/molecules/app_nav_item_use_case.dart'
    as _widgetbook_workspace_use_cases_molecules_app_nav_item_use_case;
import 'package:widgetbook_workspace/use_cases/molecules/app_service_card_use_case.dart'
    as _widgetbook_workspace_use_cases_molecules_app_service_card_use_case;
import 'package:widgetbook_workspace/use_cases/molecules/foster_home_header_card_use_case.dart'
    as _widgetbook_workspace_use_cases_molecules_foster_home_header_card_use_case;
import 'package:widgetbook_workspace/use_cases/molecules/home_welcome_header_use_case.dart'
    as _widgetbook_workspace_use_cases_molecules_home_welcome_header_use_case;
import 'package:widgetbook_workspace/use_cases/molecules/management_card_button_use_case.dart'
    as _widgetbook_workspace_use_cases_molecules_management_card_button_use_case;
import 'package:widgetbook_workspace/use_cases/molecules/profile_menu_option_use_case.dart'
    as _widgetbook_workspace_use_cases_molecules_profile_menu_option_use_case;
import 'package:widgetbook_workspace/use_cases/molecules/section_header_use_case.dart'
    as _widgetbook_workspace_use_cases_molecules_section_header_use_case;
import 'package:widgetbook_workspace/use_cases/organisms/main_navigation_bar_use_case.dart'
    as _widgetbook_workspace_use_cases_organisms_main_navigation_bar_use_case;
import 'package:widgetbook_workspace/use_cases/organisms/profile_header_use_case.dart'
    as _widgetbook_workspace_use_cases_organisms_profile_header_use_case;
import 'package:widgetbook_workspace/use_cases/organisms/profile_main_header_use_case.dart'
    as _widgetbook_workspace_use_cases_organisms_profile_main_header_use_case;
import 'package:widgetbook_workspace/use_cases/organisms/sticky_action_footer_use_case.dart'
    as _widgetbook_workspace_use_cases_organisms_sticky_action_footer_use_case;

final directories = <_widgetbook.WidgetbookNode>[
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
              _widgetbook.WidgetbookComponent(
                name: 'AppRoleBadge',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder:
                        _widgetbook_workspace_use_cases_atoms_app_role_badge_use_case
                            .buildAppRoleBadgeUseCase,
                  ),
                ],
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'molecules',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'AppInputCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder:
                        _widgetbook_workspace_use_cases_molecules_app_input_card_use_case
                            .buildAppInputCardUseCase,
                  ),
                  _widgetbook.WidgetbookUseCase(
                    name: 'Disabled',
                    builder:
                        _widgetbook_workspace_use_cases_molecules_app_input_card_use_case
                            .buildAppInputCardDisabledUseCase,
                  ),
                  _widgetbook.WidgetbookUseCase(
                    name: 'Dropdown',
                    builder:
                        _widgetbook_workspace_use_cases_molecules_app_input_card_use_case
                            .buildAppInputCardDropdownUseCase,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'AppNavItem',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Selected',
                    builder:
                        _widgetbook_workspace_use_cases_molecules_app_nav_item_use_case
                            .buildAppNavItemSelectedUseCase,
                  ),
                  _widgetbook.WidgetbookUseCase(
                    name: 'Unselected',
                    builder:
                        _widgetbook_workspace_use_cases_molecules_app_nav_item_use_case
                            .buildAppNavItemUnselectedUseCase,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'AppServiceCard',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder:
                        _widgetbook_workspace_use_cases_molecules_app_service_card_use_case
                            .buildAppServiceCardUseCase,
                  ),
                  _widgetbook.WidgetbookUseCase(
                    name: 'Warm Gradient',
                    builder:
                        _widgetbook_workspace_use_cases_molecules_app_service_card_use_case
                            .buildAppServiceCardWarmUseCase,
                  ),
                ],
              ),
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
                name: 'ManagementCardButton',
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
              _widgetbook.WidgetbookComponent(
                name: 'SectionHeader',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder:
                        _widgetbook_workspace_use_cases_molecules_section_header_use_case
                            .buildSectionHeaderUseCase,
                  ),
                ],
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'organisms',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'MainNavigationBar',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder:
                        _widgetbook_workspace_use_cases_organisms_main_navigation_bar_use_case
                            .buildMainNavigationBarUseCase,
                  ),
                ],
              ),
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
                name: 'ProfileMainHeader',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Default',
                    builder:
                        _widgetbook_workspace_use_cases_organisms_profile_main_header_use_case
                            .buildProfileMainHeaderUseCase,
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
