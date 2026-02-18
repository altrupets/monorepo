# 🛠️ Tecnologías

## 📱 Frontend (Mobile)

| Tecnología | Uso |
|-----------|-----|
| **Flutter** | Framework multiplataforma |
| **Riverpod** | State management |
| **Clean Architecture** | Patrón arquitectónico |
| **GraphQL** | API Client |
| **Freezed** | Modelos inmutables |

## ⚙️ Backend

| Tecnología | Uso |
|-----------|-----|
| **NestJS** | Framework Node.js |
| **GraphQL** | API con Apollo Server |
| **PostgreSQL** | Base de datos principal |
| **Valkey** | Cache y queues (Redis-compatible) |
| **Prisma** | ORM |

## ☁️ Infraestructura (OVHCloud)

| Tecnología | Uso |
|-----------|-----|
| **OVHCloud Kubernetes** | Orquestación (QA/Stage/Prod) |
| **OVH Managed PostgreSQL** | Base de datos gestionada |
| **Valkey** | Cache (Redis-compatible) |
| **Terraform/OpenTofu** | IaC |
| **GitHub Actions** | CI/CD |
| **OVHCloud Monitoring** | Observabilidad |

## 🔐 Pagos (latam_payments)

El paquete `latam_payments` implementa una **interfaz unificada** para procesadores de pago regionales:

| País | Gateways | Métodos |
|------|----------|---------|
| 🇨🇷 Costa Rica | OnvoPay, Tilopay | Cards, SINPE |
| 🇨🇴 Colombia | Wompi | Cards, PSE, Nequi |
| 🇲🇽 Mexico | OpenPay, Conekta | Cards, SPEI, OXXO |
| 🇧🇷 Brazil | Mercado Pago | Cards, PIX, Boleto |
