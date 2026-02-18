# LATAM Payments Changelog

All notable changes to this payment package will be documented in this file.

## [0.1.0] - 2026-02-18

### Added
- **Costa Rica Gateways:**
  - OnvoPayPaymentGateway - Cards, SINPE
  - TilopayPaymentGateway - Cards, SINPE
  
- **Colombia Gateway:**
  - WompiPaymentGateway - Cards, PSE, Nequi (Colombia & Panama)
  
- **Mexico Gateways:**
  - OpenpayPaymentGateway - Cards, SPEI, OXXO
  - ConektaPaymentGateway - Cards, SPEI, OXXO
  
- **Brazil Gateway:**
  - MercadoPagoPaymentGateway - Cards, PIX, Boleto
  
- **Core Package:**
  - LatinAmericanPaymentGateway interface
  - PaymentGatewayFactory and PaymentGatewayRegistry
  - Core entities: Money, CardToken, PaymentResult, RefundResult, PaymentGatewayConfiguration
  - Core enums: Country, Currency, PaymentMethodType, PaymentStatus

### Supported Countries
| Country | Gateways | Methods |
|---------|----------|---------|
| 🇨🇷 Costa Rica | OnvoPay, Tilopay | Cards, SINPE |
| 🇨🇴 Colombia | Wompi | Cards, PSE, Nequi |
| 🇵🇦 Panama | Wompi | Cards, ACH |
| 🇲🇽 Mexico | OpenPay, Conekta | Cards, SPEI, OXXO |
| 🇧🇷 Brazil | Mercado Pago | Cards, PIX, Boleto |

---

## [Pending] - Package Release

### Planned
- [ ] Extract to separate repository
- [ ] Create example app
- [ ] Publish to pub.dev as `latam_payments`
- [ ] Add comprehensive unit tests
- [ ] Add widget tests for payment forms
- [ ] Add integration tests for payment flows
- [ ] Add mobile testing with Flutter MCP
- [ ] CI/CD pipeline for testing

### Testing Requirements
- [ ] Unit tests for all gateway implementations
- [ ] Unit tests for factory and registry
- [ ] Widget tests for payment form components
- [ ] Integration tests for complete payment flows
- [ ] Device/simulator testing for iOS and Android
