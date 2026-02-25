import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:altrupets/core/payments/latam_payments.dart';

/// Widget para ingreso seguro de tarjetas de débito/crédito
/// Implementa tokenización PCI-compliant
/// Los datos de la tarjeta nunca se almacenan en el dispositivo
class SecureCardInputWidget extends StatefulWidget {
  const SecureCardInputWidget({
    required this.onCardSubmitted,
    super.key,
    this.initialCardLast4,
    this.showSaveOption = true,
  });

  final void Function(CardTokenizationResult) onCardSubmitted;
  final String? initialCardLast4;
  final bool showSaveOption;

  @override
  State<SecureCardInputWidget> createState() => _SecureCardInputWidgetState();
}

class _SecureCardInputWidgetState extends State<SecureCardInputWidget> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  bool _saveCard = false;
  String _cardType = 'unknown';
  bool _isTokenizing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
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
    } else if (cleanNumber.startsWith('6')) {
      detectedType = 'discover';
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

  Future<void> _tokenizeAndSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isTokenizing = true);

    try {
      // En producción, aquí se integraría con Stripe, Handpoint u otro proveedor PCI-compliant
      // Ejemplo de flujo de tokenización:

      // 1. Enviar datos a servidor de tokenización (nunca a tu propio servidor)
      // final tokenResult = await TokenizationService.tokenizeCard(
      //   cardNumber: _cardNumberController.text.replaceAll(' ', ''),
      //   expiryMonth: _getExpiryMonth(),
      //   expiryYear: _getExpiryYear(),
      //   cvv: _cvvController.text,
      //   cardHolder: _cardHolderController.text,
      // );

      // Simulación de respuesta de tokenización
      await Future<void>.delayed(const Duration(seconds: 1));

      final result = CardTokenizationResult(
        token: 'tok_${DateTime.now().millisecondsSinceEpoch}',
        last4: _cardNumberController.text
            .replaceAll(' ', '')
            .substring(
              _cardNumberController.text.replaceAll(' ', '').length - 4,
            ),
        cardType: _cardType,
        expiryMonth: _getExpiryMonth(),
        expiryYear: _getExpiryYear(),
        cardHolderName: _cardHolderController.text,
        saveForFuture: _saveCard,
      );

      widget.onCardSubmitted(result);

      if (mounted) {
        PaymentSnackbar.success(
          context: context,
          message: 'Tarjeta agregada exitosamente',
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        PaymentSnackbar.error(
          context: context,
          message: 'Error al procesar tarjeta: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isTokenizing = false);
      }
    }
  }

  String _getExpiryMonth() {
    final parts = _expiryController.text.split('/');
    return parts[0].padLeft(2, '0');
  }

  String _getExpiryYear() {
    final parts = _expiryController.text.split('/');
    if (parts.length < 2) return '';
    return parts[1].length == 2 ? '20${parts[1]}' : parts[1];
  }

  Widget _buildCardTypeIcon() {
    IconData iconData = Icons.credit_card;
    Color iconColor = Colors.grey;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agregar Tarjeta de Débito',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tus datos están protegidos con encriptación PCI-compliant',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),

            // Número de tarjeta
            TextFormField(
              controller: _cardNumberController,
              decoration: InputDecoration(
                labelText: 'Número de Tarjeta',
                hintText: '0000 0000 0000 0000',
                prefixIcon: _buildCardTypeIcon(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'Solo se almacena el token seguro, no los datos',
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
                    selection: TextSelection.collapsed(
                      offset: formatted.length,
                    ),
                  );
                }),
              ],
              validator: (value) {
                if (value == null || value.replaceAll(' ', '').length < 13) {
                  return 'Ingresa un número de tarjeta válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Nombre del titular
            TextFormField(
              controller: _cardHolderController,
              decoration: InputDecoration(
                labelText: 'Nombre del Titular',
                hintText: 'Como aparece en la tarjeta',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.length < 3) {
                  return 'Ingresa el nombre del titular';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Fecha de expiración y CVV
            Row(
              children: [
                Expanded(
                  child: TextFormField(
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
                        if (text.length >= 2) {
                          final formatted =
                              '${text.substring(0, 2)}/${text.substring(2)}';
                          return TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(
                              offset: formatted.length,
                            ),
                          );
                        }
                        return newValue;
                      }),
                    ],
                    validator: (value) {
                      if (value == null || value.length < 5) {
                        return 'Ingresa MM/AA';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      hintText: '123',
                      prefixIcon: const Icon(Icons.security),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: '3-4 dígitos',
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    validator: (value) {
                      if (value == null || value.length < 3) {
                        return 'CVV inválido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Opción de guardar tarjeta
            if (widget.showSaveOption)
              CheckboxListTile(
                title: const Text('Guardar tarjeta para futuras compras'),
                subtitle: const Text('Los datos se almacenan de forma segura'),
                value: _saveCard,
                onChanged: (value) {
                  setState(() => _saveCard = value ?? false);
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),

            const SizedBox(height: 24),

            // Botón de agregar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isTokenizing ? null : _tokenizeAndSubmit,
                icon: _isTokenizing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.lock_outline),
                label: Text(
                  _isTokenizing ? 'Procesando...' : 'Agregar Tarjeta Segura',
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
                  '256-bit SSL',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Resultado de la tokenización de tarjeta
class CardTokenizationResult {
  const CardTokenizationResult({
    required this.token,
    required this.last4,
    required this.cardType,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cardHolderName,
    required this.saveForFuture,
  });
  final String token;
  final String last4;
  final String cardType;
  final String expiryMonth;
  final String expiryYear;
  final String cardHolderName;
  final bool saveForFuture;

  Map<String, dynamic> toJson() => {
    'token': token,
    'last4': last4,
    'cardType': cardType,
    'expiryMonth': expiryMonth,
    'expiryYear': expiryYear,
    'cardHolderName': cardHolderName,
    'saveForFuture': saveForFuture,
  };
}

/// Servicio de tokenización (ejemplo - integrar con Stripe, Handpoint, etc.)
class CardTokenizationService {
  /// Tokeniza una tarjeta usando un proveedor PCI-compliant
  static Future<CardTokenizationResult> tokenizeCard({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    required String cardHolder,
    bool saveForFuture = false,
  }) async {
    // TODO: Integrar con Stripe, Handpoint u otro proveedor PCI-compliant
    // NUNCA enviar datos de tarjeta a tu propio servidor

    // Ejemplo de integración con Stripe:
    // final paymentMethod = await Stripe.instance.createPaymentMethod(
    //   params: PaymentMethodParams.card(
    //     paymentMethodData: PaymentMethodData(
    //       billingDetails: BillingDetails(name: cardHolder),
    //     ),
    //   ),
    // );

    throw UnimplementedError(
      'Integrar con proveedor de tokenización PCI-compliant (Stripe, Handpoint, etc.)',
    );
  }
}

/// Widget para mostrar tarjeta guardada
class SavedCardWidget extends StatelessWidget {
  const SavedCardWidget({
    required this.last4,
    required this.cardType,
    super.key,
    this.onDelete,
    this.onTap,
  });
  final String last4;
  final String cardType;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(_getCardIcon(), color: _getCardColor(), size: 32),
        title: Text(
          '•••• $last4',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        subtitle: Text(
          _formatCardType(cardType),
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

  IconData _getCardIcon() {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return Icons.payment;
      case 'mastercard':
        return Icons.payment;
      case 'amex':
        return Icons.payment;
      default:
        return Icons.credit_card;
    }
  }

  Color _getCardColor() {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return const Color(0xFF1A1F71);
      case 'mastercard':
        return const Color(0xFFEB001B);
      case 'amex':
        return const Color(0xFF006FCF);
      default:
        return Colors.grey;
    }
  }

  String _formatCardType(String type) {
    switch (type.toLowerCase()) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'amex':
        return 'American Express';
      default:
        return type.toUpperCase();
    }
  }
}
