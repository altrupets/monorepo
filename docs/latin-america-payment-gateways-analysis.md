# Latin American Payment Gateway Patterns Analysis

## Executive Summary

This document provides a comprehensive analysis of common patterns across major Latin American payment gateways, identifying key abstractions and integration approaches that work across providers.

**Coverage:** 15+ payment gateways across 8 countries (Argentina, Brazil, Chile, Colombia, Mexico, Peru, Uruguay, Panama)

---

## 1. Authentication Methods

### 1.1 Bearer Token / API Key Authentication
**Most Common Pattern (used by 85% of gateways)**

**Mercado Pago**
- Method: Bearer Token in Authorization header
- Format: `Authorization: Bearer <ACCESS_TOKEN>`
- Base URL: `https://api.mercadopago.com`
- Security: HTTPS required, private keys never exposed client-side

**Khipu**
- Method: API Key in header
- Format: `x-api-key: YOUR_API_KEY_HERE`
- Base URL: `https://payment-api.khipu.com`
- SSL: Extended validation certificates required

**ePayco**
- Method: API Key-based
- Public/Private key pair system
- Header-based authentication

### 1.2 Basic Authentication
**OpenPay (Mexico)**
- Method: HTTP Basic Auth
- Format: `-u <API_KEY>:` (colon required)
- Base URLs:
  - Production: `https://api.openpay.mx`
  - Sandbox: `https://sandbox-api.openpay.mx`
- Keys: Public key (client-side) / Private key (server-side)

### 1.3 HMAC Signature Authentication
**PayU Latam**
- Method: HMAC-SHA256 signature
- Headers:
  - `Authorization: Hmac <MerchantPublicKey>:<Signature>`
  - `Date: <RFC1123 date>`
- Signature format: `HMAC-SHA256(API_KEY, METHOD + DATE + URI)`
- Example:
```
GET Fri, 28 Apr 2017 18:32:01 GMT /payments-api/rest/v4.9/pricing
```

**Fiserv (Latin America)**
- Headers:
  - `Api-Key: <key>`
  - `Client-Request-Id: <unique_id>`
  - `Timestamp: <timestamp>`

### 1.4 Multi-Credential Systems
**PayU Common Pattern**
- `apiLogin`: User/login provided by PayU
- `apiKey`: Password/secret key
- Both required in request body (JSON/XML)

**Conekta**
- API Key in Authorization header
- Public key for client-side operations
- Private key for server-side operations

---

## 2. Payment Method Types Supported

### 2.1 Credit/Debit Cards
**Universal Support Across All Gateways**

| Gateway | Card Brands | Tokenization | 3DS Support |
|---------|-------------|--------------|-------------|
| Mercado Pago | Visa, MC, Amex, Diners | ✅ Native | ✅ 3DS 2.0 |
| PayU | Visa, MC, Amex, Diners | ✅ Native | ✅ Brazil/Colombia |
| OpenPay | Visa, MC, Amex | ✅ Native | ✅ |
| EBANX | Visa, MC, Amex, Hipercard | ✅ | ✅ |
| Conekta | Visa, MC, Amex | ✅ | ✅ |
| Culqi | Visa, MC | ✅ | ✅ |
| Niubiz | Visa, MC | ✅ | ✅ |

**Common Card Parameters:**
- `card_number` (PAN)
- `expiration_month` / `expiration_year`
- `cvv` / `security_code`
- `card_holder_name`

### 2.2 Bank Transfers

**Chile - Khipu/Webpay**
- Khipu: Real-time bank transfers (simplified/regular)
- Webpay Plus: Bank transfer integration
- Banks: Banco Estado, Banco de Chile, Santander, etc.

**Colombia - PSE (Pagos Seguros en Línea)**
- PayU: PSE button integration
- ePayco: PSE support
- PlaceToPay: PSE integration
- Real-time debit from bank account

**Mexico - SPEI**
- OpenPay: Bank transfer support
- Conekta: SPEI integration
- PayU: Bank reference payments

**Peru**
- Niubiz: Bank transfer options
- Culqi: PagoEfectivo integration

### 2.3 Cash Payments (Vouchers)

