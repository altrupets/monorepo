import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altrupets/core/providers/registration_provider.dart';
import 'package:altrupets/core/auth/roles/user_role.dart';
import 'package:altrupets/core/widgets/molecules/app_input_card.dart';
import 'package:altrupets/core/widgets/molecules/section_header.dart';
import 'package:altrupets/core/widgets/organisms/sticky_action_footer.dart';

/// Individual user registration page
/// Collects personal data and desired roles
class RegisterIndividualPage extends ConsumerStatefulWidget {
  const RegisterIndividualPage({super.key});

  @override
  ConsumerState<RegisterIndividualPage> createState() =>
      _RegisterIndividualPageState();
}

class _RegisterIndividualPageState
    extends ConsumerState<RegisterIndividualPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _identificationController = TextEditingController();

  // Selected roles
  final Set<UserRole> _selectedRoles = {UserRole.watcher};

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _identificationController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final registrationService = ref.read(registrationServiceProvider);

      await registrationService.registerIndividual(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim().isEmpty
            ? null
            : _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim().isEmpty
            ? null
            : _lastNameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        identification: _identificationController.text.trim().isEmpty
            ? null
            : _identificationController.text.trim(),
        roles: _selectedRoles.toList(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro exitoso. Por favor inicia sesión.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en registro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Registro Individual'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App Logo
                    Center(
                      child: Icon(
                        Icons.pets,
                        size: 80,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'AltruPets',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    const SectionHeader(title: 'DATOS DE CUENTA'),
                    const SizedBox(height: 16),

                    // Username
                    AppInputCard(
                      label: 'NOMBRE DE USUARIO *',
                      hint: 'Mínimo 3 caracteres',
                      controller: _usernameController,
                    ),
                    const SizedBox(height: 12),

                    // Email
                    AppInputCard(
                      label: 'CORREO ELECTRÓNICO',
                      hint: 'correo@ejemplo.com (opcional)',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        labelText: 'CONTRASEÑA *',
                        hintText: 'Mínimo 8 caracteres',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La contraseña es requerida';
                        }
                        if (value.length < 8) {
                          return 'Mínimo 8 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Confirm Password
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        labelText: 'CONFIRMAR CONTRASEÑA *',
                        hintText: 'Repite tu contraseña',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            );
                          },
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    const SectionHeader(title: 'DATOS PERSONALES'),
                    const SizedBox(height: 16),

                    // First Name
                    AppInputCard(
                      label: 'NOMBRE',
                      hint: 'Tu nombre (opcional)',
                      controller: _firstNameController,
                    ),
                    const SizedBox(height: 12),

                    // Last Name
                    AppInputCard(
                      label: 'APELLIDO',
                      hint: 'Tu apellido (opcional)',
                      controller: _lastNameController,
                    ),
                    const SizedBox(height: 12),

                    // Phone
                    AppInputCard(
                      label: 'TELÉFONO',
                      hint: 'Número de teléfono (opcional)',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),

                    // Identification
                    AppInputCard(
                      label: 'IDENTIFICACIÓN',
                      hint: 'Cédula o ID (opcional)',
                      controller: _identificationController,
                    ),
                    const SizedBox(height: 32),

                    const SectionHeader(title: 'ROLES DESEADOS'),
                    const SizedBox(height: 8),
                    Text(
                      'Selecciona los roles que deseas tener en la plataforma',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Role badges
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildRoleBadge(
                          context,
                          'Centinela',
                          UserRole.watcher,
                          const Color(0xFF2B8CEE),
                          'Reportar animales que necesitan ayuda',
                        ),
                        _buildRoleBadge(
                          context,
                          'Rescatista',
                          UserRole.rescuer,
                          Colors.green,
                          'Rescatar animales en peligro',
                        ),
                        _buildRoleBadge(
                          context,
                          'Donante',
                          UserRole.donor,
                          Colors.purple,
                          'Apoyar con donaciones',
                        ),
                        _buildRoleBadge(
                          context,
                          'Veterinario',
                          UserRole.veterinarian,
                          const Color(0xFFFF8C00),
                          'Proporcionar atención médica',
                        ),
                      ],
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: StickyActionFooter(
              cancelLabel: 'Cancelar',
              saveLabel: 'Registrarse',
              onCancel: () => Navigator.of(context).pop(),
              onSave: _isLoading ? () {} : _register,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(
    BuildContext context,
    String label,
    UserRole role,
    Color color,
    String description,
  ) {
    final isSelected = _selectedRoles.contains(role);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedRoles.remove(role);
          } else {
            _selectedRoles.add(role);
          }
        });
      },
      child: Tooltip(
        message: description,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : theme.colorScheme.outline,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
