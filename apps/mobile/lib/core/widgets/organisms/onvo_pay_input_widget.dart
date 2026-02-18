import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:altrupets/core/services/onvo_pay_service.dart';

/// Widget de entrada de pago usando ONVO Pay (Costa Rica)
/// Soporta:
/// - Tarjetas de débito/crédito (tokenización PCI compliant)
/// - SINPE Móvil (transferencias bancarias)
class OnvoPayInputWidget extends StatefulWidget {
  const OnvoPayInputWidget({
    super.key,
    required this.onPaymentMethodAdded,
    required this.apiKey,
    this.sandbox = true,
    this.showSinpeOption = true,
  });

  final Function(OnvoPaymentMethod) onPaymentMethodAdded;
  final String apiKey;
  final bool sandbox;
  final bool showSinpeOption;

  @override
  State<OnvoPayInputWidget> createState() => _OnvoPayInputWidgetState();
}

class _OnvoPayInputWidgetState extends State<OnvoPayInputWidget> {
  late final OnvoPayService _onvoService;
  int _selectedMethod = 0; // 0 = Tarjeta, 1 = SINPE

  // Controladores para tarjeta
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  // Controlador para SINPE
  final _sinpePhoneController = TextEditingController();

  String _cardType = 'unknown';
  bool _isProcessing = false;
  bool _saveMethod = false;

  @override
  void initState() {
    super.initState();
    _onvoService = OnvoPayService(
      apiKey: widget.apiKey,
      sandbox: widget.sandbox,
    );
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    _sinpePhoneController.dispose();
    super.dispose();
  }

  void _detectCardType(String number) {
    final cleanNumber = number.replaceAll(' ', '');
    String detectedType = 'unknown';

    if (cleanNumber.startsWith('4')) {
      detectedType = 'visa';
    } else if (RegExp(r'^5[1-5]').hasMatch(cleanNumber)) {
      detectedType = 'mastercard';
    } else if (RegExp(r'^3[47]').hasMatch(cleanNumber)) {
      detectedType = 'amex';
    }

    if (detectedType != _cardType) {
      setState(() => _cardType = detectedType);
    }
  }

  String _formatCardNumber(String value) {
    final cleanValue = value.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < cleanValue.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(cleanValue[i]);
    }