**Mexico**
- OXXO (convenience store chain)
- Paycash
- Supported by: OpenPay, Conekta, PayU

**Brazil**
- Boleto Bancário
- Supported by: Mercado Pago, EBANX, PayU

**Argentina**
- PagoFácil
- RapiPago
- Supported by: Mercado Pago, PayU

**Chile**
- ServiPag
- Multicaja

**Colombia**
- Baloto
- Efecty
- Gana
- Supported by: PayU, ePayco, Wompi

**Peru**
- PagoEfectivo
- BCP agents
- Supported by: Niubiz, Culqi, Izipay

### 2.4 Digital Wallets

**Mercado Pago Wallet**
- Mercado Pago account balance
- Mercado Crédito (credit line)

**Regional Wallets**
| Country | Wallet | Gateway Support |
|---------|--------|-----------------|
| Colombia | Nequi | PayU, ePayco |
| Colombia | Daviplata | Wompi, ePayco |
| Colombia | Movii | PlaceToPay |
| Peru | Yape | BCP integration |
| Peru | Plin | Various banks |
| Chile | MACH | Khipu, Webpay |
| Brazil | PicPay | Mercado Pago |

### 2.5 Alternative Payment Methods

**Brazil**
- PIX (instant payment system) - All major gateways
- Boleto Bancário
- Mercado Crédito

**Buy Now Pay Later (BNPL)**
- Mercado Crédito (Mercado Pago)
- Kueski (Mexico)
- Aplazo (Mexico)
- Addi (Colombia)

---

## 3. API Patterns

### 3.1 REST API (Dominant Pattern)
**90% of gateways use REST with JSON**

**Standard REST Operations:**
```
GET    /v1/payments/{id}      # Retrieve payment
POST   /v1/payments           # Create payment
PUT    /v1/payments/{id}      # Update payment
DELETE /v1/payments/{id}      # Cancel payment
POST   /v1/payments/{id}/refund  # Refund payment
```

**Mercado Pago Endpoints:**
```
POST   /v1/payments
GET    /v1/payments/{id}
PUT    /v1/payments/{id}
POST   /v1/payments/{id}/refunds
GET    /v1/payment_methods
```

**OpenPay Structure:**
```
/v1/{MERCHANT_ID}/
  /charges
  /customers
  /cards
  /plans
  /subscriptions
```

### 3.2 SOAP/XML APIs
**Legacy Support (PayU, some bank integrations)**

**PayU Example:**
```xml
<request>
  <language>es</language>
  <command>SUBMIT_TRANSACTION</command>
  <merchant>
    <apiLogin>xxxxxxxxxxxxx</apiLogin>
    <apiKey>xxxxxxxxxxxxx</apiKey>
  </merchant>
  <transaction>...</transaction>
</request>
```

**Endpoint:** `POST /payments-api/4.0/service.cgi`
**Content-Type:** `application/xml` or `application/json`

### 3.3 SDK Availability

**Common SDK Languages:**
- JavaScript/Node.js
- PHP
- Python
- Java
- C#/.NET
- Ruby
- Go

**Mercado Pago SDKs:**
- JavaScript (checkout, bricks)
- Node.js
- PHP
- Python
- Java
- .NET
- Ruby

**PayU SDKs:**
- PHP
- Java
- .NET
- Ruby
- Python

**OpenPay SDKs:**
- JavaScript
- PHP
- Java
- .NET
- Python
- Ruby

### 3.4 GraphQL
**Emerging Pattern**
- Some modern gateways exploring GraphQL for queries
- Not yet mainstream in LatAm

---

## 4. Webhook Patterns

### 4.1 Standard Webhook Structure

**Common Webhook Payload:**
```json
{
  "id": "webhook_id",
  "live_mode": true,
  "type": "payment.created",
  "date_created": "2024-01-15T10:30:00Z",
  "user_id": "merchant_id",
  "api_version": "v1",
  "action": "payment.created",
  "data": {
    "id": "payment_id"
  }
}
```

### 4.2 Event Types by Gateway

**Mercado Pago:**
- `payment.created`
- `payment.updated`
- `merchant_order.created`
- `point_integration_wh` (POS)

