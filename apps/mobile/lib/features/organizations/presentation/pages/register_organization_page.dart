import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:altrupets/core/widgets/atoms/app_snackbar.dart';
import 'package:altrupets/features/organizations/data/models/organization.dart';
import 'package:altrupets/features/organizations/data/models/register_organization_input.dart';
import 'package:altrupets/features/organizations/presentation/providers/organizations_provider.dart';

class RegisterOrganizationPage extends ConsumerStatefulWidget {
  const RegisterOrganizationPage({super.key});

  @override
  ConsumerState<RegisterOrganizationPage> createState() =>
      _RegisterOrganizationPageState();
}

class _RegisterOrganizationPageState
    extends ConsumerState<RegisterOrganizationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _legalIdController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  final _countryController = TextEditingController();
  final _provinceController = TextEditingController();
  final _cantonController = TextEditingController();
  final _districtController = TextEditingController();
  final _maxCapacityController = TextEditingController();

  OrganizationType _selectedType = OrganizationType.association;
  File? _legalDocumentationFile;
  File? _financialStatementsFile;
  int _currentStep = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _legalIdController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _countryController.dispose();
    _provinceController.dispose();
    _cantonController.dispose();
    _districtController.dispose();
    _maxCapacityController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument(bool isLegalDoc) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (isLegalDoc) {
          _legalDocumentationFile = File(pickedFile.path);
        } else {
          _financialStatementsFile = File(pickedFile.path);
        }
      });
    }
  }

  Future<String?> _fileToBase64(File? file) async {
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final legalDocBase64 = await _fileToBase64(_legalDocumentationFile);
    final financialBase64 = await _fileToBase64(_financialStatementsFile);

    final input = RegisterOrganizationInput(
      name: _nameController.text.trim(),
      type: _selectedType,
      legalId: _legalIdController.text.trim().isEmpty
          ? null
          : _legalIdController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      website: _websiteController.text.trim().isEmpty
          ? null
          : _websiteController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
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
      legalDocumentationBase64: legalDocBase64,
      financialStatementsBase64: financialBase64,
      maxCapacity: _maxCapacityController.text.trim().isEmpty
          ? null
          : int.tryParse(_maxCapacityController.text.trim()),
    );

    await ref.read(organizationsProvider.notifier).registerOrganization(input);

    if (!mounted) return;

    final state = ref.read(organizationsProvider);

    if (state.error != null) {
      AppSnackbar.error(context: context, message: state.error!);
    } else if (state.selectedOrganization != null) {
      AppSnackbar.success(
        context: context,
        message: '¡Organización registrada exitosamente!',
      );

      await Future<void>.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // state se usa para escuchar cambios en el provider
    ref.watch(organizationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Organización')),
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
            // Paso 1: Información básica
            Step(
              title: const Text('Información Básica'),
              content: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la Organización *',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<OrganizationType>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Organización *',
                    ),
                    items: OrganizationType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getOrganizationTypeLabel(type)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _legalIdController,
                    decoration: const InputDecoration(
                      labelText: 'Cédula Jurídica',
                      hintText: 'opcional',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'opcional',
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              isActive: _currentStep >= 0,
            ),

            // Paso 2: Contacto
            Step(
              title: const Text('Información de Contacto'),
              content: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo Electrónico',
                      hintText: 'opcional',
                    ),
                    keyboardType: TextInputType.emailAddress,
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
                    controller: _websiteController,
                    decoration: const InputDecoration(
                      labelText: 'Sitio Web',
                      hintText: 'opcional',
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección',
                      hintText: 'opcional',
                    ),
                    maxLines: 2,
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _maxCapacityController,
                    decoration: const InputDecoration(
                      labelText: 'Capacidad Máxima de Animales',
                      hintText: 'opcional',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              isActive: _currentStep >= 2,
            ),

            // Paso 4: Documentación
            Step(
              title: const Text('Documentación'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Documentación Legal',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _pickDocument(true),
                    icon: const Icon(Icons.upload_file),
                    label: Text(
                      _legalDocumentationFile == null
                          ? 'Seleccionar Documento'
                          : 'Documento Seleccionado',
                    ),
                  ),
                  if (_legalDocumentationFile != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _legalDocumentationFile!.path.split('/').last,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    'Estados Financieros',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _pickDocument(false),
                    icon: const Icon(Icons.upload_file),
                    label: Text(
                      _financialStatementsFile == null
                          ? 'Seleccionar Documento'
                          : 'Documento Seleccionado',
                    ),
                  ),
                  if (_financialStatementsFile != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _financialStatementsFile!.path.split('/').last,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nota: Al registrar la organización, serás automáticamente designado como Representante Legal.',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              isActive: _currentStep >= 3,
            ),
          ],
        ),
      ),
    );
  }

  String _getOrganizationTypeLabel(OrganizationType type) {
    switch (type) {
      case OrganizationType.foundation:
        return 'Fundación';
      case OrganizationType.association:
        return 'Asociación';
      case OrganizationType.ngo:
        return 'ONG';
      case OrganizationType.cooperative:
        return 'Cooperativa';
      case OrganizationType.government:
        return 'Gubernamental';
      case OrganizationType.other:
        return 'Otro';
    }
  }
}