    return buffer.toString();
  }

  Future<void> _processPaymentMethod() async {
    if (_selectedMethod == 0) {
      await _tokenizeCard();
    } else {
      await _setupSinpe();
    }
  }

  Future<void> _tokenizeCard() async {
    // Validar campos
    if (_cardNumberController.text.replaceAll(' ', '').length < 13 ||
        _expiryController.text.length < 5 ||
        _cvvController.text.length < 3 ||
        _cardHolderController.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos de la tarjeta'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final parts = _expiryController.text.split('/');
      final expiryMonth = parts[0].padLeft(2, '0');
      final expiryYear = parts[1].length == 2 ? '20${parts[1]}' : parts[1];

      final token = await _onvoService.tokenizeCard(
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        cvv: _cvvController.text,
        cardHolderName: _cardHolderController.text.toUpperCase(),
      );

      final paymentMethod = OnvoPaymentMethod(
        type: OnvoPaymentType.card,
        cardToken: token.id,
        last4: token.last4,
        cardBrand: token.brand,
        cardHolderName: token.cardHolderName,
        expiryMonth: token.expiryMonth,
        expiryYear: token.expiryYear,
        saveForFuture: _saveMethod,
      );

      widget.onPaymentMethodAdded(paymentMethod);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarjeta agregada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } on OnvoPayException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _setupSinpe() async {
    final phone = _sinpePhoneController.text.replaceAll(RegExp(r'\D'), '');

    if (phone.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un número de teléfono válido (8 dígitos)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final paymentMethod = OnvoPaymentMethod(
      type: OnvoPaymentType.sinpe,
      sinpePhoneNumber: phone,
      saveForFuture: _saveMethod,
    );

    widget.onPaymentMethodAdded(paymentMethod);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SINPE Móvil configurado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Agregar Método de Pago',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ONVO Pay - Pagos seguros en Costa Rica',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),

          // Selector de método de pago
          if (widget.showSinpeOption)
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                  0.3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _PaymentMethodButton(
                      icon: Icons.credit_card,
                      label: 'Tarjeta',
                      isSelected: _selectedMethod == 0,
                      onTap: () => setState(() => _selectedMethod = 0),
                    ),
                  ),
                  Expanded(
                    child: _PaymentMethodButton(
                      icon: Icons.phone_android,
                      label: 'SINPE Móvil',
                      isSelected: _selectedMethod == 1,
                      onTap: () => setState(() => _selectedMethod = 1),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Formulario según método seleccionado
          if (_selectedMethod == 0)
            _buildCardForm(theme)
          else
            _buildSinpeForm(theme),

          const SizedBox(height: 16),

          // Opción de guardar
          CheckboxListTile(
            title: const Text('Guardar para futuras compras'),
            subtitle: const Text('Los datos se almacenan de forma segura'),
            value: _saveMethod,
            onChanged: (value) {
              setState(() => _saveMethod = value ?? false);
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),

          const SizedBox(height: 24),

          // Botón de confirmar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _processPaymentMethod,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.lock_outline),
              label: Text(
                _isProcessing
                    ? 'Procesando...'
                    : _selectedMethod == 0
                    ? 'Agregar Tarjeta'
                    : 'Configurar SINPE',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Indicadores de seguridad
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_user,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'PCI DSS Compliant',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.lock, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'ONVO Pay',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardForm(ThemeData theme) {
    return Column(
      children: [
        // Número de tarjeta
        TextField(
          controller: _cardNumberController,
          decoration: InputDecoration(
            labelText: 'Número de Tarjeta',
            hintText: '0000 0000 0000 0000',
            prefixIcon: _getCardIcon(),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(19),
            TextInputFormatter.withFunction((oldValue, newValue) {
              final formatted = _formatCardNumber(newValue.text);
              _detectCardType(newValue.text);
              return TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            }),
          ],
        ),
        const SizedBox(height: 16),

        // Nombre del titular
        TextField(
          controller: _cardHolderController,
          decoration: InputDecoration(
            labelText: 'Nombre del Titular',
            hintText: 'Como aparece en la tarjeta',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 16),

        // Fecha y CVV
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _expiryController,
                decoration: InputDecoration(
                  labelText: 'Expiración',
                  hintText: 'MM/AA',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final text = newValue.text;
                    if (text.length >= 2 && !text.contains('/')) {
                      return TextEditingValue(
                        text: '${text.substring(0, 2)}/${text.substring(2)}',
                        selection: TextSelection.collapsed(
                          offset: text.length + 1,
                        ),
                      );
                    }
                    return newValue;
                  }),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _cvvController,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  hintText: '123',
                  prefixIcon: const Icon(Icons.security),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSinpeForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '¿Qué es SINPE Móvil?',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'SINPE Móvil es el sistema de transferencias bancarias de Costa Rica. '
                'Al realizar un pago, recibirás una notificación en tu banco para autorizar la transferencia.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _sinpePhoneController,
          decoration: InputDecoration(
            labelText: 'Número de Teléfono SINPE',
            hintText: '8888-8888',
            prefixIcon: const Icon(Icons.phone_android),
            prefixText: '+506 ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            helperText: 'Ingresa tu número registrado en SINPE Móvil',
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(8),
            TextInputFormatter.withFunction((oldValue, newValue) {
              final text = newValue.text;
              if (text.length > 4) {
                return TextEditingValue(
                  text: '${text.substring(0, 4)}-${text.substring(4)}',
                  selection: TextSelection.collapsed(offset: text.length + 1),
                );
              }
              return newValue;
            }),
          ],
        ),
      ],
    );
  }

  Widget _getCardIcon() {
    IconData iconData;
    Color iconColor;

    switch (_cardType) {
      case 'visa':
        iconData = Icons.payment;
        iconColor = const Color(0xFF1A1F71);
        break;
      case 'mastercard':
        iconData = Icons.payment;
        iconColor = const Color(0xFFEB001B);
        break;
      case 'amex':
        iconData = Icons.payment;
        iconColor = const Color(0xFF006FCF);
        break;
      default:
        iconData = Icons.credit_card;
        iconColor = Colors.grey;
    }

    return Icon(iconData, color: iconColor);
  }
}

/// Botón de selección de método de pago
class _PaymentMethodButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tipo de método de pago
enum OnvoPaymentType { card, sinpe }

/// Modelo de método de pago ONVO
class OnvoPaymentMethod {
  final OnvoPaymentType type;
  final String? cardToken;
  final String? last4;
  final String? cardBrand;
  final String? cardHolderName;
  final String? expiryMonth;
  final String? expiryYear;
  final String? sinpePhoneNumber;
  final bool saveForFuture;

  OnvoPaymentMethod({
    required this.type,
    this.cardToken,
    this.last4,
    this.cardBrand,
    this.cardHolderName,
    this.expiryMonth,
    this.expiryYear,
    this.sinpePhoneNumber,
    required this.saveForFuture,
  });

  bool get isCard => type == OnvoPaymentType.card;
  bool get isSinpe => type == OnvoPaymentType.sinpe;

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'cardToken': cardToken,
    'last4': last4,
    'cardBrand': cardBrand,
    'cardHolderName': cardHolderName,
    'expiryMonth': expiryMonth,
    'expiryYear': expiryYear,
    'sinpePhoneNumber': sinpePhoneNumber,
    'saveForFuture': saveForFuture,
  };
}

/// Widget para mostrar método de pago guardado
class OnvoSavedMethodWidget extends StatelessWidget {
  final OnvoPaymentMethod method;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const OnvoSavedMethodWidget({
    super.key,
    required this.method,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          method.isCard ? Icons.credit_card : Icons.phone_android,
          color: method.isCard ? theme.colorScheme.primary : Colors.green,
          size: 32,
        ),
        title: Text(
          method.isCard ? '•••• ${method.last4}' : '${method.sinpePhoneNumber}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: method.isCard ? 2 : 0,
          ),
        ),
        subtitle: Text(
          method.isCard
              ? '${_formatBrand(method.cardBrand)} • Expira ${method.expiryMonth}/${method.expiryYear}'
              : 'SINPE Móvil',
          style: theme.textTheme.bodySmall,
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
              )
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  String _formatBrand(String? brand) {
    if (brand == null) return 'Tarjeta';
    switch (brand.toLowerCase()) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'amex':
        return 'American Express';
      default:
        return brand;
    }
  }
}