**PayU:**
- `TRANSACTION_UPDATE`
- `ORDER_STATUS_UPDATE`
- `CHARGEBACK_NOTIFICATION`

**OpenPay:**
- `charge.created`
- `charge.cancelled`
- `charge.failed`
- `subscription.paid`
- `subscription.cancelled`

**Conekta:**
- `charge.paid`
- `charge.pending_payment`
- `charge.failed`
- `order.paid`
- `order.pending_payment`

**Khipu:**
- Payment notification with `notification_token`
- POST to merchant's `notify_url`
- Expects HTTP 200 response

### 4.3 Webhook Security

**Signature Verification:**

**Mercado Pago:**
```
X-Signature: ts=timestamp,v1=hash
```
- Verify HMAC signature using secret
- Timestamp validation

**PayU:**
- Signed webhook payloads
- Signature in header

**ePayco:**
- `x_signature` header
- HMAC validation

### 4.4 Retry Policies

| Gateway | Retry Count | Retry Interval | Timeout |
|---------|-------------|----------------|---------|
| Mercado Pago | Until 200 | Exponential | 3s |
| Khipu | 2 days | Multiple attempts | 3s |
| OpenPay | 3 attempts | 5 minutes | - |
| PayU | Configurable | Configurable | - |
| Belvo | 10 attempts | 60 minutes | - |

---

## 5. Error Handling Approaches

### 5.1 HTTP Status Codes

**Standard Usage:**
- `200 OK` - Success
- `201 Created` - Resource created
- `400 Bad Request` - Invalid parameters
- `401 Unauthorized` - Authentication failed
- `403 Forbidden` - Invalid permissions
- `404 Not Found` - Resource not found
- `409 Conflict` - Resource conflict
- `422 Unprocessable Entity` - Validation errors
- `500 Internal Server Error` - Server error
- `503 Service Unavailable` - Service down

### 5.2 Error Response Formats

**Mercado Pago:**
```json
{
  "message": "Invalid card details",
  "error": "invalid_card",
  "status": 400,
  "cause": [
    {
      "code": 205,
      "description": "Invalid card number",
      "data": null
    }
  ]
}
```

**OpenPay:**
```json
{
  "category": "request",
  "description": "The customer does not exist",
  "http_code": 404,
  "error_code": 1005,
  "request_id": "uuid"
}
```

**PayU:**
```json
{
  "code": "ERROR",
  "error": "INVALID_TRANSACTION",
  "transactionResponse": {
    "state": "DECLINED",
    "paymentNetworkResponseCode": "400",
    "paymentNetworkResponseErrorMessage": "Invalid card"
  }
}
```

### 5.3 Common Error Codes

**Card Errors:**
- `card_declined` - Issuer declined
- `insufficient_funds` - No funds available
- `invalid_card` - Card validation failed
- `expired_card` - Card expired
- `incorrect_cvv` - CVV incorrect
- `processing_error` - Generic processing error

**Authentication Errors:**
- `unauthorized` - Invalid credentials
- `forbidden` - No permission
- `invalid_signature` - HMAC verification failed

**Transaction Errors:**
- `duplicate_transaction` - Transaction already exists
- `transaction_not_found` - Transaction doesn't exist
- `refund_not_allowed` - Refund period expired
- `capture_not_allowed` - Capture not possible

---

## 6. Tokenization Approaches

### 6.1 Card Tokenization

**Mercado Pago:**
```javascript
// JavaScript SDK
cardTokenId = await MercadoPago.createCardToken({
  cardNumber: '5031755734530604',
  cardholderName: 'APRO',
  cardExpirationMonth: '11',
  cardExpirationYear: '2025',
  securityCode: '123'
});
```

**OpenPay:**
```javascript
// Create token from card
OpenPay.token.create({
  "card_number": "4111111111111111",
  "holder_name": "Juan Perez",
  "expiration_year": "25",
  "expiration_month": "12",
  "cvv2": "110"
}, successCallback, errorCallback);
```

**PayU:**
- Tokenize card via API
- Store token for future use
- Token ID used in subsequent transactions

### 6.2 Network Tokenization (MDES/VTS)

