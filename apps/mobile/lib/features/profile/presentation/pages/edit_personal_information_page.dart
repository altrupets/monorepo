import 'package:altrupets/core/providers/navigation_provider.dart';
import 'package:altrupets/core/widgets/atoms/app_role_badge.dart';
import 'package:altrupets/core/widgets/molecules/app_input_card.dart';
import 'package:altrupets/core/widgets/molecules/section_header.dart';
import 'package:altrupets/core/widgets/organisms/profile_header.dart';
import 'package:altrupets/core/widgets/organisms/sticky_action_footer.dart';
import 'package:altrupets/features/auth/domain/entities/user.dart';
import 'package:altrupets/features/profile/presentation/data/costa_rica_locations.dart';
import 'package:altrupets/features/profile/presentation/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditPersonalInformationPage extends ConsumerStatefulWidget {
  const EditPersonalInformationPage({super.key});

  @override
  ConsumerState<EditPersonalInformationPage> createState() =>
      _EditPersonalInformationPageState();
}

class _EditPersonalInformationPageState
    extends ConsumerState<EditPersonalInformationPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _identificationController;
  late final TextEditingController _countryController;
  late final TextEditingController _provinceController;
  late final TextEditingController _cantonController;
  late final TextEditingController _districtController;

  String _phoneCountryCode = '+506';

  static const List<Map<String, String>> _countryPhoneCodes = [
    {'code': '+506', 'country': 'Costa Rica'},
    {'code': '+507', 'country': 'Panama'},
    {'code': '+505', 'country': 'Nicaragua'},
    {'code': '+1', 'country': 'USA/Canada'},
  ];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _identificationController = TextEditingController();
    _countryController = TextEditingController(text: costaRicaCountry);
    _provinceController = TextEditingController();
    _cantonController = TextEditingController();
    _districtController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _identificationController.dispose();
    _countryController.dispose();
    _provinceController.dispose();
    _cantonController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  List<String> get _availableCantons {
    return costaRicaCantonsByProvince[_provinceController.text] ?? const [];
  }

  List<String> get _availableDistricts {
    final key = '${_provinceController.text}|${_cantonController.text}';
    return costaRicaDistrictsByCanton[key] ?? const [];
  }

  void _loadUserData(User user) {
    _firstNameController.text = user.firstName ?? '';
    _lastNameController.text = user.lastName ?? '';
    _identificationController.text = user.identification ?? '';

    final country = (user.country ?? '').trim();
    _countryController.text = country.isEmpty ? costaRicaCountry : country;

    final phone = (user.phone ?? '').trim();
    if (phone.startsWith('+') && phone.contains(' ')) {
      final parts = phone.split(' ');
      _phoneCountryCode = parts.first;
      _phoneController.text = parts.skip(1).join(' ').trim();
    } else if (phone.startsWith('+506')) {
      _phoneCountryCode = '+506';
      _phoneController.text = phone.replaceFirst('+506', '').trim();
    } else {
      _phoneController.text = phone;
    }

    _provinceController.text = user.province ?? '';
    _cantonController.text = user.canton ?? '';
    _districtController.text = user.district ?? '';
  }

  Future<String?> _pickOption({
    required String title,
    required List<String> options,
  }) async {
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        if (options.isEmpty) {
          return SizedBox(
            height: 140,
            child: Center(
              child: Text('No hay opciones disponibles para $title'),
            ),
          );
        }

        return SafeArea(
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (context, index) {
              final value = options[index];
              return ListTile(
                title: Text(value),
                onTap: () => Navigator.of(context).pop(value),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _selectPhoneCode() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView.builder(
            itemCount: _countryPhoneCodes.length,
            itemBuilder: (context, index) {
              final item = _countryPhoneCodes[index];
              final code = item['code']!;
              final country = item['country']!;
              return ListTile(
                title: Text('$code ($country)'),
                onTap: () => Navigator.of(context).pop(code),
              );
            },
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        _phoneCountryCode = selected;
      });
    }
  }

  Future<void> _selectCountry() async {
    final selected = await _pickOption(
      title: 'pais',
      options: const [costaRicaCountry],
    );

    if (selected != null && mounted) {
      setState(() {
        _countryController.text = selected;
        _provinceController.clear();
        _cantonController.clear();
        _districtController.clear();
        if (selected != costaRicaCountry) {
          _phoneCountryCode = '+506';
        }
      });
    }
  }

  Future<void> _selectProvince() async {
    final selected = await _pickOption(
      title: 'provincia',
      options: costaRicaProvinces,
    );

    if (selected != null && mounted) {
      setState(() {
        _provinceController.text = selected;
        _cantonController.clear();
        _districtController.clear();
      });
    }
  }

  Future<void> _selectCanton() async {
    if (_provinceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona primero una provincia')),
      );
      return;
    }

    final selected = await _pickOption(
      title: 'canton',
      options: _availableCantons,
    );

    if (selected != null && mounted) {
      setState(() {
        _cantonController.text = selected;
        _districtController.clear();
      });
    }
  }

  Future<void> _selectDistrict() async {
    if (_provinceController.text.isEmpty || _cantonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona primero provincia y canton'),
        ),
      );
      return;
    }

    final selected = await _pickOption(
      title: 'distrito',
      options: _availableDistricts,
    );

    if (selected != null && mounted) {
      setState(() {
        _districtController.text = selected;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final phoneLocal = _phoneController.text.trim();
    final normalizedPhone = phoneLocal.isEmpty
        ? null
        : '${_phoneCountryCode.trim()} ${phoneLocal.trim()}';

    final params = UpdateUserParams(
      firstName: _firstNameController.text.trim().isEmpty
          ? null
          : _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim().isEmpty
          ? null
          : _lastNameController.text.trim(),
      phone: normalizedPhone,
      identification: _identificationController.text.trim().isEmpty
          ? null
          : _identificationController.text.trim(),
      country: _countryController.text.trim().isEmpty
          ? null
          : _countryController.text.trim(),
      province: _provinceController.text.trim().isEmpty
          ? null
          : _provinceController.text.trim(),
      canton: _cantonController.text.trim().isEmpty
          ? null
          : _cantonController.text.trim(),
      district: _districtController.text.trim().isEmpty
          ? null
          : _districtController.text.trim(),
    );

    final result = await ref.read(updateUserProfileProvider(params).future);

    if (!mounted) {
      return;
    }

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informacion guardada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(navigationProvider).pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navigation = ref.read(navigationProvider);
    final userAsync = ref.watch(currentUserProvider);

    userAsync.whenData((user) {
      if (user != null && _firstNameController.text.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadUserData(user);
        });
      }
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  ProfileHeader(
                    title: 'Editar Informacion Personal',
                    imageUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuCq_iWgFzHah59OBIvWrzkg3zd6Db9TdftdNUavNvy6VGk53MEnNpB2Iih6Zn7VNCtIYW3xgWSqBwgtVTJEeuPQLeVgaDdr2L0VYrQ4etjPIFC4N7CHHsUoqD4Zm3jDawc73XeGAXZVshhN0i86f_DYwoGCoCrrKFA5gQK_qu5Mi49vFS3OxGr0iQoW88L-C_AQ-1__z3EeRMigF4hGXVwEF7x8JZ3zxFTIyjuxjOT6BXSjoKuXF-IQAcDQwt6O7IN7YhLRQoIo78Y',
                    onBackTap: () => navigation.pop(context),
                    onCameraTap: () {},
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        const SectionHeader(title: 'DATOS PERSONALES'),
                        const SizedBox(height: 16),
                        AppInputCard(
                          label: 'NOMBRE',
                          initialValue: _firstNameController.text,
                          hint: 'Tu nombre',
                          controller: _firstNameController,
                        ),
                        const SizedBox(height: 12),
                        AppInputCard(
                          label: 'APELLIDO',
                          initialValue: _lastNameController.text,
                          hint: 'Tu apellido',
                          controller: _lastNameController,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'TELEFONO',
                            hintText: 'Numero',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            prefixIcon: InkWell(
                              onTap: _selectPhoneCode,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                child: Text(
                                  _phoneCountryCode,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        AppInputCard(
                          label: 'CEDULA',
                          initialValue: _identificationController.text,
                          hint: 'ID',
                          controller: _identificationController,
                        ),
                        const SizedBox(height: 32),
                        const SectionHeader(title: 'MIS ROLES'),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const AppRoleBadge(
                              label: 'Centinela',
                              color: Color(0xFF2B8CEE),
                            ),
                            const AppRoleBadge(
                              label: 'Auxiliar',
                              color: Color(0xFFFF8C00),
                            ),
                            const AppRoleBadge(
                              label: 'Rescatista',
                              color: Colors.green,
                            ),
                            const AppRoleBadge(
                              label: 'Adoptante',
                              color: Colors.purple,
                            ),
                            _buildAddRoleButton(context),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const SectionHeader(title: 'RESIDENCIA'),
                        const SizedBox(height: 16),
                        AppInputCard(
                          label: 'PAIS',
                          initialValue: _countryController.text,
                          hint: 'Selecciona pais',
                          isDropdown: true,
                          controller: _countryController,
                          onTap: _selectCountry,
                        ),
                        const SizedBox(height: 12),
                        AppInputCard(
                          label: 'PROVINCIA',
                          initialValue: _provinceController.text,
                          hint: 'Selecciona provincia',
                          isDropdown: true,
                          controller: _provinceController,
                          onTap: _selectProvince,
                        ),
                        const SizedBox(height: 12),
                        AppInputCard(
                          label: 'CANTON',
                          initialValue: _cantonController.text,
                          hint: 'Selecciona canton',
                          isDropdown: true,
                          controller: _cantonController,
                          onTap: _selectCanton,
                        ),
                        const SizedBox(height: 12),
                        AppInputCard(
                          label: 'DISTRITO',
                          initialValue: _districtController.text,
                          hint: 'Selecciona distrito',
                          isDropdown: true,
                          controller: _districtController,
                          onTap: _selectDistrict,
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: StickyActionFooter(
              onCancel: () => navigation.pop(context),
              onSave: _handleSave,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddRoleButton(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Icon(
        Icons.add_rounded,
        size: 18,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    );
  }
}
