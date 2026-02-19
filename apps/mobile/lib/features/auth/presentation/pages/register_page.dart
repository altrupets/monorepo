import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altrupets/features/auth/presentation/providers/auth_provider.dart';
import 'package:altrupets/features/auth/data/models/register_input.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _identificationController = TextEditingController();

  // Campos de ubicación
  final _countryController = TextEditingController();
  final _provinceController = TextEditingController();
  final _cantonController = TextEditingController();
  final _districtController = TextEditingController();

  // Campos para donantes
  final _occupationController = TextEditingController();
  final _incomeSourceController = TextEditingController();

  final List<String> _selectedRoles = ['WATCHER']; // Rol por defecto
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _currentStep = 0;

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
    _countryController.dispose();
    _provinceController.dispose();
    _cantonController.dispose();
    _districtController.dispose();
    _occupationController.dispose();
    _incomeSourceController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar que si es DONOR, tenga occupation e incomeSource
    if (_selectedRoles.contains('DONOR')) {
      if (_occupationController.text.trim().isEmpty ||
          _incomeSourceController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Para el rol de Donante, los campos Ocupación y Fuente de Ingresos son obligatorios',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final input = RegisterInput(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
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
      occupation: _occupationController.text.trim().isEmpty
          ? null
          : _occupationController.text.trim(),
      incomeSource: _incomeSourceController.text.trim().isEmpty
          ? null
          : _incomeSourceController.text.trim(),
      roles: _selectedRoles,
    );

    await ref.read(authProvider.notifier).register(input);

    if (!mounted) return;

    final authState = ref.read(authProvider);

    if (authState.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authState.error!), backgroundColor: Colors.red),
      );
    } else if (authState.user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Registro exitoso! Ahora puedes iniciar sesión'),
          backgroundColor: Colors.green,
        ),
      );

      // Navegar a login después de un breve delay
      await Future<void>.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pop(); // Volver a login
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // authState se usa para escuchar cambios en el provider
    ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Usuario')),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 3) {
              setState(() => _currentStep++);
            } else {
              _handleRegister();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          steps: [
            // Paso 1: Datos de cuenta
            Step(
              title: const Text('Datos de Cuenta'),
              content: Column(
                children: [
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de usuario *',
                      hintText: 'Mínimo 3 caracteres',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre de usuario es obligatorio';
                      }
                      if (value.trim().length < 3) {
                        return 'Debe tener al menos 3 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      hintText: 'opcional',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Correo electrónico inválido';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña *',
                      hintText: 'Mínimo 8 caracteres',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La contraseña es obligatoria';
                      }
                      if (value.length < 8) {
                        return 'Debe tener al menos 8 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirmar contraseña *',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          );
                        },
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirma tu contraseña';
                      }
                      if (value != _passwordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              isActive: _currentStep >= 0,
            ),

            // Paso 2: Datos personales
            Step(
              title: const Text('Datos Personales'),
              content: Column(
                children: [
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      hintText: 'opcional',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Apellidos',
                      hintText: 'opcional',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      hintText: 'opcional',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _identificationController,
                    decoration: const InputDecoration(
                      labelText: 'Cédula/Pasaporte',
                      hintText: 'opcional',
                    ),
                  ),
                ],
              ),
              isActive: _currentStep >= 1,
            ),

            // Paso 3: Ubicación
            Step(
              title: const Text('Ubicación'),
              content: Column(
                children: [
                  TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'País',
                      hintText: 'opcional',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _provinceController,
                    decoration: const InputDecoration(
                      labelText: 'Provincia',
                      hintText: 'opcional',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cantonController,
                    decoration: const InputDecoration(
                      labelText: 'Cantón',
                      hintText: 'opcional',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _districtController,
                    decoration: const InputDecoration(
                      labelText: 'Distrito',
                      hintText: 'opcional',
                    ),
                  ),
                ],
              ),
              isActive: _currentStep >= 2,
            ),

            // Paso 4: Roles y datos adicionales
            Step(
              title: const Text('Roles'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecciona los roles que deseas tener:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('Centinela (Watcher)'),
                    subtitle: const Text(
                      'Reportar animales en situación de riesgo',
                    ),
                    value: _selectedRoles.contains('WATCHER'),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedRoles.add('WATCHER');
                        } else {
                          _selectedRoles.remove('WATCHER');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Rescatista (Rescuer)'),
                    subtitle: const Text('Rescatar animales en peligro'),
                    value: _selectedRoles.contains('RESCUER'),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedRoles.add('RESCUER');
                        } else {
                          _selectedRoles.remove('RESCUER');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Donante (Donor)'),
                    subtitle: const Text('Realizar donaciones'),
                    value: _selectedRoles.contains('DONOR'),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedRoles.add('DONOR');
                        } else {
                          _selectedRoles.remove('DONOR');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Veterinario (Veterinarian)'),
                    subtitle: const Text('Brindar atención veterinaria'),
                    value: _selectedRoles.contains('VETERINARIAN'),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedRoles.add('VETERINARIAN');
                        } else {
                          _selectedRoles.remove('VETERINARIAN');
                        }
                      });
                    },
                  ),
                  if (_selectedRoles.contains('DONOR')) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Información adicional para Donantes:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _occupationController,
                      decoration: const InputDecoration(
                        labelText: 'Ocupación *',
                        hintText: 'Requerido para donantes',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _incomeSourceController,
                      decoration: const InputDecoration(
                        labelText: 'Fuente de Ingresos *',
                        hintText: 'Requerido para donantes',
                      ),
                    ),
                  ],
                ],
              ),
              isActive: _currentStep >= 3,
            ),
          ],
        ),
      ),
    );
  }
}