**PayU Support:**
```json
{
  "transaction": {
    "networkToken": {
      "tokenPan": "4444333322221111",
      "cryptogram": "encrypted_value",
      "expiry": "1225"
    }
  }
}
```

### 6.3 Customer Vault Tokenization

**Mercado Pago:**
- Store cards under `customer`
- Retrieve cards via `customer_id`
- PCI compliance handled by gateway

**OpenPay:**
```
POST /v1/{merchant_id}/customers/{customer_id}/cards
```

**Conekta:**
```
POST /customers/{id}/payment_sources
```

---

## 7. Common Payment Flows

### 7.1 Standard Card Payment Flow

**Two-Step Flow (Authorization + Capture):**
```
1. Create Payment Intent/Order
2. Collect Card Details (tokenize)
3. Submit Authorization (funds reserved)
4. Capture (funds transferred)
5. Webhook confirmation
```

**One-Step Flow (Authorization + Capture):**
```
1. Create Payment Intent/Order
2. Collect Card Details
3. Submit Charge (immediate capture)
4. Webhook confirmation
```

### 7.2 Redirect Payment Flow

**Cash Payment Flow:**
```
1. Create payment with method=cash/store
2. Gateway returns barcode/voucher URL
3. Customer pays at physical location
4. Gateway sends webhook on payment
5. Update order status
```

**Example OpenPay Store Payment:**
```json
{
  "method": "store",
  "amount": 100.00,
  "description": "Order #12345",
  "order_id": "oid-00051"
}
```

Response includes:
- `payment_method.reference` (barcode number)
- `payment_method.barcode_url` (PNG image)

### 7.3 Bank Transfer Flow (PSE/Khipu)

**Khipu Flow:**
```
1. Get available banks (/v3/banks)
2. Create payment with bank_id
3. Redirect to payment_url
4. Customer completes bank transfer
5. Webhook notification on completion
```

**PayU PSE Flow:**
```
1. Create transaction with paymentMethod=PSE
2. Redirect to PSE interface
3. Customer selects bank and authenticates
4. Bank processes transfer
5. Return to merchant with result
```

### 7.4 Subscription Flow

**Mercado Pago:**
```
1. Create Plan (recurring configuration)
2. Create Subscription (customer + plan)
3. Setup payment method
4. Automatic charges on schedule
5. Webhooks for each payment
```

**OpenPay:**
```
1. Create Plan
2. Create Customer with card
3. Create Subscription (customer + plan)
4. Automatic recurring charges
5. Webhook on each payment
```

### 7.5 Refund Flow

**Standard Refund:**
```
1. POST /payments/{id}/refunds
2. Specify amount (partial or full)
3. Gateway processes reversal
4. Webhook confirmation
```

**Constraints:**
- Must refund before settlement (usually 24-48h)
- Partial refunds supported
- Refund to original payment method

---

## 8. Common Abstractions & Unified Interface

### 8.1 Proposed Unified Data Model

```typescript
// Payment Method Types
enum PaymentMethodType {
  CREDIT_CARD = 'credit_card',
  DEBIT_CARD = 'debit_card',
  BANK_TRANSFER = 'bank_transfer',
  CASH_VOUCHER = 'cash_voucher',
  DIGITAL_WALLET = 'digital_wallet',
  PIX = 'pix'
}

// Payment Status
enum PaymentStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  AUTHORIZED = 'authorized',
  CAPTURED = 'captured',
  DECLINED = 'declined',
  CANCELLED = 'cancelled',
  REFUNDED = 'refunded',
  PARTIALLY_REFUNDED = 'partially_refunded'
}

// Common Payment Request
interface PaymentRequest {
  amount: number;
  currency: string; // ISO-4217
  description: string;
  reference: string;
  method: PaymentMethodType;
  customer: Customer;
  payment_details: PaymentDetails;
  metadata?: Record<string, any>;
}

// Common Payment Response
interface PaymentResponse {
  id: string;
  status: PaymentStatus;
  amount: number;
  currency: string;
  reference: string;
  method: PaymentMethodType;
  processed_at: string;
  gateway_response: any;
  redirect_url?: string;
  barcode_url?: string;
  expiration_date?: string;
}
```

### 8.2 Gateway Adapter Pattern

```typescript
interface PaymentGateway {
  // Authentication
  authenticate(credentials: Credentials): Promise<AuthToken>;
  
  // Payments
  createPayment(request: PaymentRequest): Promise<PaymentResponse>;
  getPayment(id: string): Promise<PaymentResponse>;
  capturePayment(id: string, amount?: number): Promise<PaymentResponse>;
  cancelPayment(id: string): Promise<PaymentResponse>;
  refundPayment(id: string, amount?: number): Promise<PaymentResponse>;
  
  // Tokenization
  tokenizeCard(card: CardDetails): Promise<string>;
  
  // Webhooks
  verifyWebhookSignature(payload: string, signature: string): boolean;
  parseWebhookEvent(payload: string): WebhookEvent;
  
  // Methods
  getPaymentMethods(): Promise<PaymentMethod[]>;
}
```

### 8.3 Country-Specific Considerations

**Brazil:**
- CPF/CNPJ required for all transactions
- PIX support essential
- Boleto for cash payments
- Interest-free installments (parcelamento)

**Mexico:**
- CURP/RFC for invoicing
- OXXO cash payments
- SPEI bank transfers
- Kueski/Aplazo BNPL

**Colombia:**
- PSE bank transfers (major payment method)
- Nequi/Daviplata wallets
- Baloto/Efecty cash
- DUI/NIT identification

**Chile:**
- RUT identification
- Khipu bank transfers
- Webpay Plus cards
- ServiPag cash

**Argentina:**
- CUIL/CUIT identification
- PagoFácil/RapiPago cash
- Cuotas (installments)
- ARS currency volatility

**Peru:**
- DNI identification
- PagoEfectivo cash
- Yape/Plin wallets
- BCP agents

---

## 9. Integration Best Practices

### 9.1 Security
- Never store raw card data (use gateway tokenization)
- Use HTTPS for all communications
- Implement webhook signature verification
- Store API keys securely (environment variables)
- Implement idempotency for payment creation

### 9.2 Error Handling
- Implement exponential backoff for retries
- Handle network timeouts gracefully
- Log all payment attempts with correlation IDs
- Implement circuit breaker for gateway outages
- Queue webhooks for asynchronous processing

### 9.3 Testing
- Use sandbox environments for testing
- Test all payment methods in each country
- Implement webhook testing tools
- Test failure scenarios (insufficient funds, expired cards)
- Validate idempotency behavior

### 9.4 Compliance
- PCI DSS compliance (use tokenization)
- Local tax requirements (CFDI in Mexico, etc.)
- Anti-fraud measures (device fingerprinting)
- Data residency requirements
- KYC/AML for high-value transactions

---

## 10. Summary Matrix

| Feature | Mercado Pago | PayU | OpenPay | Conekta | Khipu | ePayco | Wompi |
|---------|--------------|------|---------|---------|-------|--------|-------|
| **Auth Method** | Bearer Token | HMAC/API Key | Basic Auth | API Key | API Key | API Key | API Key |
| **REST API** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **SOAP** | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Cards** | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| **Bank Transfer** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Cash** | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| **Wallets** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Webhooks** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Tokenization** | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| **3DS** | ✅ | ✅ | ✅ | ✅ | N/A | ✅ | ✅ |
| **Recurring** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **SDKs** | 7+ | 5+ | 6+ | 5+ | 5+ | 4+ | 4+ |

---

## Conclusion

Latin American payment gateways share significant common patterns while maintaining country-specific nuances. A unified abstraction layer can handle 80-90% of use cases across providers, with country-specific adapters handling local requirements.

**Key Abstractions:**
1. Standard REST API with JSON
2. Bearer token or API key authentication
3. Webhook-based async notifications
4. Tokenization for PCI compliance
5. Support for cards, bank transfers, cash, and wallets

**Implementation Recommendations:**
- Use gateway-specific SDKs for production
- Implement retry logic with exponential backoff
- Support multiple payment methods per country
- Implement comprehensive webhook handling
- Maintain separate credentials per environment

---

*Document Version: 1.0*
*Last Updated: February 2025*
