# Especificación de Requisitos Software: AltruPets

## 1. Introducción

### 1.1. Propósito

Este documento de Especificación de Requisitos Software (ERS) define los requisitos funcionales y no funcionales para el sistema AltruPets, una plataforma integral de protección animal basada en arquitectura de microservicios cloud-native. Este documento está dirigido a:

- Arquitectos de software y desarrolladores del sistema
- Equipos de pruebas y control de calidad
- Administradores de sistemas y DevOps
- Stakeholders gubernamentales y organizacionales
- Auditores de cumplimiento regulatorio (PCI DSS, KYC)

### 1.2. Ámbito del Sistema

**Nombre del Sistema:** AltruPets - Plataforma de Protección Animal

**Funcionalidades principales:**
- Coordinación de redes de rescate animal entre centinelas, auxiliares y rescatistas
- Gestión de denuncias anónimas de maltrato animal
- Administración de casas cuna y procesos de adopción
- Sistema de donaciones y gestión financiera con cumplimiento PCI DSS
- Red de veterinarios colaboradores
- Administración gubernamental multi-tenant
- Sistema de reputación y calificaciones

**Funcionalidades excluidas:**
- Procesamiento directo de pagos con tarjetas (delegado a ONVOPay)
- Servicios veterinarios directos (solo coordinación)
- Aplicación de leyes (solo facilitación de reportes)

**Beneficios esperados:**
- Reducción del tiempo de respuesta en rescates de animales vulnerables
- Mejora en la transparencia financiera de organizaciones de rescate
- Fortalecimiento de la red colaborativa de protección animal
- Cumplimiento regulatorio en transacciones financieras
- Optimización de recursos mediante geolocalización inteligente

**Objetivos del sistema:**
- Conectar eficientemente a todos los actores del ecosistema de rescate animal
- Garantizar transparencia y trazabilidad en el uso de donaciones
- Facilitar el cumplimiento de las leyes de maltrato animal de países latinoamericanos
- Proporcionar herramientas de gestión para gobiernos locales

### 1.3. Definiciones, Acrónimos y Abreviaturas

**Roles de Usuario:**
- **Centinela:** Persona que alerta sobre animales abandonados, maltratados, desnutridos, malheridos, enfermos o accidentados que necesitan auxilio inmediato
- **Auxiliar:** Persona con capacidad de brindar auxilio inmediato a animales vulnerables, pero sin capacidad de refugio a largo plazo. Usualmente entrega el animal a un rescatista
- **Rescatista:** Persona con casa cuna que puede rescatar y cuidar animales a largo plazo, proporcionando comida, vacunas, castración y cuidado maternal
- **Adoptante:** Persona que desea adoptar animales rescatados, preferiblemente castrados y vacunados
- **Donante:** Persona física o jurídica que sufraga gastos asociados al rescate animal sin adoptar
- **Veterinario:** Profesional con credenciales para atención médica animal

**Roles Administrativos:**
- **Representante Legal:** Máxima autoridad de una organización registrada
- **Administrador de Usuarios:** Gestiona membresías y roles dentro de una organización
- **Administrador Gubernamental:** Autoridad local que supervisa actividades en su jurisdicción

**Términos Técnicos:**
- **API Gateway:** Punto único de entrada para todas las solicitudes del frontend
- **CQRS:** Command Query Responsibility Segregation - Separación de comandos y consultas
- **Event Sourcing:** Patrón de almacenamiento de eventos para auditoría
- **gRPC:** Protocolo de comunicación entre microservicios
- **JWT:** JSON Web Token para autenticación
- **KYC:** Know Your Customer - Conocimiento del cliente para cumplimiento regulatorio
- **RBAC:** Role-Based Access Control - Control de acceso basado en roles
- **Saga Pattern:** Patrón para transacciones distribuidas
- **WebSocket:** Protocolo para comunicación en tiempo real

**Acrónimos:**
- **PCI DSS:** Payment Card Industry Data Security Standard
- **SUGEF:** Superintendencia General de Entidades Financieras
- **ONVOPay:** Pasarela de pagos integrada
- **PostGIS:** Extensión geoespacial de PostgreSQL
- **OTel:** OpenTelemetry
- **OTLP:** OpenTelemetry Protocol
- **Loki:** Sistema de logs de Grafana
- **Tempo:** Backend de trazas de Grafana
- **CI/CD:** Continuous Integration/Continuous Deployment
- **IaC:** Infrastructure as Code
- **SaaS:** Software as a Service

### 1.4. Referencias

- Leyes de Maltrato Animal de países latinoamericanos (ej: Ley N° 9458 de Costa Rica)
- Estándar PCI DSS versión 4.0
- Regulaciones financieras locales (ej: SUGEF en Costa Rica)
- Principios de 12-Factor App
- Estándar IEEE 830-1998 para especificaciones de requisitos software
- Documentación técnica de pasarelas de pago regionales
- Kubernetes Documentation v1.28
- OpenShift Container Platform Documentation

### 1.5. Visión General del Documento

Este documento está organizado en las siguientes secciones:

- **Sección 2 (Descripción General):** Proporciona el contexto del sistema, incluyendo perspectiva del producto, funciones principales, características de usuarios, restricciones y dependencias
- **Sección 3 (Requisitos Específicos):** Detalla los requisitos funcionales organizados por tipos de usuario, requisitos de rendimiento, restricciones de diseño y atributos de calidad
- **Sección 4 (Apéndices):** Incluye información complementaria sobre arquitectura técnica y diagramas del sistema

## 2. Descripción General

### 2.1. Perspectiva del Producto

AltruPets es un sistema independiente basado en arquitectura de microservicios cloud-native que opera como una plataforma SaaS. El sistema se compone de dos componentes principales:

**Frontend (Aplicación Móvil Flutter):**
- Aplicación nativa multiplataforma (iOS/Android)
- Interfaz de usuario para todos los tipos de usuarios
- Comunicación con backend a través de API Gateway
- Capacidades offline para funciones críticas

**Backend (Microservicios Distribuidos):**
- 9 microservicios especializados ejecutándose en Kubernetes/OpenShift
- Bases de datos independientes por servicio (Database per Service)
- Comunicación asíncrona mediante eventos y message brokers
- Integración con servicios externos (ONVOPay, mapas, notificaciones push)

**Interfaces Externas:**
- ONVOPay para procesamiento de pagos
- Google Maps/MapBox para geolocalización
- Firebase para notificaciones push
- Servicios gubernamentales para reportes oficiales

### 2.2. Funciones del Producto

El sistema proporciona las siguientes funciones principales:

**Gestión de Usuarios y Organizaciones:**
- Registro y autenticación de usuarios individuales y organizacionales
- Control de acceso basado en roles (RBAC)
- Gestión de membresías organizacionales

**Red de Rescate Animal:**
- Denuncias anónimas de maltrato animal
- Coordinación entre centinelas, auxiliares y rescatistas
- Gestión de casas cuna e inventarios de animales
- Proceso de adopción con contratos digitales

**Sistema Financiero:**
- Donaciones individuales y suscripciones recurrentes
- Gestión contable para rescatistas
- Cumplimiento regulatorio (KYC, PCI DSS)
- Transparencia financiera y auditoría

**Red Veterinaria:**
- Directorio de veterinarios colaboradores
- Coordinación de atención médica
- Historial médico de animales

**Comunicación y Coordinación:**
- Chat interno en tiempo real
- Sistema de notificaciones inteligentes
- Geolocalización para optimización de rescates

**Administración Gubernamental:**
- Supervisión jurisdiccional multi-tenant
- Mediación de conflictos
- Reportes de transparencia y métricas de impacto

### 2.3. Características de los Usuarios

**Centinelas:**
- Nivel educativo: Diverso (primaria a universitario)
- Experiencia técnica: Básica a intermedia con dispositivos móviles
- Motivación: Alta sensibilidad hacia el bienestar animal
- Frecuencia de uso: Esporádica, basada en avistamientos

**Auxiliares:**
- Nivel educativo: Secundaria a universitario
- Experiencia técnica: Intermedia con aplicaciones móviles
- Capacidades: Transporte y tiempo disponible para rescates inmediatos
- Frecuencia de uso: Regular, según disponibilidad

**Rescatistas:**
- Nivel educativo: Secundaria a universitario
- Experiencia técnica: Intermedia a avanzada
- Recursos: Casa cuna establecida, recursos financieros
- Frecuencia de uso: Diaria, gestión continua de animales

**Adoptantes:**
- Nivel educativo: Diverso
- Experiencia técnica: Básica a intermedia
- Motivación: Deseo de adoptar mascotas responsablemente
- Frecuencia de uso: Esporádica, durante proceso de adopción

**Donantes:**
- Nivel educativo: Secundaria a universitario
- Experiencia técnica: Básica a intermedia
- Recursos: Capacidad financiera para donaciones
- Frecuencia de uso: Esporádica a regular según tipo de donación

**Veterinarios:**
- Nivel educativo: Universitario (título profesional)
- Experiencia técnica: Intermedia a avanzada
- Credenciales: Colegiado y licencias sanitarias
- Frecuencia de uso: Regular, según demanda de servicios

**Administradores Gubernamentales:**
- Nivel educativo: Universitario
- Experiencia técnica: Intermedia a avanzada
- Autoridad: Jurisdiccional sobre territorio específico
- Frecuencia de uso: Diaria, supervisión continua

### 2.4. Restricciones

**Restricciones Regulatorias:**
- Cumplimiento obligatorio con estándar PCI DSS nivel 1
- Implementación de controles KYC según regulaciones SUGEF
- Adherencia a las leyes de maltrato animal del país de operación
- Protección de datos personales según legislación local

**Restricciones Técnicas:**
- Arquitectura obligatoria de microservicios en Kubernetes/OpenShift
- Uso exclusivo de ONVOPay para procesamiento de pagos con tarjetas
- Implementación de principios 12-Factor App
- Comunicación encriptada TLS 1.3 entre todos los componentes

**Restricciones de Integración:**
- API de ONVOPay para transacciones financieras
- Firebase Admin SDK para notificaciones push
- Google Maps API o MapBox para servicios de geolocalización
- Limitaciones de rate limiting en APIs externas

**Restricciones de Infraestructura:**
- Despliegue en contenedores Docker/Podman
- Orquestación mediante Kubernetes o Red Hat OpenShift
- Almacenamiento de datos en bases de datos relacionales y NoSQL
- Implementación de observabilidad con OpenTelemetry (OTLP) usando Prometheus (métricas), Loki (logs) y Grafana Tempo (trazas)

### 2.5. Suposiciones y Dependencias

**Suposiciones de Infraestructura:**
- Disponibilidad de clúster Kubernetes/OpenShift para despliegue
- Conectividad estable a internet para servicios cloud
- Capacidad de almacenamiento distribuido para bases de datos
- Ancho de banda suficiente para comunicación entre microservicios

**Dependencias Externas:**
- Disponibilidad continua de la API de ONVOPay
- Servicios de Firebase para notificaciones push
- APIs de mapas (Google Maps/MapBox) para geolocalización
- Conectividad móvil de los usuarios finales

**Suposiciones de Usuario:**
- Usuarios tienen dispositivos móviles iOS o Android actualizados
- Acceso a internet móvil o WiFi para uso de la aplicación
- Capacidad básica de navegación en aplicaciones móviles
- Voluntad de proporcionar información personal para verificación KYC

**Dependencias de Desarrollo:**
- Equipo con experiencia en Flutter y arquitecturas de microservicios
- Herramientas de CI/CD para despliegue automatizado
- Acceso a entornos de desarrollo, pruebas y producción
- Certificaciones de seguridad para cumplimiento PCI DSS

### 2.6. Requisitos Futuros

**Expansión Geográfica:**
- Adaptación a regulaciones de otros países latinoamericanos
- Integración con pasarelas de pago locales adicionales
- Soporte para múltiples idiomas y monedas

**Funcionalidades Avanzadas:**
- Inteligencia artificial para detección automática de maltrato en imágenes
- Integración con IoT para monitoreo de casas cuna
- Blockchain para trazabilidad completa de donaciones
- Realidad aumentada para identificación de especies

**Integraciones Adicionales:**
- APIs gubernamentales para reportes automáticos
- Sistemas de gestión veterinaria existentes
- Plataformas de redes sociales para difusión
- Sistemas de contabilidad empresarial

**Optimizaciones Técnicas:**
- Implementación de edge computing para mejor rendimiento
- Machine learning para optimización de rutas de rescate
- Análisis predictivo para prevención de abandono animal
- Automatización completa de procesos administrativos

## 3. Requisitos Específicos

### 3.1. Funciones

*Los requisitos funcionales se organizan por prioridad de implementación y tipos de usuario para facilitar la comprensión y trazabilidad de cada rol en el sistema.*

#### 3.1.1. PRIORIDAD 1: Coordinación de Redes de Rescate Animal

*Esta funcionalidad es crítica para el primer sprint y release del sistema, estableciendo la coordinación básica entre centinelas, auxiliares y rescatistas.*

**REQ-COORD-001: Flujo Básico de Rescate**

CUANDO un centinela identifique un animal vulnerable ENTONCES el sistema DEBERÁ:
- Permitir crear una alerta con ubicación GPS, descripción, fotografías y nivel de urgencia
- Notificar automáticamente a auxiliares en un radio de 5km
- Establecer comunicación directa entre centinela y auxiliar mediante chat interno

**REQ-COORD-002: Respuesta de Auxiliares**

CUANDO un auxiliar reciba una alerta ENTONCES el sistema DEBERÁ:
- Mostrar notificación push inmediata con detalles del caso
- Permitir aceptar o declinar la solicitud con justificación
- Proporcionar navegación GPS al lugar del incidente

**REQ-COORD-003: Transferencia a Rescatistas**

CUANDO un auxiliar brinde auxilio inmediato a un animal ENTONCES el sistema DEBERÁ:
- Mostrar rescatistas disponibles con casa cuna en un radio de 15km inicialmente
- Permitir documentar el estado del animal con fotografías
- Facilitar la coordinación para transferencia del animal al rescatista

**REQ-COORD-004: Seguimiento de Casos**

CUANDO se inicie un proceso de rescate ENTONCES el sistema DEBERÁ:
- Generar código de seguimiento único
- Mantener historial completo de todas las interacciones
- Permitir consultar estado del caso a todos los participantes

#### 3.1.2. Funciones para Centinelas

**REQ-CEN-001: Registro de Centinelas**

CUANDO una persona desee registrarse como centinela ENTONCES el sistema DEBERÁ permitir registro con datos personales básicos, ubicación y motivación para el rescate animal

**REQ-CEN-002: Creación de Alertas**

CUANDO un centinela identifique un animal vulnerable ENTONCES el sistema DEBERÁ permitir crear una alerta con ubicación GPS, descripción del estado del animal, fotografías opcionales y nivel de urgencia

**REQ-CEN-003: Seguimiento de Alertas**

CUANDO un centinela cree una alerta ENTONCES el sistema DEBERÁ generar un código de seguimiento único y permitir consultar el estado de la alerta

**REQ-CEN-004: Comunicación con Auxiliares**

CUANDO un auxiliar responda a una alerta ENTONCES el sistema DEBERÁ establecer comunicación directa entre centinela y auxiliar mediante chat interno

#### 3.2.2. Funciones para Auxiliares

**REQ-AUX-001: Registro de Auxiliares**

CUANDO una persona desee registrarse como auxiliar ENTONCES el sistema DEBERÁ verificar capacidad de transporte, disponibilidad horaria y experiencia en manejo de animales

**REQ-AUX-002: Recepción de Alertas**

CUANDO haya una alerta en el área del auxiliar ENTONCES el sistema DEBERÁ enviar notificación push inmediata con detalles del caso y distancia

**REQ-AUX-003: Aceptación de Rescates**

CUANDO un auxiliar acepte una alerta ENTONCES el sistema DEBERÁ proporcionar información de contacto del centinela y navegación GPS al lugar

**REQ-AUX-004: Coordinación con Rescatistas**

CUANDO un auxiliar brinde auxilio inmediato a un animal ENTONCES el sistema DEBERÁ mostrar rescatistas disponibles cercanos y facilitar la transferencia del animal

**REQ-AUX-005: Documentación de Rescate**

CUANDO un auxiliar complete el auxilio ENTONCES el sistema DEBERÁ permitir documentar el estado del animal con fotografías y descripción para el rescatista

**REQ-AUX-006: Solicitud de Crowdfunding para Gastos de Transporte**

CUANDO un auxiliar acepte una alerta y no tenga transporte propio viable ENTONCES el sistema DEBERÁ permitir crear una "vaca" o "banca" (crowdfunding) para cubrir gastos de transporte con:
- Descripción del caso específico y animal a rescatar
- Desglose de costos estimados (viaje ida, viaje vuelta con Uber Pets/similar)
- Meta de recaudación específica y plazo límite
- Ubicaciones de origen y destino para validar costos
- Fotografías del animal reportado por el centinela

**REQ-AUX-006A: Validación automática de costos de transporte**

CUANDO se cree una solicitud de crowdfunding para transporte ENTONCES el sistema DEBERÁ:
- Calcular automáticamente costos estimados usando APIs de Uber/Didi/inDriver
- Verificar que la meta de recaudación sea razonable (máximo 150% del costo estimado)
- Validar que el auxiliar no tenga transporte propio registrado
- Confirmar que la distancia justifique el gasto (mínimo 2km del domicilio del auxiliar)

**REQ-AUX-006B: Gestión de fondos de crowdfunding**

CUANDO se recauden fondos para transporte ENTONCES el sistema DEBERÁ:
- Transferir automáticamente los fondos al auxiliar una vez alcanzada la meta
- Devolver donaciones proporcionalmente si no se alcanza la meta en 24 horas
- Requerir comprobantes de gasto (recibos de Uber/taxi) dentro de 48 horas
- Permitir que donantes vean el uso transparente de sus contribuciones

**REQ-AUX-006C: Límites y controles de crowdfunding**

CUANDO un auxiliar solicite crowdfunding ENTONCES el sistema DEBERÁ aplicar:
- Máximo 2 solicitudes de crowdfunding por auxiliar por mes
- Límite máximo de $50 USD (o equivalente local) por solicitud
- Verificación de que el auxiliar haya completado exitosamente rescates previos
- Suspensión temporal si no presenta comprobantes de gasto en solicitudes anteriores

**REQ-AUX-006D: Notificaciones de crowdfunding**

CUANDO se cree una solicitud de crowdfunding ENTONCES el sistema DEBERÁ notificar a:
- Donantes activos en la zona geográfica del rescate
- Otros auxiliares y rescatistas cercanos que puedan contribuir
- Centinela que reportó el caso para que pueda apoyar económicamente
- Comunidad general con filtros de interés en casos de transporte

#### 3.2.3. Funciones para Rescatistas

**REQ-RES-001: Registro de Rescatistas con Contactos de Emergencia Obligatorios**

CUANDO una persona desee registrarse como rescatista ENTONCES el sistema DEBERÁ requerir OBLIGATORIAMENTE:

**Información básica del rescatista:**
- Capacidad de casa cuna (número máximo de animales)
- Experiencia previa en rescate animal (años, casos atendidos)
- Ubicación geográfica precisa de las instalaciones
- Recursos disponibles (económicos, veterinarios, suministros)

**Contactos de emergencia OBLIGATORIOS (no puede completar registro sin estos):**
- **Contacto familiar directo** con acceso físico a las instalaciones
- **Rescatista "padrino"** verificado que pueda asumir todos los animales bajo cuidado
- **Contacto de acceso** con información de llaves, códigos, alarmas y ubicación de suministros

**Contactos de emergencia OPCIONALES (se pueden agregar después):**
- **Veterinario de confianza** (se puede asignar después del primer rescate o mediante recomendaciones del sistema)

**Información de contingencia OBLIGATORIA:**
- Inventario inicial de capacidad de casa cuna
- Protocolos específicos de cuidado por tipo de animal
- Ubicación de suministros médicos y alimentarios
- Instrucciones de emergencia para acceso a instalaciones

**REQ-RES-001A: Validación obligatoria de contactos de emergencia**

CUANDO un rescatista intente completar su registro ENTONCES el sistema DEBERÁ:
- Verificar que TODOS los contactos de emergencia estén completos y validados
- Confirmar que el rescatista "padrino" tenga capacidad disponible para asumir los animales
- Validar que el veterinario de confianza esté registrado en el sistema
- Impedir la activación de la cuenta hasta que todos los contactos estén verificados
- Enviar notificaciones de confirmación a todos los contactos de emergencia

**REQ-RES-001B: Verificación de rescatista "padrino"**

CUANDO se asigne un rescatista "padrino" ENTONCES el sistema DEBERÁ verificar que:
- Tenga experiencia mínima de 2 años como rescatista activo
- Mantenga reputación mínima de 4.0/5.0 estrellas
- Tenga capacidad física adicional para asumir animales de emergencia
- Esté ubicado en radio máximo de 25km del rescatista titular
- Confirme explícitamente su disponibilidad para casos de emergencia

**REQ-RES-001C: Apoyo para encontrar veterinario de confianza**

CUANDO un rescatista no tenga veterinario de confianza asignado ENTONCES el sistema DEBERÁ:
- Mostrar veterinarios registrados en radio de 25km con tarifas preferenciales
- Proporcionar recomendaciones de otros rescatistas en la zona
- Facilitar contacto con la oficina de Bienestar Animal local para recomendaciones oficiales
- Permitir que el rescatista opere sin veterinario asignado por máximo 90 días
- Enviar recordatorios semanales para asignar veterinario de confianza
- Requerir veterinario asignado antes de recibir el tercer animal rescatado

**REQ-RES-001D: Recomendaciones de veterinarios por la comunidad**

CUANDO un rescatista busque veterinario ENTONCES el sistema DEBERÁ mostrar:
- Lista de veterinarios recomendados por otros rescatistas cercanos
- Calificaciones y comentarios de la comunidad sobre cada veterinario
- Tarifas preferenciales disponibles para rescatistas
- Especialidades de cada veterinario (felinos, caninos, exóticos, etc.)
- Disponibilidad para emergencias y horarios de atención

**REQ-RES-001E: Apoyo gubernamental para asignación veterinaria**

CUANDO un rescatista solicite apoyo gubernamental ENTONCES el sistema DEBERÁ:
- Conectar automáticamente con la oficina de Bienestar Animal de su jurisdicción
- Facilitar que el gobierno local proporcione lista de veterinarios colaboradores
- Permitir que el gobierno subsidie parcialmente las primeras consultas veterinarias
- Coordinar con veterinarios que participen en programas gubernamentales de rescate

#### 3.2.3.1. Excepción al Principio de Responsabilidad Única para Rescatistas

**Justificación de múltiples responsabilidades:**

Los rescatistas son la **única excepción** al principio de responsabilidad única porque tienen **autonomía profesional** y **responsabilidad moral completa** sobre el bienestar animal. Esta excepción está **cuidadosamente justificada** porque:

1. **Conocimiento directo del animal**: Son los únicos que conviven día a día con el animal y conocen su estado real
2. **Capacidad de evaluación médica básica**: Tienen experiencia para determinar si pueden manejar cuidados básicos o si requieren veterinario
3. **Responsabilidad legal y moral**: Deben garantizar el bienestar desde el rescate hasta la adopción
4. **Autoridad para tomar decisiones críticas**: Son los únicos que pueden evaluar cuándo un animal está listo para adopción
5. **Conocimiento de situaciones de maltrato**: Por su experiencia, pueden identificar casos que requieren intervención legal

**Tipos de solicitudes que pueden crear los rescatistas:**

1. **"Solicitudes para atención veterinaria"** - Cuando evalúen que el caso requiere atención profesional que excede sus conocimientos/insumos disponibles
2. **"Solicitudes de adopción"** - Cuando evalúen que el animal cumple todos los criterios de adoptabilidad  
3. **"Solicitudes de intervención policial"** - Cuando identifiquen situaciones de maltrato animal o resistencia que requiera autoridad legal

**¿Por qué esta violación es necesaria y justificada?**

- **Eficiencia**: Evita burocracia innecesaria que podría resultar en más sufrimiento animal
- **Expertise**: Los rescatistas tienen el conocimiento y experiencia necesarios para estas evaluaciones
- **Responsabilidad**: Si algo sale mal, la responsabilidad recae claramente en el rescatista
- **Urgencia**: Situaciones de maltrato o emergencias médicas no pueden esperar múltiples aprobaciones

**REQ-RES-002: Gestión de Casa Cuna**

CUANDO un rescatista reciba un animal ENTONCES el sistema DEBERÁ permitir registrar datos médicos, comportamiento, necesidades especiales y fotografías del animal

**REQ-RES-003: Gestión Financiera**

CUANDO un rescatista incurra en gastos ENTONCES el sistema DEBERÁ permitir registrar gastos por categorías: alimentación, veterinaria, medicamentos y otros insumos

**REQ-RES-004: Coordinación Veterinaria**

CUANDO un animal requiera atención médica ENTONCES el sistema DEBERÁ mostrar veterinarios colaboradores cercanos y facilitar la solicitud de atención

**REQ-RES-005: Proceso de Adopción**

CUANDO un animal esté listo para adopción ENTONCES el sistema DEBERÁ permitir publicar el perfil del animal y gestionar solicitudes de adopción

**REQ-RES-006: Recepción de Donaciones**

CUANDO un rescatista reciba donaciones ENTONCES el sistema DEBERÁ registrar automáticamente en el sistema financiero y enviar agradecimiento al donante

**REQ-RES-007: Solicitud de Intervención Policial**

CUANDO un rescatista identifique una situación que requiera intervención policial ENTONCES el sistema DEBERÁ permitir crear una "solicitud de intervención policial" con:
- Descripción detallada de la situación (maltrato, animal amarrado/encerrado, resistencia del propietario)
- Ubicación GPS precisa del incidente
- Evidencia fotográfica o de video
- Referencia legal aplicable (Ley de Maltrato Animal del país)
- Nivel de urgencia (bajo, medio, alto, crítico)
- Solicitud de escolta policial para auxiliares o rescatistas

**REQ-RES-007A: Notificación automática a autoridades policiales**

CUANDO se cree una solicitud de intervención policial ENTONCES el sistema DEBERÁ:
- Notificar automáticamente a la estación de policía de la jurisdicción correspondiente
- Incluir todos los detalles del caso y evidencia adjunta
- Proporcionar información de contacto del rescatista como referencia principal
- Generar código de seguimiento único para el caso

**REQ-RES-007B: Escalamiento por falta de respuesta policial**

CUANDO no haya respuesta policial en los tiempos establecidos ENTONCES el sistema DEBERÁ:
- Escalar automáticamente a supervisores policiales después de 2 horas para casos críticos
- Escalar a supervisores después de 24 horas para casos no críticos
- Notificar al rescatista sobre el estado del escalamiento
- Registrar la falta de respuesta para reportes de transparencia

**REQ-RES-007C: Contacto de referencia para quejas policiales**

CUANDO un oficial de policía se niegue a cumplir con la legislación de maltrato animal ENTONCES:
- El rescatista DEBERÁ ser el contacto de referencia principal para cualquier denuncia
- El sistema DEBERÁ proporcionar al rescatista información legal de respaldo
- Se DEBERÁ registrar la negativa del oficial para reportes a supervisores
- El rescatista podrá reportar la situación a través del sistema para escalamiento administrativo

**REQ-RES-007D: Seguimiento de casos policiales**

CUANDO se active una solicitud de intervención policial ENTONCES el sistema DEBERÁ:
- Permitir al rescatista actualizar el estado del caso
- Registrar la respuesta y acciones tomadas por las autoridades
- Mantener historial completo para auditoría y mejora de procesos
- Generar métricas de efectividad de respuesta policial por jurisdicción

#### 3.2.4. Funciones para Adoptantes

**REQ-ADO-001: Registro de Adoptantes**

CUANDO una persona desee adoptar ENTONCES el sistema DEBERÁ permitir registro con datos personales, preferencias de adopción y experiencia con mascotas

**REQ-ADO-002: Búsqueda de Animales**

CUANDO un adoptante busque mascotas ENTONCES el sistema DEBERÁ mostrar animales disponibles con filtros por especie, edad, tamaño y ubicación

**REQ-ADO-003: Solicitud de Adopción**

CUANDO un adoptante seleccione un animal ENTONCES el sistema DEBERÁ permitir enviar solicitud con información personal y motivación para adopción

**REQ-ADO-004: Proceso de Adopción**

CUANDO se apruebe una adopción ENTONCES el sistema DEBERÁ facilitar la coordinación entre adoptante y rescatista para entrega del animal

**REQ-ADO-005: Seguimiento Post-Adopción**

CUANDO se complete una adopción ENTONCES el sistema DEBERÁ permitir seguimiento opcional del bienestar del animal adoptado

#### 3.2.5. Funciones para Donantes

**REQ-DON-001: Registro de Donantes**

CUANDO una persona desee donar ENTONCES el sistema DEBERÁ permitir registro con información KYC según el tipo y monto de donación

**REQ-DON-002: Donaciones Monetarias**

CUANDO un donante realice donación monetaria ENTONCES el sistema DEBERÁ procesar el pago a través de ONVOPay con cumplimiento PCI DSS

**REQ-DON-003: Donaciones de Insumos**

CUANDO un donante ofrezca insumos ENTONCES el sistema DEBERÁ mostrar necesidades actuales de casas cuna cercanas

**REQ-DON-004: Suscripciones Recurrentes**

CUANDO un donante configure suscripción ENTONCES el sistema DEBERÁ permitir seleccionar frecuencia, monto y casas cuna beneficiarias

**REQ-DON-005: Transparencia de Donaciones**

CUANDO un donante contribuya ENTONCES el sistema DEBERÁ proporcionar seguimiento del uso de fondos y impacto generado

#### 3.2.6. Funciones para Veterinarios

**REQ-VET-001: Registro de Veterinarios**

CUANDO un veterinario se registre ENTONCES el sistema DEBERÁ verificar credenciales profesionales, especialidades y tarifas preferenciales

**REQ-VET-002: Recepción de Solicitudes**

CUANDO un rescatista solicite atención ENTONCES el sistema DEBERÁ notificar a veterinarios cercanos con especialidad requerida

**REQ-VET-003: Gestión de Casos**

CUANDO un veterinario acepte un caso ENTONCES el sistema DEBERÁ proporcionar historial médico del animal y contacto del rescatista

**REQ-VET-004: Registro Médico**

CUANDO un veterinario complete atención ENTONCES el sistema DEBERÁ permitir registrar diagnóstico, tratamiento, medicamentos y seguimiento requerido

**REQ-VET-005: Facturación de Servicios**

CUANDO se complete atención veterinaria ENTONCES el sistema DEBERÁ registrar costos del servicio en el sistema financiero del rescatista

#### 3.2.7. Funciones Administrativas

**REQ-ADM-001: Gestión de Organizaciones**

CUANDO se registre una organización ENTONCES el sistema DEBERÁ crear roles jerárquicos: Representante Legal y Administrador de Usuarios

**REQ-ADM-002: Control de Acceso**

CUANDO un usuario acceda al sistema ENTONCES el sistema DEBERÁ aplicar permisos específicos según su rol y afiliación organizacional

**REQ-ADM-003: Administración Gubernamental Multi-Tenant**

CUANDO un gobierno local contrate el servicio ENTONCES el sistema DEBERÁ implementar tenant específico con segregación ÚNICAMENTE de datos gubernamentales (autorizaciones veterinarias, reportes jurisdiccionales, políticas locales) manteniendo los datos de AltruPets centralizados

**REQ-ADM-004: Mediación de Conflictos Multi-Tenant**

CUANDO se reporte un conflicto ENTONCES el sistema DEBERÁ notificar al administrador gubernamental correspondiente según geolocalización Y segregar los datos de mediación por tenant gubernamental

**REQ-ADM-005: Reportes de Transparencia Multi-Tenant**

CUANDO se requieran reportes oficiales ENTONCES el sistema DEBERÁ generar estadísticas de rescates, uso de fondos y métricas de impacto FILTRADAS por jurisdicción del tenant gubernamental, manteniendo los datos base centralizados

**REQ-ADM-006: Reportes administrativos por Superadministrador de Plataforma**

CUANDO un Superadministrador de Plataforma (SRE) requiera información ENTONCES el sistema DEBERÁ permitir generar reportes administrativos y operativos globales con alcance multi-tenant respetando segregación de datos gubernamentales (`REQ-MT-002`) y aplicando minimización de PII (`REQ-SEC-006`).

**REQ-ADM-007: Reportes oficiales por Auditor Gubernamental/Ambiental**

CUANDO un Auditor Gubernamental o Ambiental (p. ej., municipalidades o SINAC) requiera reportes ENTONCES el sistema DEBERÁ permitir generar reportes oficiales y de auditoría LIMITADOS a su jurisdicción (`REQ-MT-004`, `REQ-JUR-011`) y clasificados por propósito legítimo.

**REQ-ADM-008: Exportación controlada y trazable de reportes**

CUANDO se exporten reportes ENTONCES el sistema DEBERÁ aplicar marca de agua, versionado, registro de auditoría (quién, cuándo, alcance, filtros) y controles anti-exfiltración (por ejemplo, redacción de PII y límites de volumen).

#### 3.2.8. Sistema de Continuidad y Contingencia

**REQ-CONT-001: Detección automática de inactividad**

CUANDO un usuario no responda a solicitudes o no acceda al sistema por más de 7 días ENTONCES el sistema DEBERÁ activar protocolo de detección de inactividad y notificar a contactos de emergencia predefinidos.

**REQ-CONT-002: Contactos de emergencia obligatorios para rescatistas**

CUANDO un rescatista se registre ENTONCES el sistema DEBERÁ requerir obligatoriamente:
- Contacto familiar con acceso a instalaciones
- Rescatista "padrino" que pueda asumir animales
- Veterinario de confianza con historial de animales
- Información de acceso a casa cuna y suministros

**REQ-CONT-003: Contactos de emergencia opcionales para otros roles**

CUANDO usuarios de otros roles se registren ENTONCES el sistema DEBERÁ permitir opcionalmente definir:
- Contacto familiar para notificación
- Usuario backup del mismo rol en la zona

**REQ-CONT-004: Reporte manual de emergencias**

CUANDO se reporte una situación de emergencia de usuario ENTONCES el sistema DEBERÁ permitir reportes a través de:
- Botón "Reportar emergencia de usuario" en la aplicación
- Línea telefónica de emergencia 24/7
- Email de emergencia (continuidad@altrupets.org)
- Chat de soporte integrado

**REQ-CONT-005: Información requerida en reportes de emergencia**

CUANDO se reporte una emergencia ENTONCES el sistema DEBERÁ requerir:
- Nombre del usuario afectado
- Tipo de situación (enfermedad, fallecimiento, mudanza, etc.)
- Ubicación de animales bajo cuidado (si aplica)
- Contacto del reportante
- Nivel de urgencia del caso

**REQ-CONT-006: Protocolo de transferencia para rescatistas**

CUANDO un rescatista no pueda continuar con su rol ENTONCES el sistema DEBERÁ ejecutar automáticamente:
- Notificación inmediata a red de rescatistas cercanos
- Búsqueda de casas cuna disponibles para transferencia
- Traspaso completo de historial médico y documentación
- Transferencia de donaciones activas hacia nuevos cuidadores

**REQ-CONT-007: Escalamiento automático por roles**

CUANDO se detecte inactividad por rol ENTONCES el sistema DEBERÁ aplicar escalamiento específico:
- Centinelas: Redistribución automática de alertas a otros centinelas en zona
- Auxiliares: Búsqueda automática en radio expandido + notificación a supervisores
- Rescatistas: Activación de protocolo de emergencia crítica
- Veterinarios: Notificación a red de veterinarios colaboradores

**REQ-CONT-008: Red de supervisores regionales**

CUANDO se implemente el sistema ENTONCES DEBERÁ incluir supervisores regionales que:
- Coordinen emergencias en su área geográfica específica
- Mantengan lista actualizada de usuarios backup disponibles
- Gestionen transferencias de casos críticos
- Tengan autoridad para activar protocolos de emergencia

**REQ-CONT-009: Sistema de rescatistas "padrinos"**

CUANDO se configure la red de continuidad ENTONCES el sistema DEBERÁ mantener:
- Rescatistas experimentados con capacidad adicional reservada
- Disponibilidad para asumir casos de emergencia
- Entrenamiento especial en transferencias de animales
- Mínimo 3 rescatistas padrinos por cada 10 rescatistas activos

**REQ-CONT-010: Red de veterinarios de emergencia**

CUANDO se requiera continuidad veterinaria ENTONCES el sistema DEBERÁ proporcionar:
- Red de veterinarios disponibles para casos urgentes
- Acceso completo a historiales médicos de animales transferidos
- Tarifas preferenciales para casos de continuidad
- Disponibilidad 24/7 para emergencias críticas

**REQ-CONT-011: Continuidad financiera automática**

CUANDO se transfiera un caso ENTONCES el sistema DEBERÁ:
- Transferir automáticamente donaciones recurrentes al nuevo cuidador
- Notificar a donantes sobre el cambio con transparencia completa
- Honrar compromisos financieros existentes del usuario anterior
- Activar fondo de emergencia para casos críticos sin cobertura

**REQ-CONT-012: Métricas de continuidad**

CUANDO se opere el sistema de continuidad ENTONCES DEBERÁ mantener métricas de:
- Tiempo promedio de transferencia (objetivo: <24 horas para casos críticos)
- Tasa de éxito en reubicación (objetivo: >95% de animales reubicados)
- Cobertura de red backup (objetivo: mínimo 3 usuarios backup por rescatista)
- Cobertura geográfica (objetivo: 100% del territorio con supervisores)

**REQ-CONT-013: Validación de capacidad de backup**

CUANDO se asigne un usuario backup ENTONCES el sistema DEBERÁ verificar:
- Capacidad física y recursos para asumir casos adicionales
- Proximidad geográfica (máximo 25km del usuario principal)
- Experiencia y reputación adecuada para el rol
- Disponibilidad confirmada para emergencias

**REQ-CONT-014: Notificaciones de continuidad**

CUANDO se active un protocolo de continuidad ENTONCES el sistema DEBERÁ notificar:
- Usuarios backup asignados con detalles del caso
- Supervisores regionales para coordinación
- Donantes afectados sobre cambios en sus contribuciones
- Veterinarios involucrados sobre transferencias de historiales

**REQ-CONT-015: Auditoría de procesos de continuidad**

CUANDO se ejecute cualquier proceso de continuidad ENTONCES el sistema DEBERÁ registrar:
- Timestamp de activación del protocolo
- Razón de la activación (inactividad, reporte manual, etc.)
- Usuarios involucrados en la transferencia
- Tiempo total de resolución
- Resultado final (exitoso, parcial, fallido)
- Lecciones aprendidas para mejora del proceso

#### 3.2.9. Proceso de Fallecimiento de Usuarios

**REQ-DEATH-001: Reporte de fallecimiento con documentación**

CUANDO se reporte el fallecimiento de un usuario ENTONCES el sistema DEBERÁ permitir que familiares directos o representantes legales reporten mediante:
- Formulario específico "Reporte de Fallecimiento"
- Carga obligatoria de acta de defunción oficial (PDF, JPG, PNG)
- Identificación del reportante con documento de identidad
- Relación familiar o legal con el usuario fallecido

**REQ-DEATH-002: Validación de documentos de defunción**

CUANDO se presente un acta de defunción ENTONCES el sistema DEBERÁ:
- Verificar que el documento contenga información oficial (sello, firma, número de registro)
- Validar que el nombre en el acta coincida con el usuario registrado
- Confirmar que la fecha de defunción sea posterior al último acceso del usuario
- Requerir documento de identidad del reportante para verificar relación familiar

**REQ-DEATH-003: Tipos de reportantes autorizados**

CUANDO se reporte un fallecimiento ENTONCES el sistema DEBERÁ aceptar reportes únicamente de:
- Cónyuge o pareja registrada civilmente
- Hijos mayores de edad
- Padres del usuario fallecido
- Hermanos mayores de edad
- Representante legal con poder notarial
- Albacea testamentario con documentación legal

**REQ-DEATH-004: Proceso de verificación de fallecimiento**

CUANDO se reciba un reporte de fallecimiento ENTONCES el sistema DEBERÁ:
- Suspender temporalmente la cuenta del usuario (estado: "Verificando Fallecimiento")
- Enviar notificación a supervisores regionales para verificación
- Iniciar proceso de validación documental (máximo 72 horas)
- Contactar a contactos de emergencia predefinidos para confirmación cruzada

**REQ-DEATH-005: Activación de protocolo de emergencia por fallecimiento**

CUANDO se confirme un fallecimiento ENTONCES el sistema DEBERÁ activar inmediatamente:
- Protocolo de transferencia de animales bajo cuidado (si es rescatista)
- Notificación urgente a rescatistas padrinos asignados
- Contacto inmediato con veterinarios que atiendan a los animales
- Coordinación con familiares para acceso a instalaciones y suministros

**REQ-DEATH-006: Gestión de cuenta memorial**

CUANDO se confirme un fallecimiento ENTONCES el sistema DEBERÁ:
- Convertir la cuenta a estado "Memorial" (no eliminable)
- Mantener historial de rescates y contribuciones como legado
- Permitir que familiares accedan a información de animales bajo cuidado
- Preservar datos para continuidad de donaciones y transparencia

**REQ-DEATH-007: Transferencia de responsabilidades financieras**

CUANDO un usuario fallezca ENTONCES el sistema DEBERÁ:
- Transferir donaciones recurrentes a rescatistas padrinos designados
- Notificar a donantes sobre el fallecimiento y nueva asignación
- Honrar compromisos financieros pendientes del usuario fallecido
- Proporcionar reporte financiero completo a familiares/albacea

**REQ-DEATH-008: Acceso familiar a información crítica**

CUANDO se confirme un fallecimiento ENTONCES familiares autorizados DEBERÁN poder acceder a:
- Ubicación exacta de animales bajo cuidado
- Información de contacto de veterinarios tratantes
- Inventario de suministros y medicamentos
- Instrucciones específicas de cuidado por animal
- Información de contacto de rescatistas padrinos

**REQ-DEATH-009: Protocolo de acceso a instalaciones**

CUANDO un rescatista fallezca ENTONCES el sistema DEBERÁ facilitar:
- Coordinación entre familiares y rescatistas padrinos para acceso inmediato
- Información de ubicación de llaves, códigos de acceso, alarmas
- Inventario de animales presentes en las instalaciones
- Contacto de emergencia con servicios veterinarios 24/7

**REQ-DEATH-010: Comunicación con la comunidad**

CUANDO se confirme el fallecimiento de un usuario activo ENTONCES el sistema DEBERÁ:
- Notificar respetuosamente a la red de usuarios colaboradores
- Publicar mensaje memorial destacando contribuciones del usuario
- Invitar a la comunidad a apoyar la transición de animales bajo cuidado
- Mantener privacidad de detalles personales según preferencias familiares

**REQ-DEATH-011: Prevención de fraude en reportes de fallecimiento**

CUANDO se reciba un reporte de fallecimiento ENTONCES el sistema DEBERÁ implementar medidas anti-fraude:
- Verificación cruzada con múltiples contactos de emergencia
- Validación de documentos oficiales con autoridades competentes
- Período de gracia de 72 horas antes de transferencias irreversibles
- Registro de auditoría completo del proceso de verificación

**REQ-DEATH-012: Soporte psicológico para familiares**

CUANDO se confirme un fallecimiento ENTONCES el sistema DEBERÁ ofrecer:
- Recursos de apoyo psicológico para familiares en duelo
- Conexión con grupos de apoyo de la comunidad AltruPets
- Orientación sobre el proceso de transferencia de animales
- Acompañamiento durante la transición de responsabilidades

**REQ-DEATH-013: Documentación legal del proceso**

CUANDO se complete un proceso de fallecimiento ENTONCES el sistema DEBERÁ generar:
- Certificado de transferencia de responsabilidades
- Reporte completo de animales transferidos y su nuevo estado
- Documentación legal para familiares/albacea sobre el proceso
- Registro permanente en el sistema para auditorías futuras

**REQ-DEATH-014: Integración con autoridades locales**

CUANDO sea requerido por ley local ENTONCES el sistema DEBERÁ:
- Reportar casos de fallecimiento a autoridades de bienestar animal
- Proporcionar información sobre animales transferidos
- Cumplir con regulaciones locales sobre tenencia de animales
- Facilitar inspecciones de bienestar animal si son solicitadas

**REQ-DEATH-015: Métricas y seguimiento post-fallecimiento**

CUANDO se complete un proceso de fallecimiento ENTONCES el sistema DEBERÁ monitorear:
- Tiempo total de transferencia de responsabilidades
- Éxito en la reubicación de todos los animales bajo cuidado
- Satisfacción de familiares con el proceso
- Continuidad exitosa de cuidados por parte de rescatistas padrinos

### 3.2. Interfaces Externas

#### 3.2.1. Interfaz de Usuario (Aplicación Móvil Flutter)

**REQ-UI-001: UI nativa iOS/Android**

CUANDO un usuario interactúe con la aplicación móvil ENTONCES el sistema DEBERÁ proporcionar una interfaz nativa para iOS y Android con navegación intuitiva y consistente

**REQ-UI-002: Validación en tiempo real y mensajes claros**

CUANDO se muestren formularios ENTONCES el sistema DEBERÁ implementar validación en tiempo real con mensajes de error claros en español

**REQ-UI-003: Manejo de conectividad y modo offline crítico**

CUANDO ocurran errores de conectividad ENTONCES el sistema DEBERÁ mostrar mensajes informativos y permitir operación offline para funciones críticas

#### 3.2.1.1. Requisitos Específicos de Flutter y Clean Architecture

**REQ-FLT-001: Arquitectura Clean Architecture obligatoria**

CUANDO se desarrolle la aplicación Flutter ENTONCES DEBERÁ implementar estrictamente Clean Architecture con tres capas: Presentación, Dominio y Datos

**REQ-FLT-002: Estructura basada en features**

CUANDO se organice el proyecto Flutter ENTONCES DEBERÁ seguir estructura basada en features con separación clara de capas por cada funcionalidad

**REQ-FLT-003: Gestión de estado con Riverpod obligatorio**

CUANDO se maneje estado en Flutter ENTONCES se DEBERÁ usar exclusivamente Riverpod como solución de gestión de estado

**REQ-FLT-004: Inyección de dependencias con Riverpod**

CUANDO se requieran dependencias en Flutter ENTONCES estas DEBERÁN inyectarse usando Riverpod, prohibiendo el hardcoding

**REQ-FLT-005: Independencia de framework en dominio**

CUANDO se implemente la capa de dominio ENTONCES esta DEBERÁ contener únicamente código Dart puro, sin dependencias de Flutter

**REQ-FLT-006: Separación de responsabilidades en UI**

CUANDO se desarrollen widgets ENTONCES estos DEBERÁN ser puramente presentacionales, sin lógica de negocio embebida

**REQ-FLT-007: Implementación de repositorios**

CUANDO se implementen repositorios ENTONCES estos DEBERÁN coordinar entre fuentes de datos remotas y locales según la lógica de negocio

**REQ-FLT-008: Casos de uso específicos**

CUANDO se implementen casos de uso ENTONCES cada uno DEBERÁ encapsular una única regla de negocio y actuar como orquestador entre presentación y datos

**REQ-FLT-009: Modelos de datos tipados**

CUANDO se definan modelos ENTONCES estos DEBERÁN representar la estructura exacta de los datos de las fuentes externas con serialización/deserialización automática

**REQ-FLT-010: Flujo de dependencias unidireccional**

CUANDO se establezcan dependencias ENTONCES estas DEBERÁN fluir únicamente desde capas externas hacia capas internas (Presentación → Dominio ← Datos)

#### 3.2.1.2. Requisitos de Rendimiento Flutter

**REQ-FLT-011: Fluidez de interfaz 60 FPS**

CUANDO la aplicación esté en uso ENTONCES DEBERÁ mantener 60 FPS constantes en dispositivos objetivo

**REQ-FLT-012: Tiempo de carga inicial ≤3s**

CUANDO se inicie la aplicación ENTONCES el tiempo de carga inicial NO DEBERÁ exceder 3 segundos en dispositivos de gama media

**REQ-FLT-013: ListView.builder para listas grandes**

CUANDO se rendericen listas grandes (>20 elementos) ENTONCES se DEBERÁ usar ListView.builder o equivalentes para renderizado bajo demanda

**REQ-FLT-014: Operaciones no bloqueantes**

CUANDO se ejecuten tareas intensivas ENTONCES estas DEBERÁN ejecutarse en Isolates o usando compute() para no bloquear el hilo principal

**REQ-FLT-015: Constructores const obligatorios**

CUANDO sea posible ENTONCES se DEBERÁ usar constructor const para optimizar el rendimiento

**REQ-FLT-016: RepaintBoundary para widgets costosos**

CUANDO se implementen widgets costosos ENTONCES se DEBERÁ usar RepaintBoundary para aislar el área de repintado

#### 3.2.1.3. Requisitos de Calidad de Código Flutter

**REQ-FLT-017: Análisis estático con flutter_lints**

CUANDO se escriba código Flutter ENTONCES DEBERÁ pasar las validaciones de flutter_lints con configuración estricta en analysis_options.yaml

**REQ-FLT-018: Formateo consistente**

CUANDO se realice un commit ENTONCES el código DEBERÁ estar formateado usando flutter format

**REQ-FLT-019: Inmutabilidad preferida**

CUANDO se declaren variables ENTONCES se DEBERÁ usar final para valores inmutables, evitando var innecesario

**REQ-FLT-020: Logging estructurado**

CUANDO se requiera logging ENTONCES se DEBERÁ usar debugPrint() o paquete logger, prohibiendo print()

**REQ-FLT-021: Nomenclatura consistente**

CUANDO se nombren elementos del código ENTONCES se DEBERÁN seguir convenciones: archivos snake_case.dart, clases PascalCase, variables camelCase

#### 3.2.1.4. Requisitos de Testing Flutter

**REQ-FLT-022: Cobertura de testing mínima 80%**

CUANDO se desarrollen features ENTONCES DEBERÁN tener una cobertura de tests unitarios mínima del 80%

**REQ-FLT-023: Tests unitarios para casos de uso**

CUANDO se implementen casos de uso ENTONCES DEBERÁN tener tests unitarios que validen la lógica de negocio

**REQ-FLT-024: Widget tests para UI**

CUANDO se desarrollen widgets ENTONCES DEBERÁN tener widget tests que validen la interfaz de usuario

**REQ-FLT-025: Integration tests para flujos críticos**

CUANDO se implementen flujos críticos ENTONCES DEBERÁN tener integration tests que validen el comportamiento end-to-end

#### 3.2.1.5. Requisitos de Seguridad Flutter

**REQ-FLT-026: Almacenamiento seguro**

CUANDO se manejen datos sensibles ENTONCES estos DEBERÁN almacenarse usando flutter_secure_storage o equivalente con cifrado

**REQ-FLT-027: No hardcodear claves**

CUANDO se configuren APIs ENTONCES se DEBERÁ prohibir hardcodear claves de API o tokens en el código

**REQ-FLT-028: Validación de entrada**

CUANDO se reciban datos del usuario o APIs ENTONCES estos DEBERÁN validarse tanto en cliente como en servidor

**REQ-FLT-029: Comunicaciones HTTPS**

CUANDO se realicen comunicaciones de red ENTONCES estas DEBERÁN usar exclusivamente HTTPS con validación de certificados

**REQ-FLT-030: Ofuscación en producción**

CUANDO se generen builds de producción ENTONCES DEBERÁN estar ofuscados para dificultar la ingeniería inversa

#### 3.2.1.6. Requisitos de Conectividad Flutter

**REQ-FLT-031: Cliente HTTP robusto con Dio**

CUANDO se realicen peticiones HTTP ENTONCES se DEBERÁ usar Dio con interceptores para logging, retry y headers automáticos

**REQ-FLT-032: Estrategia offline-first**

CUANDO se diseñe la aplicación ENTONCES DEBERÁ funcionar sin conexión usando almacenamiento local SQLite y sincronizar cuando haya conectividad

**REQ-FLT-033: Detección de conectividad**

CUANDO se maneje conectividad ENTONCES se DEBERÁ usar connectivity_plus para detectar cambios de red

**REQ-FLT-034: Paginación obligatoria**

CUANDO se carguen listas de datos ENTONCES se DEBERÁ implementar paginación para optimizar memoria y datos

#### 3.2.1.7. Requisitos de Despliegue Flutter

**REQ-FLT-035: Feature flags con Firebase Remote Config**

CUANDO se despliegue a producción ENTONCES se DEBERÁN usar Feature Flags con Firebase Remote Config para control remoto de funcionalidades

**REQ-FLT-036: Monitoreo con Crashlytics y Analytics**

CUANDO la aplicación esté en producción ENTONCES DEBERÁ tener Crashlytics y Firebase Analytics configurados para monitoreo

**REQ-FLT-037: Dependencias actualizadas mensualmente**

CUANDO se mantenga la aplicación ENTONCES las dependencias DEBERÁN actualizarse mensualmente usando flutter pub outdated y flutter pub upgrade

**REQ-FLT-038: Pipeline CI/CD automatizado**

CUANDO se integre código ENTONCES DEBERÁ pasar por pipeline CI/CD que incluya linting, testing y build

**REQ-FLT-039: Versionado semántico**

CUANDO se publique una release ENTONCES DEBERÁ seguir versionado semántico (Major.Minor.Patch)

#### 3.2.1.8. Requisitos de Navegación Flutter

**REQ-FLT-040: Routing declarativo con GoRouter**

CUANDO se implemente navegación ENTONCES se DEBERÁ usar GoRouter para routing declarativo

**REQ-FLT-041: Patrones de navegación consistentes**

CUANDO se navegue ENTONCES se DEBERÁN usar patrones consistentes para navegación programática, modal y bottom sheets

#### 3.2.1.9. Requisitos de Theming y Diseño Flutter

**REQ-FLT-042: Material Design 3 o Cupertino**

CUANDO se diseñe la interfaz ENTONCES DEBERÁ seguir Material Design 3 o Cupertino Design

**REQ-FLT-043: Soporte para temas claro y oscuro**

CUANDO se implemente theming ENTONCES DEBERÁ soportar temas claro y oscuro

**REQ-FLT-044: ThemeData centralizado**

CUANDO se configure theming ENTONCES se DEBERÁ definir un ThemeData centralizado para consistencia

**REQ-FLT-045: Layouts responsivos**

CUANDO se diseñen layouts ENTONCES se DEBERÁN usar patrones responsivos con LayoutBuilder o MediaQuery

**REQ-FLT-046: Prevención de overflow**

CUANDO se construyan layouts ENTONCES se DEBERÁ prevenir overflow usando Flexible, Expanded, Wrap o SingleChildScrollView

#### 3.2.1.10. Requisitos de Accesibilidad Flutter

**REQ-FLT-047: Accesibilidad según WCAG 2.1**

CUANDO se implemente la interfaz ENTONCES DEBERÁ cumplir con accesibilidad según WCAG 2.1

**REQ-FLT-048: Labels semánticos obligatorios**

CUANDO se implementen widgets ENTONCES se DEBERÁN añadir labels semánticos usando widget Semantics

**REQ-FLT-049: Contraste mínimo 4.5:1**

CUANDO se definan colores ENTONCES se DEBERÁ asegurar contraste mínimo 4.5:1 para texto

**REQ-FLT-050: Pruebas con TalkBack y VoiceOver**

CUANDO se valide accesibilidad ENTONCES se DEBERÁ probar regularmente con TalkBack (Android) y VoiceOver (iOS)

#### 3.2.1.11. Requisitos de Configuración MCP (Model Context Protocol)

**REQ-FLT-051: Servidor MCP configurado obligatorio**

CUANDO se configure el entorno de desarrollo ENTONCES se DEBERÁ conectar al servidor MCP (Model Context Protocol) de Dart/Flutter para habilitar asistencia de AI avanzada

**REQ-FLT-052: Configuración MCP en Kiro**

CUANDO se use Kiro ENTONCES se DEBERÁ configurar el servidor MCP usando el archivo de workspace .kiro/settings/mcp.json con autoApprove para dart_analyze, dart_format, pub_search, pub_add

**REQ-FLT-053: Verificación de conexión MCP**

CUANDO se configure MCP ENTONCES se DEBERÁ verificar que el comando dart mcp-server esté disponible y la versión de Dart SDK sea 3.9+ o Flutter 3.35+

**REQ-FLT-054: Aprovechamiento de herramientas MCP**

CUANDO se desarrolle con asistencia de AI ENTONCES se DEBERÁN aprovechar las herramientas MCP para análisis automático de código, búsqueda de paquetes, generación de código siguiendo Clean Architecture y debugging asistido

#### 3.2.1.12. Requisitos de Estructura de Proyecto Flutter

**REQ-FLT-055: Organización por features obligatoria**

CUANDO se organice el proyecto Flutter ENTONCES DEBERÁ seguir la estructura: lib/features/[feature_name]/{presentation,domain,data}/ con separación clara de responsabilidades

**REQ-FLT-056: Configuración de desarrollo obligatoria**

CUANDO se configure el proyecto ENTONCES DEBERÁ incluir analysis_options.yaml con flutter_lints, build_runner para generación de código y pre-commit hooks

**REQ-FLT-057: Dependencias aprobadas para Clean Architecture**

CUANDO se agreguen dependencias ENTONCES se DEBERÁN usar las dependencias aprobadas: riverpod (estado y DI), dartz (Either), dio (HTTP), sqflite (BD local), go_router (navegación)

**REQ-FLT-058: Validaciones automáticas**

CUANDO se configure el proyecto ENTONCES se DEBERÁN establecer pre-commit hooks que ejecuten flutter analyze, flutter format, flutter test y dart run build_runner build

#### 3.2.2. Interfaz con Hardware

**REQ-HW-001: GPS con precisión ≥10m**

CUANDO se requiera geolocalización ENTONCES el sistema DEBERÁ acceder al GPS del dispositivo móvil con precisión mínima de 10 metros

**REQ-HW-002: Cámara con compresión automática**

CUANDO se capturen imágenes ENTONCES el sistema DEBERÁ utilizar la cámara del dispositivo con compresión automática para optimizar almacenamiento

**REQ-HW-003: Notificaciones push nativas**

CUANDO se envíen notificaciones ENTONCES el sistema DEBERÁ utilizar las capacidades nativas de notificaciones push del dispositivo

#### 3.2.3. Interfaz con Software Externo

**REQ-SW-001: Integración ONVOPay vía HTTPS/API Keys**

CUANDO se procesen pagos ENTONCES el sistema DEBERÁ integrarse con la API de ONVOPay usando protocolo HTTPS y autenticación mediante API keys

**REQ-SW-002: Mapas con Google Maps o MapBox**

CUANDO se requieran mapas ENTONCES el sistema DEBERÁ integrarse con Google Maps API o MapBox para visualización y cálculos geoespaciales

**REQ-SW-003: Notificaciones con Firebase Admin SDK**

CUANDO se envíen notificaciones push ENTONCES el sistema DEBERÁ utilizar Firebase Admin SDK para entrega confiable

**REQ-SW-FIN-010: Obligación municipal al aprobar subvención**

CUANDO una solicitud de subvención cambie a `APROBADA` ENTONCES el `Financial Service` DEBERÁ crear la obligación de pago municipal y preparar el flujo de pago (vía ONVOPay o método alternativo `REQ-INT-002`).

**REQ-SW-FIN-011: Obligación del rescatista si rechazada/expirada**

CUANDO una solicitud de subvención cambie a `RECHAZADA` o `EXPIRADA` ENTONCES el `Financial Service` DEBERÁ crear la obligación de pago del rescatista y habilitar los métodos de cobro correspondientes.

#### 3.2.4. Interfaces de Comunicación

**REQ-COM-001: gRPC interno con TLS 1.3**

CUANDO los microservicios se comuniquen internamente ENTONCES el sistema DEBERÁ utilizar gRPC con encriptación TLS 1.3

**REQ-COM-002: REST vía API Gateway con JWT**

CUANDO el frontend se comunique con el backend ENTONCES el sistema DEBERÁ utilizar REST APIs a través del API Gateway con autenticación JWT

**REQ-COM-003: WebSockets para tiempo real**

CUANDO se requiera comunicación en tiempo real ENTONCES el sistema DEBERÁ implementar WebSockets para chat y notificaciones instantáneas

### 3.3. Requisitos de Rendimiento

**REQ-PER-001: 10k usuarios concurrentes mínimos**

CUANDO el sistema opere en producción ENTONCES DEBERÁ soportar mínimo 10,000 usuarios concurrentes sin degradación del servicio

**REQ-PER-002: ≥100 TPS en transacciones financieras**

CUANDO se procesen transacciones financieras ENTONCES el sistema DEBERÁ procesar mínimo 100 transacciones por segundo

**REQ-PER-003: Push <5s desde evento**

CUANDO se envíen notificaciones push ENTONCES DEBERÁN entregarse en menos de 5 segundos desde el evento disparador

**REQ-PER-004: Búsquedas geo <2s**

CUANDO se realicen búsquedas geoespaciales ENTONCES los resultados DEBERÁN mostrarse en menos de 2 segundos

**REQ-PER-005: Imágenes ≤2MB via compresión**

CUANDO se carguen imágenes ENTONCES el sistema DEBERÁ comprimir automáticamente a máximo 2MB por imagen

**REQ-PER-006: Sincronización offline <30s**

CUANDO se sincronicen datos offline ENTONCES la sincronización DEBERÁ completarse en menos de 30 segundos

**REQ-PER-007: Reportes financieros <10s (hasta 1 año)**

CUANDO se generen reportes financieros ENTONCES DEBERÁN procesarse en menos de 10 segundos para períodos de hasta 1 año

**REQ-PER-008: Rendimiento Flutter 60 FPS**

CUANDO la aplicación Flutter esté en uso ENTONCES DEBERÁ mantener 60 FPS constantes en dispositivos objetivo

**REQ-PER-009: Tiempo de inicio Flutter ≤3s**

CUANDO se inicie la aplicación Flutter ENTONCES el tiempo de carga inicial NO DEBERÁ exceder 3 segundos en dispositivos de gama media

**REQ-PER-010: Uso eficiente de memoria Flutter**

CUANDO se rendericen listas grandes en Flutter ENTONCES se DEBERÁ usar ListView.builder o equivalentes para renderizado bajo demanda

### 3.4. Restricciones de Diseño

**REQ-DIS-001: Arquitectura microservicios y Db-per-Service**

CUANDO se implemente la arquitectura ENTONCES el sistema DEBERÁ seguir obligatoriamente el patrón de microservicios con Database per Service

**REQ-DIS-002: Contenedores y orquestación K8s/OpenShift**

CUANDO se despliegue el sistema ENTONCES DEBERÁ ejecutarse en contenedores Docker/Podman orquestados por Kubernetes o OpenShift

**REQ-DIS-003: Principios 12-Factor App**

CUANDO se implementen los microservicios ENTONCES DEBERÁN seguir los principios de 12-Factor App

**REQ-DIS-004: Cumplimiento PCI DSS nivel 1**

CUANDO se procesen pagos ENTONCES el sistema DEBERÁ cumplir obligatoriamente con PCI DSS nivel 1

**REQ-DIS-005: Cifrado AES-256 en reposo y TLS 1.3 en tránsito**

CUANDO se almacenen datos sensibles ENTONCES DEBERÁN encriptarse usando AES-256 en reposo y TLS 1.3 en tránsito

**REQ-DIS-006: gRPC interno y REST externo**

CUANDO se comuniquen los microservicios ENTONCES DEBERÁN utilizar gRPC para comunicación interna y REST para APIs externas

**REQ-DIS-007: Observabilidad con OTel/Prometheus/Loki/Tempo**

CUANDO se implemente observabilidad ENTONCES el sistema DEBERÁ usar Prometheus para métricas, Loki para logs y Grafana Tempo para trazas distribuidas, mediante OpenTelemetry Collector usando protocolo OTLP

**REQ-DIS-008: Flutter SDK y Clean Architecture obligatorios**

CUANDO se desarrolle la aplicación móvil ENTONCES DEBERÁ usar Flutter SDK con implementación estricta de Clean Architecture de tres capas

**REQ-DIS-009: Compatibilidad multiplataforma Flutter**

CUANDO se desarrolle la aplicación ENTONCES DEBERÁ funcionar correctamente en iOS 12+ y Android API 21+ sin modificaciones específicas de plataforma innecesarias

### 3.5. Atributos del Sistema

#### 3.5.1. Seguridad

**REQ-SEC-001: Autenticación JWT + refresh tokens (24h)**

CUANDO un usuario se autentique ENTONCES el sistema DEBERÁ utilizar JWT con expiración de 24 horas y refresh tokens

**REQ-SEC-002: Hash de credenciales con bcrypt (≥12 rounds)**

CUANDO se almacenen credenciales ENTONCES DEBERÁN hashearse usando bcrypt con salt mínimo de 12 rounds

**REQ-SEC-003: Bloqueo por actividad sospechosa y notificación**

CUANDO se detecte actividad sospechosa ENTONCES el sistema DEBERÁ bloquear temporalmente la cuenta y notificar al administrador

**REQ-SEC-004: KYC cifrado E2E y BD segregada**

CUANDO se procesen datos KYC ENTONCES DEBERÁN encriptarse punto a punto y almacenarse en bases de datos segregadas

**REQ-SEC-005: Rate limiting 1000 RPM por usuario**

CUANDO se acceda a APIs ENTONCES el sistema DEBERÁ implementar rate limiting de 1000 requests por minuto por usuario

**REQ-SEC-006: Minimización de PII y acceso de solo lectura**

CUANDO SREs o Auditores accedan a datos ENTONCES el sistema DEBERÁ exponer vistas de solo lectura con minimización de PII (enmascarado/tokenización cuando aplique) y prohibir modificaciones, excepto mediante proceso de emergencia `break-glass`.

**REQ-SEC-007: Proceso break-glass auditado y con expiración**

CUANDO sea necesario acceso excepcional ENTONCES el sistema DEBERÁ requerir doble autorización (aprobador independiente), registrar motivo, delimitar alcance/tiempo (TTL) y realizar auto-revocación con auditoría completa.

#### 3.5.5. Clasificación de Datos y Niveles de Sensibilidad

- **Plataforma/Operacional:** Telemetría, métricas agregadas, salud del sistema (sin PII).
- **PII Central (no gubernamental):** Datos de usuarios/animales centrales de AltruPets.
- **Financiero/PCI:** Donaciones/pagos tokenizados y artefactos de cumplimiento.
- **Gubernamental Segregado:** Autorizaciones veterinarias, reportes jurisdiccionales, políticas locales por tenant.
- **Ambiental:** Datos de entidades ambientales (p. ej., SINAC) sujetos a su jurisdicción.

**REQ-SEC-007-A: Break-glass Plataforma/Operacional**

CUANDO se requiera acceso excepcional a datos de plataforma ENTONCES los aprobadores DEBERÁN ser Seguridad/Compliance y Manager SRE, el acceso SERÁ solo lectura, sin PII, con TTL ≤ 2 horas y alcance mínimo.

**REQ-SEC-007-B: Break-glass PII Central**

CUANDO se requiera acceso excepcional a PII central ENTONCES los aprobadores DEBERÁN ser DPO/Compliance y el Data Owner, aplicando minimización de PII y motivo legal explícito, con TTL ≤ 1 hora y alcance mínimo.

**REQ-SEC-007-C: Break-glass Financiero/PCI**

CUANDO se requiera acceso excepcional a datos financieros ENTONCES los aprobadores DEBERÁN ser PCI Officer y Compliance, permitiendo SOLO tokens (sin PAN), con controles de exportación, TTL ≤ 1 hora y alcance mínimo.

**REQ-SEC-007-D: Break-glass Gubernamental Segregado**

CUANDO se requiera acceso excepcional a datos gubernamentales ENTONCES los aprobadores DEBERÁN ser el Administrador Gubernamental del tenant y Compliance, limitando el alcance por jurisdicción y TTL ≤ 1 hora.

**REQ-SEC-007-E: Break-glass Ambiental**

CUANDO se requiera acceso excepcional a datos ambientales ENTONCES los aprobadores DEBERÁN ser la autoridad ambiental competente (p. ej., SINAC) y Compliance, limitando el alcance por jurisdicción y TTL ≤ 1 hora.

**REQ-SEC-008: Auditoría inmutable de break-glass**

CUANDO se ejecute break-glass ENTONCES el sistema DEBERÁ registrar de forma inmutable: solicitante, aprobadores, motivo, alcance, TTL, acciones/consultas, exportaciones y hashes de integridad, con sellado temporal.

**REQ-SEC-009: Controles de volumen y anomalías en break-glass**

CUANDO se use break-glass ENTONCES el sistema DEBERÁ aplicar límites de volumen/velocidad por sesión, detección de anomalías (picos, exfiltración) y bloqueo/rescisión automática al exceder umbrales.

#### 3.5.2. Confiabilidad

**REQ-REL-001: Disponibilidad ≥99.9% mensual**

CUANDO el sistema esté en producción ENTONCES DEBERÁ mantener disponibilidad mínima del 99.9% mensual

**REQ-REL-002: Circuit Breaker ante fallas**

CUANDO falle un microservicio ENTONCES el sistema DEBERÁ implementar Circuit Breaker para evitar cascadas de errores

**REQ-REL-003: Backups cada 6h, retención 30 días**

CUANDO se pierdan datos ENTONCES el sistema DEBERÁ mantener backups automáticos cada 6 horas con retención de 30 días

**REQ-REL-004: Reintentos con backoff exponencial**

CUANDO ocurran errores ENTONCES el sistema DEBERÁ implementar reintentos automáticos con backoff exponencial

**REQ-REL-005: Continuidad operativa ante pérdida de usuarios críticos**

CUANDO un rescatista con animales bajo cuidado no pueda continuar ENTONCES el sistema DEBERÁ garantizar transferencia exitosa en <24 horas para casos críticos y <72 horas para casos rutinarios

**REQ-REL-006: Redundancia en roles críticos**

CUANDO se opere el sistema ENTONCES DEBERÁ mantener mínimo 3 usuarios backup por cada rescatista activo y 2 supervisores regionales por área geográfica

**REQ-REL-007: Recuperación ante falla de supervisores**

CUANDO un supervisor regional no esté disponible ENTONCES el sistema DEBERÁ escalar automáticamente a supervisores de áreas adyacentes o al nivel nacional

#### 3.5.3. Escalabilidad

**REQ-ESC-001: Autoescalado hasta 100 réplicas/servicio**

CUANDO aumente la carga ENTONCES el sistema DEBERÁ escalar automáticamente hasta 100 réplicas por microservicio

**REQ-ESC-002: Particionamiento horizontal en BD**

CUANDO se requiera más almacenamiento ENTONCES las bases de datos DEBERÁN soportar particionamiento horizontal

**REQ-ESC-003: Soporte multi-región**

CUANDO se expanda geográficamente ENTONCES el sistema DEBERÁ soportar despliegue multi-región

#### 3.5.4. Mantenibilidad

**REQ-MAN-001: Rolling updates sin downtime**

CUANDO se actualicen microservicios ENTONCES DEBERÁ ser posible despliegue sin tiempo de inactividad usando rolling updates

**REQ-MAN-002: Healthchecks y endpoints de diagnóstico**

CUANDO se requiera debugging ENTONCES cada microservicio DEBERÁ exponer métricas de salud y endpoints de diagnóstico

**REQ-MAN-003: CI/CD con pruebas unitarias e integración**

CUANDO se modifique código ENTONCES DEBERÁ pasar por pipeline CI/CD automatizado con pruebas unitarias e integración

### 3.6. Reglas de Negocio Fundamentales

#### 3.6.1. Reglas de Asociación entre Rescatistas y Casas Cuna

**REQ-BR-001: Múltiples casas cuna por rescatista**

CUANDO se registre un rescatista ENTONCES el sistema DEBERÁ permitir asociar múltiples casas cuna a un mismo rescatista

**REQ-BR-002: Múltiples rescatistas por casa cuna**

CUANDO se registre una casa cuna ENTONCES el sistema DEBERÁ permitir asociar múltiples rescatistas a la misma casa cuna

**REQ-BR-003: Autorización bilateral en asociaciones**

CUANDO se establezca una asociación rescatista-casa cuna ENTONCES el sistema DEBERÁ requerir autorización explícita de ambas partes

#### 3.6.2. Principio de Responsabilidad Única para Solicitudes

**REQ-BR-010: Centinela solo envía solicitudes de auxilio**

CUANDO un centinela ciudadano use el sistema ENTONCES ÚNICAMENTE DEBERÁ poder enviar "solicitudes de auxilio"

**REQ-BR-011: Centinela no envía informes**

CUANDO un centinela ciudadano use el sistema ENTONCES NO DEBERÁ poder enviar informes de ningún tipo

**REQ-BR-012: Auxilio requiere geolocalización obligatoria**

CUANDO un centinela cree una solicitud de auxilio ENTONCES el sistema DEBERÁ requerir geolocalización obligatoria

**REQ-BR-020: Auxiliar solo envía solicitudes de rescate**

CUANDO un auxiliar use el sistema ENTONCES ÚNICAMENTE DEBERÁ poder enviar "solicitudes de rescate"

**REQ-BR-021: Auxiliar no envía informes**

CUANDO un auxiliar use el sistema ENTONCES NO DEBERÁ poder enviar informes de ningún tipo

**REQ-BR-022: Rescate requiere auxilio previo válido**

CUANDO un auxiliar cree una solicitud de rescate ENTONCES el sistema DEBERÁ requerir referencia a una solicitud de auxilio previa válida

**REQ-BR-030: Rescatista envía múltiples tipos de solicitudes (Excepción al Principio de Responsabilidad Única)**

CUANDO un rescatista use el sistema ENTONCES DEBERÁ poder enviar DOS tipos de solicitudes:
- "Solicitudes para atención veterinaria" cuando evalúe que el animal requiere atención profesional que excede sus conocimientos/insumos disponibles
- "Solicitudes de adopción" cuando evalúe que el animal cumple todos los criterios de adoptabilidad

**Justificación de la violación:** Los rescatistas tienen autonomía profesional y son los únicos con conocimiento directo del estado del animal, capacidad de evaluación médica básica, y responsabilidad moral de garantizar el bienestar desde rescate hasta adopción

#### 3.6.2.1. Documentación de la Excepción al Principio de Responsabilidad Única

**REQ-BR-025: Reconocimiento formal de la violación**

CUANDO se evalúe la arquitectura del sistema ENTONCES se DEBERÁ reconocer formalmente que los rescatistas violan intencionalmente el principio de responsabilidad única por razones de dominio de negocio

**REQ-BR-026: Criterios para solicitudes veterinarias de rescatistas**

CUANDO un rescatista evalúe crear una solicitud para atención veterinaria ENTONCES DEBERÁ considerar:
- Si sus conocimientos médicos básicos son suficientes para el caso
- Si cuenta con los insumos necesarios (vendajes, medicamentos, anestesia local, ungüentos, chupones, alimento especial, pañales, pads)
- Si la condición del animal requiere diagnóstico o tratamiento profesional especializado
- Si el riesgo de complicaciones justifica atención veterinaria inmediata

**REQ-BR-027: Criterios para solicitudes de adopción de rescatistas**

CUANDO un rescatista evalúe crear una solicitud de adopción ENTONCES DEBERÁ verificar que el animal cumple todos los criterios de adoptabilidad según REQ-BR-050 y REQ-BR-051

**REQ-BR-028: Implicaciones técnicas de la excepción**

CUANDO se implemente el sistema ENTONCES se DEBERÁ:
- Permitir que los rescatistas accedan a formularios de ambos tipos de solicitudes
- Implementar validaciones específicas para cada tipo de solicitud
- Mantener trazabilidad de las decisiones del rescatista
- Proporcionar interfaces diferenciadas para cada responsabilidad

**REQ-BR-031: Rescatista no envía informes**

CUANDO un rescatista use el sistema ENTONCES NO DEBERÁ poder enviar informes de ningún tipo

**REQ-BR-032: Adopción requiere adoptabilidad completa**

CUANDO un rescatista cree una solicitud de adopción ENTONCES el sistema DEBERÁ verificar que el animal cumpla todos los requisitos de adoptabilidad

#### 3.6.3. Subvención Municipal de Atención Veterinaria

**REQ-FIN-VET-001: Crear solicitud de subvención municipal**

CUANDO un veterinario o clínica registre un procedimiento de atención ENTONCES el sistema DEBERÁ permitir crear una “Solicitud de Subvención Municipal” vinculada al caso, con monto tentativo, desglose de servicios, proveedor (clínica/veterinario), fecha y ubicación del animal.

**REQ-FIN-VET-002: Asignación por jurisdicción del caso**

CUANDO se cree una solicitud de subvención ENTONCES el sistema DEBERÁ asignarla al gobierno local cuya jurisdicción contenga la ubicación del caso, respetando `REQ-JUR-001..003` y `REQ-JUR-011`.

**REQ-FIN-VET-003: Flujo de estados de subvención**

CUANDO una solicitud de subvención exista ENTONCES DEBERÁ gestionar estados: `CREADA` → `EN_REVISION` → `APROBADA` | `RECHAZADA` | `EXPIRADA`.

**REQ-FIN-VET-004: Factura a municipalidad si aprobada**

CUANDO una solicitud sea `APROBADA` ENTONCES el sistema DEBERÁ emitir la factura a nombre de la municipalidad aprobadora y registrar la obligación de pago municipal (subvención total).

**REQ-FIN-VET-005: Factura al rescatista si rechazada/expirada**

CUANDO una solicitud sea `RECHAZADA` o `EXPIRADA` ENTONCES el sistema DEBERÁ emitir la factura a nombre del rescatista y registrar su obligación de pago.

**REQ-FIN-VET-006: Notificaciones a municipal/vet/rescatista**

CUANDO se creen o resuelvan solicitudes ENTONCES el sistema DEBERÁ notificar al encargado municipal (creación) y al veterinario y rescatista (resolución: `APROBADA`/`RECHAZADA`/`EXPIRADA`).

**REQ-FIN-VET-007: Solicitud de información y pausa de plazo**

CUANDO la municipalidad requiera aclaraciones ENTONCES el sistema DEBERÁ permitir solicitudes de información durante `EN_REVISION` y pausar el cómputo de plazo hasta que el veterinario adjunte los soportes.

**REQ-FIN-VET-008: Procedimiento no condicionado por aprobación**

CUANDO se ejecute un procedimiento médico ENTONCES su realización NO DEBERÁ depender de la aprobación municipal; la subvención afectará únicamente la facturación y el sujeto obligado de pago.

**REQ-FIN-VET-009: Emisión inmediata de factura según estado**

CUANDO una solicitud cambie a `APROBADA` ENTONCES el sistema DEBERÁ emitir la factura inmediata a nombre de la municipalidad; CUANDO cambie a `RECHAZADA` o `EXPIRADA` ENTONCES deberá emitir la factura a nombre del rescatista.

**REQ-FIN-VET-010: Subvención total (sin cofinanciamiento)**

CUANDO se gestione subvención municipal ENTONCES el sistema DEBERÁ aplicar subvención total; el cofinanciamiento parcial NO DEBERÁ estar habilitado.

**REQ-FIN-VET-011: Validación de proveedor por Veterinary Service**

CUANDO un proveedor solicite subvención ENTONCES el sistema DEBERÁ verificar que el veterinario/clínica esté validado por el `Veterinary Service`.

**REQ-FIN-VET-012: Sin subvención fuera de jurisdicción**

CUANDO la ubicación del caso esté fuera de la jurisdicción ENTONCES el sistema NO DEBERÁ permitir subvención por esa municipalidad; en zonas fronterizas podrá requerirse doble subvención conforme `REQ-JUR-002` y `REQ-JUR-012`.

**REQ-FIN-VET-013: Auditoría completa con retención 7 años**

CUANDO se gestione subvención ENTONCES el sistema DEBERÁ registrar auditoría completa (solicitante, aprobador, fechas, montos, ubicación) con retención mínima de 7 años (`REQ-REG-004`).

**REQ-FIN-VET-014: SLA de respuesta configurable (horas)**

CUANDO se configure un tenant municipal ENTONCES el parámetro “Tiempo máximo de respuesta para subvencionar” DEBERÁ ser definible por la municipalidad (en horas) y aplicarse al cálculo de `EXPIRADA`.

Nota: `REQ-BR-040`, `REQ-BR-041` y `REQ-BR-042` quedan reemplazados por `REQ-FIN-VET-001..014`.

#### 3.6.4. Atributos y Validaciones de Animales

**REQ-BR-050: Requisitos mínimos de adoptabilidad**

CUANDO se evalúe la adoptabilidad de un animal ENTONCES el sistema DEBERÁ verificar que cumpla TODOS los siguientes requisitos:
- Usa arenero = TRUE
- Come por sí mismo = TRUE

**REQ-BR-051: Restricciones que impiden adopción**

CUANDO se evalúe la adoptabilidad de un animal ENTONCES el sistema DEBERÁ verificar que NO tenga NINGUNA de las siguientes restricciones:
- Arizco con humanos = TRUE
- Arizco con otros animales = TRUE
- Lactante = TRUE
- Nodriza = TRUE
- Enfermo = TRUE
- Herido = TRUE
- Recién parida = TRUE
- Recién nacido = TRUE

**REQ-BR-060: Solicitudes para atención veterinaria (automáticas y manuales)**

CUANDO un auxiliar genere una solicitud de rescate ENTONCES el sistema DEBERÁ crear automáticamente una "solicitud de autorización para atención veterinaria" SI el animal tiene CUALQUIERA de las siguientes condiciones:
- Callejero = TRUE
- Herido = TRUE
- Enfermo = TRUE

CUANDO un rescatista evalúe que un animal requiere atención veterinaria profesional ENTONCES el sistema DEBERÁ permitir crear una "solicitud para atención veterinaria" independientemente de las condiciones automáticas, basada en su criterio profesional y conocimiento directo del animal

**Diferenciación:**
- **Solicitudes automáticas**: Generadas por el sistema para subvención gubernamental de animales callejeros
- **Solicitudes manuales de rescatistas**: Creadas por evaluación profesional para cualquier animal bajo su cuidado

**REQ-BR-070: Criterios para autorizar atención veterinaria**

CUANDO un encargado gubernamental evalúe una autorización veterinaria ENTONCES SOLAMENTE PODRÁ autorizarla CUANDO se cumplan AMBAS condiciones:
- La ubicación esté dentro de su jurisdicción territorial
- El animal tenga la condición "callejero" = TRUE

#### 3.6.5. Validaciones de Integridad del Sistema

**REQ-BR-080: Validación de conflictos de atributos**

CUANDO se actualicen atributos de un animal ENTONCES el sistema DEBERÁ validar que no existan conflictos entre requisitos y restricciones

**REQ-BR-081: Incompatibilidad comer por sí mismo vs lactante**

CUANDO se actualicen atributos de un animal ENTONCES el sistema DEBERÁ impedir que tenga simultáneamente "Come por sí mismo" = TRUE Y "Lactante" = TRUE

**REQ-BR-082: Recién nacido implica lactante**

CUANDO un animal tenga "Recién Nacido" = TRUE ENTONCES el sistema DEBERÁ establecer automáticamente "Lactante" = TRUE

**REQ-BR-090: Rescate requiere auxilio previo**

CUANDO se intente crear una solicitud de rescate ENTONCES el sistema DEBERÁ verificar que exista una solicitud de auxilio previa válida

**REQ-BR-091: Adopción requiere adoptabilidad**

CUANDO se intente crear una solicitud de adopción ENTONCES el sistema DEBERÁ verificar que el animal cumpla todos los requisitos de adoptabilidad

**REQ-BR-092: Autorización vet dentro de jurisdicción**

CUANDO se intente otorgar una autorización veterinaria ENTONCES el sistema DEBERÁ verificar que esté dentro de la jurisdicción territorial correspondiente

#### 3.6.6. Cumplimiento Regulatorio

**REQ-REG-001: KYC extendido > USD 1000**

CUANDO se procesen donaciones superiores a $1000 USD ENTONCES el sistema DEBERÁ aplicar controles KYC extendidos según regulaciones financieras locales

**REQ-REG-002: Reportes automáticos por patrones sospechosos**

CUANDO se detecten patrones sospechosos ENTONCES el sistema DEBERÁ generar reportes automáticos para autoridades competentes

**REQ-REG-003: Tokenización sin PAN completo**

CUANDO se almacenen datos de tarjetas ENTONCES el sistema DEBERÁ utilizar únicamente tokenización sin almacenar PAN completo

**REQ-REG-004: Logs inmutables 7 años**

CUANDO se audite el sistema ENTONCES DEBERÁ mantener logs inmutables de todas las transacciones financieras por 7 años

**REQ-REG-005: Retención y cadena de custodia de evidencias**

CUANDO se conserven evidencias de auditoría ENTONCES el sistema DEBERÁ mantener retención mínima de 7 años, con cadena de custodia documentada y verificable criptográficamente.

#### 3.6.7. Localización

**REQ-LOC-001: UI en español local**

CUANDO se muestre la interfaz ENTONCES DEBERÁ estar en español adaptado al país de operación

**REQ-LOC-002: Monedas local y USD**

CUANDO se manejen montos ENTONCES el sistema DEBERÁ soportar la moneda local del país y dólares estadounidenses (USD)

**REQ-LOC-003: Fechas en formato DD/MM/YYYY**

CUANDO se muestren fechas ENTONCES DEBERÁN seguir formato DD/MM/YYYY según estándares locales

#### 3.6.8. Reglas de Geolocalización y Proximidad

**REQ-GEO-001: Búsqueda de auxiliares 10km inicial**

CUANDO se busquen auxiliares para una solicitud de auxilio ENTONCES el sistema DEBERÁ usar un radio inicial de búsqueda de 10km desde el punto de auxilio

**REQ-GEO-002: Expansión a 25km a los 30 minutos**

CUANDO no haya respuesta de auxiliares en 30 minutos ENTONCES el sistema DEBERÁ expandir automáticamente el radio de búsqueda a 25km

**REQ-GEO-003: Expansión a 50km y alerta a 60 minutos**

CUANDO no haya respuesta de auxiliares en 60 minutos ENTONCES el sistema DEBERÁ expandir el radio a 50km y alertar supervisores

**REQ-GEO-004: Radio máximo 100km**

CUANDO se busquen auxiliares ENTONCES el sistema DEBERÁ usar un radio máximo de búsqueda de 100km (nivel nacional)

**REQ-GEO-010: Rescatistas 15km inicial**

CUANDO se busquen rescatistas ENTONCES el sistema DEBERÁ usar un radio inicial de búsqueda de 15km desde el punto de rescate

**REQ-GEO-011: Priorizar casas cuna disponibles ≤25km**

CUANDO se busquen rescatistas ENTONCES el sistema DEBERÁ priorizar aquellos con casas cuna disponibles en radio de 25km

**REQ-GEO-012: Considerar transporte >30km**

CUANDO se busquen rescatistas a más de 30km ENTONCES el sistema DEBERÁ considerar la capacidad de transporte del rescatista

**REQ-GEO-020: Veterinarios emergencias 20km**

CUANDO se busquen veterinarios para emergencias ENTONCES el sistema DEBERÁ usar un radio de búsqueda de 20km

**REQ-GEO-021: Veterinarios consultas 50km**

CUANDO se busquen veterinarios para consultas rutinarias ENTONCES el sistema DEBERÁ usar un radio de búsqueda de 50km

**REQ-GEO-022: Priorizar tarifas preferenciales**

CUANDO se busquen veterinarios ENTONCES el sistema DEBERÁ priorizar aquellos con tarifas preferenciales para rescate

#### 3.6.9. Reglas de Jurisdicción Gubernamental

**REQ-JUR-001: Definir jurisdicción con polígonos**

CUANDO un gobierno local se registre ENTONCES el sistema DEBERÁ permitir definir su jurisdicción mediante polígonos geográficos

**REQ-JUR-002: Solapamiento para zonas fronterizas**

CUANDO se definan jurisdicciones ENTONCES el sistema DEBERÁ permitir solapamiento para casos fronterizos

**REQ-JUR-003: Notificación a jurisdicciones solapadas**

CUANDO haya solapamiento de jurisdicciones ENTONCES el sistema DEBERÁ notificar a ambas jurisdicciones

**REQ-JUR-010: Aprobación financiera exclusiva por jurisdicción**

CUANDO se requiera subvención municipal ENTONCES SOLAMENTE los encargados de la jurisdicción correspondiente DEBERÁN poder aprobar o rechazar la subvención financiera; esta aprobación no condiciona la realización del procedimiento médico.

**REQ-JUR-011: Jurisdicción según ubicación exacta**

CUANDO se determine la jurisdicción ENTONCES el sistema DEBERÁ usar la ubicación exacta del animal reportado

**REQ-JUR-012: Autorización doble en zona fronteriza**

CUANDO un animal esté en zona fronteriza ENTONCES el sistema DEBERÁ requerir autorización de ambas jurisdicciones

**REQ-JUR-020: Carreteras nacionales → cantón más cercano**

CUANDO un animal esté en carreteras nacionales ENTONCES el sistema DEBERÁ asignar la jurisdicción del cantón más cercano

**REQ-JUR-021: Propiedad privada requiere autorización del dueño**

CUANDO un animal esté en propiedades privadas ENTONCES el sistema DEBERÁ requerir autorización adicional del propietario

**REQ-JUR-022: Zonas protegidas requieren entidad ambiental**

CUANDO un animal esté en zonas protegidas ENTONCES el sistema DEBERÁ requerir autorización de la entidad ambiental nacional (ej: SINAC en Costa Rica) además del gobierno local

#### 3.6.10. Validación de Ubicaciones

**REQ-VAL-001: GPS ≥10m en solicitudes de auxilio**

CUANDO se capture ubicación GPS para solicitudes de auxilio ENTONCES el sistema DEBERÁ requerir precisión mínima de 10 metros

**REQ-VAL-002: GPS ≥5m al confirmar rescate**

CUANDO se confirme un rescate ENTONCES el sistema DEBERÁ requerir precisión mínima GPS de 5 metros

**REQ-VAL-003: Ubicación manual con confirmación posterior**

CUANDO no haya GPS disponible ENTONCES el sistema DEBERÁ permitir ubicación manual con confirmación posterior

**REQ-VAL-010: Coordenadas dentro del país**

CUANDO se ingresen coordenadas ENTONCES el sistema DEBERÁ verificar que estén dentro del territorio del país de operación

**REQ-VAL-011: Rechazar coordenadas en océano**

CUANDO se ingresen coordenadas ENTONCES el sistema DEBERÁ rechazar coordenadas en océano (excepto islas habitadas)

**REQ-VAL-012: Coordenadas deben corresponder a dirección**

CUANDO se ingresen coordenadas ENTONCES el sistema DEBERÁ validar que correspondan a la dirección proporcionada

#### 3.6.11. Estados y Transiciones de Workflow

**REQ-WF-001: Auxilio inicia en CREADA**

CUANDO se cree una solicitud de auxilio ENTONCES el sistema DEBERÁ asignar el estado inicial "CREADA"

**REQ-WF-002: Transiciones válidas desde CREADA (auxilio)**

CUANDO una solicitud de auxilio esté en estado "CREADA" ENTONCES el sistema DEBERÁ permitir transición a "EN_REVISION", "ASIGNADA" o "RECHAZADA"

**REQ-WF-003: Transiciones desde ASIGNADA (auxilio)**

CUANDO una solicitud de auxilio esté "ASIGNADA" ENTONCES el sistema DEBERÁ permitir transición a "EN_PROGRESO" o "COMPLETADA"

**REQ-WF-010: Rescate inicia en CREADA**

CUANDO se cree una solicitud de rescate ENTONCES el sistema DEBERÁ asignar el estado inicial "CREADA"

**REQ-WF-011: Rescate pasa a PENDIENTE_AUTORIZACION**

CUANDO una solicitud de rescate requiera autorización veterinaria ENTONCES el sistema DEBERÁ cambiar automáticamente a estado "PENDIENTE_AUTORIZACION"

**REQ-WF-012: Rescate cambia a AUTORIZADA**

CUANDO se autorice una solicitud de rescate ENTONCES el sistema DEBERÁ cambiar a estado "AUTORIZADA"

**REQ-WF-020: Adopción inicia en CREADA**

CUANDO se cree una solicitud de adopción ENTONCES el sistema DEBERÁ asignar el estado inicial "CREADA"

**REQ-WF-021: Adopción pasa a VALIDADA**

CUANDO un animal cumpla requisitos de adoptabilidad ENTONCES el sistema DEBERÁ cambiar automáticamente a estado "VALIDADA"

**REQ-WF-022: Adopción se puede PUBLICAR**

CUANDO un animal esté validado para adopción ENTONCES el sistema DEBERÁ permitir cambio a estado "PUBLICADA"

**REQ-WF-030: Animal inicia en REPORTADO**

CUANDO se reporte un animal ENTONCES el sistema DEBERÁ asignar el estado inicial "REPORTADO"

**REQ-WF-031: Confirmación cambia a EVALUADO**

CUANDO un auxiliar confirme la situación ENTONCES el sistema DEBERÁ cambiar automáticamente el estado del animal a "EVALUADO"

**REQ-WF-032: Rescate completo → EN_CUIDADO**

CUANDO se complete un rescate ENTONCES el sistema DEBERÁ cambiar el estado del animal a "EN_CUIDADO"

**REQ-WF-040: Confirmación crea solicitud de rescate**

CUANDO un auxiliar confirme una situación real ENTONCES el sistema DEBERÁ crear automáticamente una solicitud de rescate

**REQ-WF-041: Evaluación automática de adoptabilidad**

CUANDO se actualicen atributos de un animal ENTONCES el sistema DEBERÁ evaluar automáticamente si cumple requisitos de adoptabilidad

**REQ-WF-042: Cambio automático a ADOPTABLE**

CUANDO un animal cumpla todos los requisitos Y no tenga restricciones ENTONCES el sistema DEBERÁ cambiar automáticamente su estado a "ADOPTABLE"

**REQ-WF-050:** CUANDO se cree una Solicitud de Subvención Municipal ENTONCES el estado inicial DEBERÁ ser `CREADA`.

**REQ-WF-051:** CUANDO una solicitud de subvención entre a evaluación ENTONCES el estado DEBERÁ ser `EN_REVISION`.

**REQ-WF-052:** CUANDO la municipalidad apruebe ENTONCES el estado DEBERÁ cambiar a `APROBADA` y se DEBERÁ emitir factura a nombre de la municipalidad.

**REQ-WF-053:** CUANDO la municipalidad rechace ENTONCES el estado DEBERÁ cambiar a `RECHAZADA` y se DEBERÁ emitir factura a nombre del rescatista.

**REQ-WF-054:** CUANDO venza el “Tiempo máximo de respuesta para subvencionar” sin resolución ENTONCES el estado DEBERÁ cambiar automáticamente a `EXPIRADA` y se DEBERÁ emitir factura a nombre del rescatista.

#### 3.6.12. Notificaciones Automáticas por Estados

**REQ-NOT-001: Notificar auxiliares 10km al crear auxilio**

CUANDO se cree una solicitud de auxilio ENTONCES el sistema DEBERÁ notificar automáticamente a auxiliares en radio de 10km

**REQ-NOT-002: Expandir notificaciones 25km a 30 min**

CUANDO no haya respuesta en 30 minutos ENTONCES el sistema DEBERÁ expandir notificaciones a auxiliares en radio de 25km

**REQ-NOT-003: Notificar rescatistas al crear rescate**

CUANDO se cree una solicitud de rescate ENTONCES el sistema DEBERÁ notificar a rescatistas disponibles en la zona

**REQ-NOT-004: Notificar encargado jurisdiccional**

CUANDO se requiera autorización veterinaria ENTONCES el sistema DEBERÁ notificar al encargado de bienestar animal jurisdiccional

**REQ-NOT-005: Notificar adoptantes coincidentes**

CUANDO un animal esté disponible para adopción ENTONCES el sistema DEBERÁ notificar a adoptantes con preferencias coincidentes

**REQ-NOT-006: Notificar municipal/vet/rescatista en subvención**

CUANDO se cree una Solicitud de Subvención Municipal ENTONCES el sistema DEBERÁ notificar al encargado municipal correspondiente; CUANDO la solicitud sea resuelta o expire ENTONCES DEBERÁ notificar a veterinario y rescatista.

#### 3.6.13. Arquitectura Multi-Tenant Híbrida

**REQ-MT-001: Datos de AltruPets centralizados**

CUANDO se almacenen datos de AltruPets ENTONCES el sistema DEBERÁ mantener centralizados los datos de usuarios, animales, rescates, donaciones, veterinarios y casas cuna de rescatistas

**REQ-MT-002: Datos gubernamentales segregados por tenant**

CUANDO se almacenen datos gubernamentales ENTONCES el sistema DEBERÁ segregar por tenant ÚNICAMENTE las autorizaciones veterinarias, reportes jurisdiccionales y políticas locales

**REQ-MT-003: Acceso gubernamental a datos en su jurisdicción**

CUANDO un gobierno local acceda al sistema ENTONCES DEBERÁ ver solo sus datos gubernamentales segregados pero tener acceso a los datos centralizados de AltruPets en su jurisdicción

**REQ-MT-004: Reportes filtrados por jurisdicción**

CUANDO se generen reportes gubernamentales ENTONCES el sistema DEBERÁ filtrar los datos centralizados por jurisdicción geográfica del tenant

**REQ-MT-005: RLS solo en tablas gubernamentales**

CUANDO se implemente Row Level Security ENTONCES DEBERÁ aplicarse ÚNICAMENTE a tablas gubernamentales (autorizaciones veterinarias, reportes, mediación de conflictos)

**REQ-MT-006: Terminología “casa cuna de rescatistas”**

CUANDO se refiera a instalaciones de rescatistas ENTONCES el sistema DEBERÁ usar la terminología "casa cuna de rescatistas" en lugar de "refugios" o "shelters" para distinguir de refugios gubernamentales

**REQ-MT-007: Colaboración transfronteriza con datos centralizados**

CUANDO un rescatista de un país ayude en otro país ENTONCES el sistema DEBERÁ permitir la colaboración transfronteriza manteniendo los datos centralizados accesibles

**REQ-MT-008: Visibilidad global restringida para Superadministrador**

CUANDO un SRE acceda al sistema ENTONCES DEBERÁ poder consultar métricas y reportes globales multi-tenant SIN acceso directo a datos gubernamentales segregados, salvo agregados o métricas anonimizadas.

**REQ-MT-009: Acceso jurisdiccional para Auditores**

CUANDO un Auditor Gubernamental/Ambiental acceda al sistema ENTONCES DEBERÁ ver únicamente sus datos gubernamentales segregados y datos centralizados de AltruPets dentro de su jurisdicción, con filtros de propósito y trazabilidad reforzada.

**REQ-MT-010: Prohibición de acceso cross-tenant sin aprobación explícita**

CUANDO se requiera acceso a datos de otro tenant ENTONCES el sistema DEBERÁ prohibirlo salvo aprobación explícita y verificable del tenant afectado y cumplimiento de `REQ-SEC-007`.

#### 3.6.14. Integración con Terceros

**REQ-INT-001: Adapter para ONVOPay**

CUANDO se integre con ONVOPay ENTONCES el sistema DEBERÁ implementar patrón Adapter para facilitar cambios de proveedor

**REQ-INT-002: Método alternativo si ONVOPay no está**

CUANDO ONVOPay no esté disponible ENTONCES el sistema DEBERÁ ofrecer métodos alternativos como transferencia bancaria

**REQ-INT-003: Soporte Google Maps y MapBox**

CUANDO se requieran mapas ENTONCES el sistema DEBERÁ soportar tanto Google Maps como MapBox según disponibilidad

## 4. Apéndices

### Apéndice A: Modelado de Roles de Usuario

#### A.1. Jerarquía de Roles del Sistema

El sistema AltruPets implementa un modelo de roles basado en RBAC (Role-Based Access Control) que distingue entre usuarios individuales, organizacionales y gubernamentales.

#### A.2. Roles Operativos Principales

##### A.2.1. Centinela
- **Definición:** Persona que alerta sobre animales abandonados, maltratados, desnutridos, malheridos, enfermos o accidentados que necesitan auxilio inmediato
- **Responsabilidades:**
  - Identificar y reportar animales en situación vulnerable
  - Crear alertas con ubicación, descripción y evidencia fotográfica
  - Comunicarse con auxiliares para coordinar rescate inmediato
  - Seguimiento del estado de las alertas creadas
- **Permisos del sistema:**
  - Crear alertas de rescate
  - Acceso a chat con auxiliares y rescatistas
  - Consultar estado de casos reportados
  - Calificar auxiliares y rescatistas
- **Requisitos de registro:**
  - Datos personales básicos
  - Ubicación geográfica
  - Motivación para rescate animal
  - Aceptación de términos y condiciones

##### A.2.2. Auxiliar
- **Definición:** Persona con capacidad de brindar auxilio inmediato a animales vulnerables, pero sin capacidad de refugio a largo plazo. Usualmente entrega el animal a un rescatista
- **Responsabilidades:**
  - Responder a alertas de centinelas en su área
  - Brindar auxilio inmediato a animales en riesgo
  - Transportar animales rescatados a rescatistas con casa cuna
  - Documentar el estado del animal durante el rescate
- **Permisos del sistema:**
  - Recibir notificaciones de alertas cercanas
  - Aceptar/declinar solicitudes de rescate
  - Acceso a chat con centinelas y rescatistas
  - Documentar rescates con fotografías
  - Calificar centinelas y rescatistas
- **Requisitos de registro:**
  - Datos personales completos
  - Verificación de capacidad de transporte
  - Disponibilidad horaria
  - Experiencia en manejo de animales

##### A.2.3. Rescatista
- **Definición:** Persona con casa cuna que puede rescatar y cuidar animales a largo plazo, proporcionando comida, vacunas, castración y cuidado maternal
- **Responsabilidades:**
  - Recibir animales de auxiliares
  - Proporcionar casa cuna y cuidado a largo plazo
  - Gestionar proceso de adopción
  - Coordinar atención veterinaria
  - Mantener registros financieros transparentes
- **Permisos del sistema:**
  - Gestión completa de casa cuna
  - Recepción y gestión de donaciones
  - Coordinación con veterinarios
  - Publicación de animales para adopción
  - Generación de reportes financieros
- **Requisitos de registro:**
  - Documentación completa de casa cuna
  - Credenciales y experiencia verificada
  - Capacidad financiera demostrada
  - Ubicación y recursos disponibles

##### A.2.4. Adoptante
- **Definición:** Persona que desea adoptar animales rescatados, preferiblemente castrados y vacunados
- **Responsabilidades:**
  - Buscar y seleccionar animales para adopción
  - Cumplir con proceso de evaluación
  - Firmar contratos de adopción
  - Proporcionar seguimiento post-adopción
- **Permisos del sistema:**
  - Búsqueda de animales disponibles
  - Solicitar adopciones
  - Comunicación con rescatistas
  - Acceso a historial médico del animal
- **Requisitos de registro:**
  - Datos personales y de contacto
  - Preferencias de adopción
  - Experiencia con mascotas
  - Verificación de capacidad de cuidado

##### A.2.5. Donante
- **Definición:** Persona física o jurídica que sufraga gastos asociados al rescate animal sin adoptar
- **Responsabilidades:**
  - Realizar donaciones monetarias o de insumos
  - Mantener transparencia en origen de fondos
  - Seguimiento del uso de donaciones
- **Permisos del sistema:**
  - Realizar donaciones únicas o recurrentes
  - Seleccionar casas cuna beneficiarias
  - Consultar transparencia de uso de fondos
  - Calificar rescatistas
- **Requisitos de registro:**
  - Información KYC según monto de donación
  - Verificación de origen lícito de fondos
  - Datos bancarios para donaciones recurrentes

##### A.2.6. Veterinario
- **Definición:** Profesional con credenciales para atención médica animal
- **Responsabilidades:**
  - Proporcionar atención médica a animales rescatados
  - Ofrecer tarifas preferenciales para rescate
  - Mantener historial médico actualizado
  - Derivar casos especializados
- **Permisos del sistema:**
  - Recibir solicitudes de atención médica
  - Registrar diagnósticos y tratamientos
  - Facturación de servicios
  - Acceso a historial médico de animales
- **Requisitos de registro:**
  - Credenciales profesionales verificadas
  - Número de colegiado vigente
  - Especialidades y servicios ofrecidos
  - Tarifas preferenciales para rescate

#### A.3. Roles Administrativos

##### A.3.1. Representante Legal (Organizacional)
- **Definición:** Máxima autoridad de una organización registrada
- **Permisos:** Gestión completa de la organización, asignación de roles, decisiones críticas

##### A.3.2. Administrador de Usuarios (Organizacional)
- **Definición:** Gestiona membresías y roles dentro de una organización
- **Permisos:** Aprobar/rechazar membresías, asignar roles operativos, gestionar permisos

##### A.3.3. Administrador Gubernamental
- **Definición:** Autoridad local que supervisa actividades en su jurisdicción
- **Permisos:** Supervisión jurisdiccional, mediación de conflictos, reportes oficiales

##### A.3.4. Superadministrador de Plataforma (SRE)
- **Definición:** Rol operativo de plataforma con responsabilidad de confiabilidad y operación multi-tenant
- **Permisos:** Generación de reportes administrativos/operativos globales, acceso solo lectura con PII minimizada, inicio de proceso break-glass bajo `REQ-SEC-007`

##### A.3.5. Auditor Gubernamental/Ambiental
- **Definición:** Rol de auditoría para entidades gubernamentales (municipalidades, SINAC u homólogos)
- **Permisos:** Generación de reportes oficiales y de auditoría acotados a su jurisdicción, acceso solo lectura con PII minimizada, exportación controlada y auditada

#### A.4. Matriz de Permisos por Rol

| Funcionalidad | Centinela | Auxiliar | Rescatista | Adoptante | Donante | Veterinario |
|---------------|-----------|----------|------------|-----------|---------|-------------|
| Crear alertas | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Responder alertas | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ |
| Gestionar casa cuna | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |
| Solicitar adopción | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Realizar donaciones | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Atención veterinaria | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Chat interno | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Calificar usuarios | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

### Apéndice B: Arquitectura Técnica del Sistema

El sistema AltruPets está diseñado como una **arquitectura de microservicios cloud-native** siguiendo los principios de 12-factor app y patrones de diseño para microservicios en Kubernetes/OpenShift:

#### Principios Arquitectónicos

- **Microservicios Autocontenidos:** Cada servicio es una unidad independiente con su propia base de datos
- **API-First:** Comunicación a través de APIs REST bien definidas y GraphQL para consultas complejas
- **Cloud-Native:** Optimizado para contenedorización con Podman/Docker y orquestación con Kubernetes
- **Headless:** Desacoplamiento completo entre frontend y backend
- **Stateless:** Procesos sin estado que externalizan datos de sesión
- **Observabilidad:** Telemetría continua con métricas, logs y trazas distribuidas

#### Frontend (Aplicación Móvil Flutter)

**Responsabilidades principales:**

- Interfaz de usuario y experiencia del usuario (UI/UX)
- Captura y validación básica de datos de formularios
- Gestión de estado local y caché offline
- Comunicación con APIs del backend mediante REST y WebSockets
- Manejo de notificaciones push (mostrar)
- Geolocalización y integración con mapas
- Captura de fotos y multimedia
- WebViews para pagos seguros (sin procesar datos sensibles)

**Arquitectura Flutter Clean Architecture:**

- **Capa de Presentación**: Pages, State Management (Riverpod), Widgets reutilizables
- **Capa de Dominio**: Entities, Repository interfaces, Use Cases (código Dart puro)
- **Capa de Datos**: Models, Repository implementations, Data Sources (remote/local)

**Patrones implementados:**

- Clean Architecture con tres capas bien definidas
- Inyección de dependencias con Riverpod
- Gestión de estado centralizada con Riverpod
- Repository pattern para acceso a datos
- Client-side UI composition
- Externalized configuration mediante ConfigMaps
- Health Check API para monitoreo
- Offline-first strategy con SQLite
- Feature-based project structure

#### Backend (Arquitectura de Microservicios)

**Microservicios principales:**

##### 1. **User Management Service**

- Autenticación y autorización (RBAC)
- Gestión de usuarios individuales y organizacionales
- Control de acceso basado en roles
- Base de datos: PostgreSQL con encriptación

##### 2. **Animal Rescue Service**

- Gestión de denuncias anónimas
- Coordinación de rescates entre centinelas, auxiliares y rescatistas
- Gestión de casas cuna e inventario de animales
- Base de datos: PostgreSQL con datos geoespaciales

##### 3. **Veterinary Service**

- Red de veterinarios colaboradores
- Gestión de solicitudes de atención médica
- Historial médico de animales
- Base de datos: PostgreSQL

##### 4. **Financial Service**

- Procesamiento de donaciones y pagos (PCI DSS compliant)
- Gestión financiera y contable de rescatistas
- Integración con ONVOPay mediante patrón Adapter
- Cumplimiento regulatorio y KYC
- Base de datos: PostgreSQL con encriptación de nivel bancario

##### 5. **Notification Service**

- Gestión de notificaciones push
- Sistema de chat interno en tiempo real
- WebSockets para comunicación instantánea
- Base de datos: Redis para caché y MongoDB para persistencia

##### 6. **Geolocation Service**

- Cálculos geoespaciales y búsquedas por proximidad
- Optimización de rutas para rescates
- Base de datos: PostGIS (PostgreSQL con extensiones geoespaciales)

##### 7. **Reputation Service**

- Sistema de calificaciones y reputación
- Detección de patrones sospechosos con ML
- Base de datos: PostgreSQL

##### 8. **Government Service**

- Administración gubernamental multi-tenant
- Mediación de conflictos
- Reportes de transparencia
- Base de datos: PostgreSQL con segregación por jurisdicción

##### 9. **Analytics Service**

- Algoritmos de machine learning para detección de anomalías
- Generación de reportes y análisis
- Métricas de impacto y KPIs
- Base de datos: ClickHouse para analytics

**Patrones de microservicios implementados:**

- **Database per Service:** Cada microservicio tiene su propia base de datos
- **API Gateway:** Punto único de entrada con enrutamiento y autenticación
- **Service Discovery:** Descubrimiento automático de servicios en Kubernetes
- **Circuit Breaker:** Tolerancia a fallos entre servicios
- **Saga Pattern:** Transacciones distribuidas para operaciones complejas
- **CQRS:** Separación de comandos y consultas en servicios críticos
- **Event Sourcing:** Para auditoría y trazabilidad de transacciones financieras

### Apéndice C: Stack Tecnológico y Responsabilidades

#### Frontend (Flutter App) - `/mobile`

**Responsabilidades principales:**

- Interfaz de usuario y experiencia del usuario (UI/UX)
- Captura y validación básica de datos de formularios
- Gestión de estado local y caché offline (siguiendo principio stateless)
- Comunicación con API Gateway del backend
- Manejo de notificaciones push (mostrar)
- Geolocalización y integración con mapas
- Captura de fotos y multimedia
- WebViews para pagos seguros (sin procesar datos sensibles)
- Chat en tiempo real (interfaz WebSocket)

**Tecnologías cloud-native:**

- **Flutter/Dart**: Framework multiplataforma con Clean Architecture
- **Gestión de estado**: riverpod para estado centralizado y DI
- **Casos de uso**: dartz para Either y manejo funcional de errores
- **Almacenamiento local**: sqflite para BD local, flutter_secure_storage para datos sensibles
- **Comunicación HTTP**: dio con interceptores para logging y retry
- **Navegación**: go_router para routing declarativo
- **Serialización**: json_annotation + freezed para modelos inmutables
- **Testing**: mockito para mocks, riverpod_test para testing de providers
- **Generación de código**: build_runner para generación automática
- **Análisis de código**: flutter_lints para linting estricto
- **WebSocket**: Para comunicación en tiempo real
- **Firebase**: Messaging para push, Analytics y Crashlytics para monitoreo
- **Mapas**: Google Maps/MapBox para geolocalización
- **Conectividad**: connectivity_plus para detección de red

#### Backend (Arquitectura de Microservicios) - `/services`

**Stack tecnológico cloud-native:**

**Microservicios (cada uno siguiendo 12-factor app):**

- **Lenguajes:** Node.js/NestJS, Python/FastAPI, o Go
- **Contenedorización:** Docker/Podman
- **Orquestación:** Kubernetes/OpenShift
- **Service Mesh:** Istio para comunicación segura entre servicios

**Bases de datos (Database per Service):**

- **PostgreSQL:** Para User Management, Animal Rescue, Veterinary, Financial
- **PostGIS:** Para Geolocation Service (extensión geoespacial)
- **MongoDB:** Para Notification Service (chat y mensajes)
- **Redis:** Para caché distribuido y sesiones
- **ClickHouse:** Para Analytics Service (big data)

**Comunicación entre servicios:**

- **API Gateway:** Kong o Istio Gateway
- **REST APIs:** Para comunicación externa
- **gRPC:** Para comunicación interna entre microservicios
- **Message Broker:** Apache Kafka o RabbitMQ para eventos asíncronos
- **WebSockets:** Para chat en tiempo real

**Observabilidad y monitoreo:**

- **Métricas:** Prometheus + Grafana
- **Logs:** Loki (con Grafana)
- **Trazas distribuidas:** Grafana Tempo
- **Ingesta/Exportación:** OpenTelemetry Collector (OTLP)
- **Health checks:** Endpoints /health en cada servicio

**Seguridad y cumplimiento:**

- **Autenticación:** JWT con OAuth 2.0/OpenID Connect
- **Autorización:** RBAC implementado en cada microservicio
- **Secrets:** Kubernetes Secrets para credenciales
- **Encriptación:** TLS 1.3 para comunicación, AES-256 para datos en reposo
- **PCI DSS:** Cumplimiento en Financial Service

**CI/CD y GitOps:**

- **CI/CD:** GitLab CI/Jenkins con pipelines automatizados
- **GitOps:** ArgoCD para despliegue continuo
- **IaC:** Terraform/OpenTofu para infraestructura
- **Configuración:** Ansible para automatización

### Apéndice D: Estructura del Proyecto

```
centinelasalrescate/
├── mobile/                           # Aplicación Flutter
│   ├── lib/
│   │   ├── config/                  # Configuraciones globales
│   │   │   ├── theme/              # Temas visuales
│   │   │   └── routes/             # Rutas de navegación
│   │   ├── core/                   # Código compartido entre features
│   │   │   ├── constants/          # Constantes globales
│   │   │   ├── errors/             # Manejo de errores
│   │   │   ├── network/            # Configuración de red
│   │   │   ├── utils/              # Utilidades compartidas
│   │   │   └── use_cases/          # Casos de uso comunes
│   │   ├── features/               # Features organizadas por dominio
│   │   │   ├── auxilio/            # Feature de auxilio
│   │   │   │   ├── presentation/   # Capa de presentación
│   │   │   │   │   ├── pages/      # Páginas/pantallas
│   │   │   │   │   ├── providers/       # Riverpod providers
│   │   │   │   │   └── widgets/    # Widgets específicos
│   │   │   │   ├── domain/         # Capa de dominio
│   │   │   │   │   ├── entities/   # Entidades de negocio
│   │   │   │   │   ├── repositories/ # Interfaces de repositorio
│   │   │   │   │   └── use_cases/  # Casos de uso específicos
│   │   │   │   └── data/           # Capa de datos
│   │   │   │       ├── models/     # Modelos de datos
│   │   │   │       ├── repositories/ # Implementaciones de repositorio
│   │   │   │       └── data_sources/ # Fuentes de datos (remote/local)
│   │   │   ├── rescate/            # Feature de rescate
│   │   │   │   ├── presentation/
│   │   │   │   ├── domain/
│   │   │   │   └── data/
│   │   │   ├── adopcion/           # Feature de adopción
│   │   │   │   ├── presentation/
│   │   │   │   ├── domain/
│   │   │   │   └── data/
│   │   │   ├── donaciones/         # Feature de donaciones
│   │   │   │   ├── presentation/
│   │   │   │   ├── domain/
│   │   │   │   └── data/
│   │   │   └── veterinaria/        # Feature veterinaria
│   │   │       ├── presentation/
│   │   │       ├── domain/
│   │   │       └── data/
│   │   └── main.dart               # Punto de entrada
│   ├── android/
│   ├── ios/
│   ├── analysis_options.yaml       # Configuración de linting
│   └── pubspec.yaml
├── services/                         # Microservicios
│   ├── api-gateway/                 # API Gateway (Kong/Istio)
│   ├── user-management/             # Servicio de usuarios y RBAC
│   ├── animal-rescue/               # Servicio de rescates y denuncias
│   ├── veterinary/                  # Servicio veterinario
│   ├── financial/                   # Servicio financiero y pagos
│   ├── notification/                # Servicio de notificaciones y chat
│   ├── geolocation/                 # Servicio de geolocalización
│   ├── reputation/                  # Servicio de reputación
│   ├── government/                  # Servicio gubernamental
│   └── analytics/                   # Servicio de analytics y ML
├── shared/                          # Código compartido
│   ├── models/                      # Modelos de datos
│   ├── constants/                   # Constantes compartidas
│   ├── utils/                       # Utilidades comunes
│   └── proto/                       # Definiciones gRPC
├── infrastructure/                   # Infraestructura como código
│   ├── kubernetes/                  # Manifiestos K8s
│   ├── terraform/                   # Infraestructura con Terraform
│   ├── ansible/                     # Configuración con Ansible
│   └── argocd/                      # GitOps con ArgoCD
├── docs/                            # Documentación
├── scripts/                         # Scripts de deployment
└── docker-compose.yml               # Para desarrollo local
```

### Apéndice E: Principios de 12-Factor App Implementados

1. **Codebase:** Un repositorio por microservicio
2. **Dependencies:** Dependencias declaradas en contenedores
3. **Config:** Configuración en ConfigMaps y Secrets de Kubernetes
4. **Backing Services:** Bases de datos y servicios externos como recursos adjuntos
5. **Build/Release/Run:** Pipeline CI/CD automatizado con GitOps
6. **Processes:** Servicios stateless con datos externalizados
7. **Port Binding:** Cada servicio expone su propio puerto
8. **Concurrency:** Escalado horizontal mediante réplicas en Kubernetes
9. **Disposability:** Inicio/parada rápida de contenedores
10. **Dev/Prod Parity:** Entornos idénticos con contenedores
11. **Logs:** Logs como streams a stdout/stderr
12. **Admin Processes:** Tareas administrativas como Jobs de Kubernetes

### Apéndice F: Modelos de Datos para Reglas de Negocio

#### F.1. Estructura de Datos de Animales

```typescript
// Condiciones del Animal
interface AnimalConditions {
  discapacitado: boolean;        // Animal con limitaciones físicas permanentes
  pacienteCronico: boolean;      // Requiere medicación o cuidados continuos
  zeropositivo: boolean;         // SIDA felino o Leucemia felina
  callejero: boolean;            // Animal sin hogar identificado
}

// Requisitos de Adoptabilidad (TODOS deben ser TRUE)
interface AdoptabilityRequirements {
  usaArenero: boolean;           // Entrenado para usar arenero
  comePorSiMismo: boolean;       // Capaz de alimentarse independientemente
}

// Restricciones de Adoptabilidad (CUALQUIERA impide adopción)
interface AdoptabilityRestrictions {
  arizcoConHumanos: boolean;     // Comportamiento agresivo/temeroso hacia personas
  arizcoConAnimales: boolean;    // Comportamiento agresivo hacia otros animales
  lactante: boolean;             // Aún requiere leche materna
  nodriza: boolean;              // Hembra amamantando crías
  enfermo: boolean;              // Condición médica activa que requiere tratamiento
  herido: boolean;               // Lesiones físicas que requieren atención
  recienParida: boolean;         // Hembra que dio a luz recientemente (<8 semanas)
  recienNacido: boolean;         // Animal menor a 8 semanas de edad
}

// Modelo completo del Animal
interface Animal {
  id: string;
  nombre?: string;
  especie: 'GATO' | 'PERRO' | 'OTRO';
  edad?: number;
  sexo?: 'MACHO' | 'HEMBRA';
  condiciones: AnimalConditions;
  requisitos: AdoptabilityRequirements;
  restricciones: AdoptabilityRestrictions;
  estado: AnimalState;
  ubicacion: Coordenadas;
  rescatistaId?: string;
  casaCunaId?: string;
}

// Modelo de Solicitud de Subvención Municipal
interface SolicitudSubvencion {
  id: string;
  casoId: string;
  animal: Animal;
  veterinarioId: string;
  clinicaId?: string;
  montoTentativo: number;
  desgloseServicios: string[];
  fechaProcedimiento: Date;
  ubicacion: Coordenadas;
  estado: SolicitudSubvencionState;
  municipalidadId: string;
  encargadoId?: string;
  fechaCreacion: Date;
  fechaVencimiento: Date;
  justificacionRechazo?: string;
  soportesAdjuntos: string[];
}
```

#### F.2. Estados de Workflow

```typescript
// Estados de Solicitudes de Auxilio
enum SolicitudAuxilioState {
  CREADA = 'CREADA',
  EN_REVISION = 'EN_REVISION',
  ASIGNADA = 'ASIGNADA',
  EN_PROGRESO = 'EN_PROGRESO',
  COMPLETADA = 'COMPLETADA',
  RECHAZADA = 'RECHAZADA'
}

// Estados de Solicitudes de Rescate
enum SolicitudRescateState {
  CREADA = 'CREADA',
  PENDIENTE_AUTORIZACION = 'PENDIENTE_AUTORIZACION',
  AUTORIZADA = 'AUTORIZADA',
  ASIGNADA = 'ASIGNADA',
  EN_PROGRESO = 'EN_PROGRESO',
  RESCATADO = 'RESCATADO',
  COMPLETADA = 'COMPLETADA',
  RECHAZADA = 'RECHAZADA'
}

// Estados de Solicitudes de Adopción
enum SolicitudAdopcionState {
  CREADA = 'CREADA',
  PENDIENTE_REQUISITOS = 'PENDIENTE_REQUISITOS',
  VALIDADA = 'VALIDADA',
  PUBLICADA = 'PUBLICADA',
  EN_PROCESO = 'EN_PROCESO',
  ADOPTADO = 'ADOPTADO',
  RECHAZADA = 'RECHAZADA'
}

// Estados de Solicitudes de Subvención Municipal
enum SolicitudSubvencionState {
  CREADA = 'CREADA',
  EN_REVISION = 'EN_REVISION',
  APROBADA = 'APROBADA',
  RECHAZADA = 'RECHAZADA',
  EXPIRADA = 'EXPIRADA'
}

// Estados del Ciclo de Vida del Animal
enum AnimalState {
  REPORTADO = 'REPORTADO',
  EVALUADO = 'EVALUADO',
  EN_RESCATE = 'EN_RESCATE',
  EN_CUIDADO = 'EN_CUIDADO',
  ADOPTABLE = 'ADOPTABLE',
  ADOPTADO = 'ADOPTADO',
  NO_ADOPTABLE = 'NO_ADOPTABLE',
  FALLECIDO = 'FALLECIDO',
  INALCANZABLE = 'INALCANZABLE',
  FALSA_ALARMA = 'FALSA_ALARMA'
}
```

#### F.3. Algoritmos de Priorización

```typescript
// Algoritmo de Priorización de Auxiliares
interface AuxiliarScore {
  distancia: number;        // Peso: 40%
  reputacion: number;       // Peso: 30%
  disponibilidad: number;   // Peso: 20%
  experiencia: number;      // Peso: 10%
}

function calcularPrioridadAuxiliar(auxiliar: Auxiliar, solicitud: SolicitudAuxilio): number {
  const distancia = calcularDistancia(auxiliar.ubicacion, solicitud.ubicacion);
  const scoreDistancia = Math.max(0, 100 - (distancia / 1000)); // 1km = 1 punto menos
  
  const scoreReputacion = auxiliar.reputacion * 20; // 0-5 estrellas * 20
  const scoreDisponibilidad = auxiliar.disponible ? 100 : 0;
  const scoreExperiencia = Math.min(100, auxiliar.rescatesCompletados * 2);
  
  return (scoreDistancia * 0.4) + 
         (scoreReputacion * 0.3) + 
         (scoreDisponibilidad * 0.2) + 
         (scoreExperiencia * 0.1);
}

// Algoritmo de Priorización de Rescatistas
interface RescatistaScore {
  distancia: number;           // Peso: 30%
  capacidadCasaCuna: number;   // Peso: 25%
  reputacion: number;          // Peso: 25%
  especializacion: number;     // Peso: 20%
}

function calcularPrioridadRescatista(rescatista: Rescatista, solicitud: SolicitudRescate): number {
  const distancia = calcularDistancia(rescatista.ubicacion, solicitud.ubicacion);
  const scoreDistancia = Math.max(0, 100 - (distancia / 1000));
  
  const capacidadDisponible = rescatista.casasCuna.reduce((total, casa) => 
    total + (casa.capacidadMaxima - casa.animalesActuales), 0);
  const scoreCapacidad = Math.min(100, capacidadDisponible * 10);
  
  const scoreReputacion = rescatista.reputacion * 20;
  
  const tieneEspecializacion = rescatista.especializaciones.some(esp => 
    solicitud.animal.condiciones.includes(esp));
  const scoreEspecializacion = tieneEspecializacion ? 100 : 50;
  
  return (scoreDistancia * 0.3) + 
         (scoreCapacidad * 0.25) + 
         (scoreReputacion * 0.25) + 
         (scoreEspecializacion * 0.2);
}
```

#### F.4. Validaciones de Reglas de Negocio

```typescript
// Validación de Adoptabilidad
function validateAdoptable(animal: Animal): boolean {
  // Verificar requisitos (TODOS deben ser TRUE)
  const requirements = animal.requisitos.usaArenero && animal.requisitos.comePorSiMismo;
  
  // Verificar restricciones (NINGUNA debe ser TRUE)
  const restrictions = !animal.restricciones.arizcoConHumanos && 
                      !animal.restricciones.arizcoConAnimales && 
                      !animal.restricciones.lactante && 
                      !animal.restricciones.nodriza && 
                      !animal.restricciones.enfermo && 
                      !animal.restricciones.herido && 
                      !animal.restricciones.recienParida && 
                      !animal.restricciones.recienNacido;
  
  return requirements && restrictions;
}

// Validación de Subvención Municipal
function validateMunicipalSubsidy(
  solicitud: SolicitudSubvencion, 
  encargado: EncargadoBienestar
): boolean {
  // Verificar jurisdicción
  const enJurisdiccion = isWithinJurisdiction(
    solicitud.ubicacion, 
    encargado.jurisdiccion
  );
  
  // Verificar condición callejero
  const esCallejero = solicitud.animal.condiciones.callejero === true;
  
  return enJurisdiccion && esCallejero;
}

// Validación de Integridad de Atributos
function validateAnimalIntegrity(animal: Animal): ValidationResult {
  const errors: string[] = [];
  
  // BR-081: No puede comer por sí mismo si es lactante
  if (animal.requisitos.comePorSiMismo && animal.restricciones.lactante) {
    errors.push('Un animal lactante no puede comer por sí mismo');
  }
  
  // BR-082: Recién nacido automáticamente es lactante
  if (animal.restricciones.recienNacido && !animal.restricciones.lactante) {
    errors.push('Un animal recién nacido debe ser marcado como lactante');
  }
  
  return {
    valid: errors.length === 0,
    errors
  };
}
```

---

*Este documento cumple con el estándar IEEE 830-1998 para especificaciones de requisitos software y ha sido estructurado para facilitar el desarrollo de la plataforma AltruPets siguiendo principios de arquitectura de microservicios cloud-native.*

#### Estados de Solicitudes de Intervención Policial

**REQ-WF-060:** CUANDO se cree una Solicitud de Intervención Policial ENTONCES el estado inicial DEBERÁ ser `CREADA`.

**REQ-WF-061:** CUANDO una solicitud de intervención policial sea recibida por las autoridades ENTONCES el estado DEBERÁ cambiar a `EN_REVISION`.

**REQ-WF-062:** CUANDO las autoridades policiales asignen el caso a un oficial ENTONCES el estado DEBERÁ cambiar a `ASIGNADA`.

**REQ-WF-063:** CUANDO el oficial de policía esté en camino o en el lugar ENTONCES el estado DEBERÁ cambiar a `EN_PROGRESO`.

**REQ-WF-064:** CUANDO se complete la intervención policial exitosamente ENTONCES el estado DEBERÁ cambiar a `COMPLETADA`.

**REQ-WF-065:** CUANDO las autoridades rechacen la solicitud o se nieguen a actuar ENTONCES el estado DEBERÁ cambiar a `RECHAZADA` con justificación obligatoria.

**REQ-WF-066:** CUANDO no haya respuesta policial en los tiempos establecidos ENTONCES el estado DEBERÁ cambiar automáticamente a `ESCALADA` y notificar a supervisores.

**REQ-WF-067:** CUANDO la situación se resuelva sin intervención policial ENTONCES el estado DEBERÁ cambiar a `RESUELTA_SIN_INTERVENCION`.

#### Notificaciones para Intervención Policial

**REQ-NOT-007: Notificar autoridades policiales al crear solicitud**

CUANDO se cree una solicitud de intervención policial ENTONCES el sistema DEBERÁ notificar automáticamente a la estación de policía de la jurisdicción correspondiente con todos los detalles del caso.

**REQ-NOT-008: Escalamiento automático por falta de respuesta**

CUANDO no haya respuesta policial ENTONCES el sistema DEBERÁ escalar automáticamente:
- A supervisores policiales después de 2 horas para casos críticos
- A supervisores después de 24 horas para casos no críticos
- Notificar al rescatista sobre el estado del escalamiento

#### Modelo de Datos para Intervención Policial

```typescript
// Estados de Solicitudes de Intervención Policial
enum SolicitudIntervencionPolicialState {
  CREADA = 'CREADA',
  EN_REVISION = 'EN_REVISION', 
  ASIGNADA = 'ASIGNADA',
  EN_PROGRESO = 'EN_PROGRESO',
  COMPLETADA = 'COMPLETADA',
  RECHAZADA = 'RECHAZADA',
  ESCALADA = 'ESCALADA',
  RESUELTA_SIN_INTERVENCION = 'RESUELTA_SIN_INTERVENCION'
}

// Modelo de Solicitud de Intervención Policial
interface SolicitudIntervencionPolicial {
  id: string;
  rescatistaId: string;
  casoRelacionadoId?: string; // Puede estar relacionada con un rescate específico
  descripcionSituacion: string;
  tipoIntervencion: 'MALTRATO' | 'ANIMAL_AMARRADO' | 'ANIMAL_ENCERRADO' | 'RESISTENCIA_PROPIETARIO' | 'ESCOLTA_RESCATE' | 'OTRO';
  ubicacion: Coordenadas;
  direccionCompleta: string;
  evidenciaFotografica: string[]; // URLs de fotos/videos
  referenciaLegal: string; // Artículo específico de la Ley de Maltrato Animal
  nivelUrgencia: 'BAJO' | 'MEDIO' | 'ALTO' | 'CRITICO';
  requiereEscolta: boolean;
  detallesEscolta?: string;
  estado: SolicitudIntervencionPolicialState;
  estacionPolicialId: string;
  oficialAsignadoId?: string;
  fechaCreacion: Date;
  fechaVencimiento: Date;
  fechaResolucion?: Date;
  accionesTomadas?: string;
  resultadoIntervencion?: string;
  justificacionRechazo?: string;
  numeroEscalamientos: number;
  contactoReferencia: {
    nombre: string;
    telefono: string;
    email: string;
    rol: 'RESCATISTA'; // Siempre el rescatista es la referencia
  };
}

// Validación de autorización para crear solicitud policial
function validatePolicialRequest(rescatista: Rescatista, solicitud: SolicitudIntervencionPolicial): boolean {
  // Solo rescatistas pueden crear solicitudes de intervención policial
  const esRescatista = rescatista.rol === 'RESCATISTA';
  
  // Debe tener experiencia mínima para casos críticos
  const tieneExperiencia = rescatista.rescatesCompletados >= 5 || solicitud.nivelUrgencia !== 'CRITICO';
  
  // Ubicación debe estar dentro de área de operación del rescatista
  const enAreaOperacion = isWithinOperationArea(solicitud.ubicacion, rescatista.areaOperacion);
  
  return esRescatista && tieneExperiencia && enAreaOperacion;
}
```

#### Integración con Autoridades Policiales

**REQ-POL-001: Registro de estaciones policiales**

CUANDO se configure el sistema ENTONCES DEBERÁ incluir registro de estaciones policiales por jurisdicción con:
- Información de contacto oficial
- Horarios de atención
- Oficiales especializados en maltrato animal
- Protocolos específicos de respuesta

**REQ-POL-002: Capacitación sobre legislación animal**

CUANDO se integre con autoridades policiales ENTONCES el sistema DEBERÁ proporcionar:
- Resumen de la legislación de maltrato animal aplicable
- Protocolos de actuación recomendados
- Formularios estándar para reportes
- Contactos de organizaciones de apoyo legal

**REQ-POL-003: Métricas de efectividad policial**

CUANDO se opere el sistema ENTONCES DEBERÁ generar métricas de:
- Tiempo promedio de respuesta por estación policial
- Tasa de resolución exitosa de casos
- Número de escalamientos por falta de respuesta
- Efectividad de intervenciones por tipo de caso

**REQ-POL-004: Reportes de transparencia policial**

CUANDO se requieran reportes ENTONCES el sistema DEBERÁ generar:
- Estadísticas de respuesta policial por jurisdicción
- Casos rechazados con justificaciones
- Tiempo promedio de resolución
- Impacto de las intervenciones en bienestar animal
#
### Estados de Crowdfunding para Transporte de Auxiliares

**REQ-WF-070:** CUANDO se cree una solicitud de crowdfunding para transporte ENTONCES el estado inicial DEBERÁ ser `CREADA`.

**REQ-WF-071:** CUANDO se valide y publique la solicitud de crowdfunding ENTONCES el estado DEBERÁ cambiar a `ACTIVA`.

**REQ-WF-072:** CUANDO se alcance la meta de recaudación ENTONCES el estado DEBERÁ cambiar a `META_ALCANZADA`.

**REQ-WF-073:** CUANDO se transfieran los fondos al auxiliar ENTONCES el estado DEBERÁ cambiar a `FONDOS_TRANSFERIDOS`.

**REQ-WF-074:** CUANDO el auxiliar presente comprobantes válidos de gasto ENTONCES el estado DEBERÁ cambiar a `COMPROBANTES_VALIDADOS`.

**REQ-WF-075:** CUANDO no se alcance la meta en 24 horas ENTONCES el estado DEBERÁ cambiar a `EXPIRADA` y devolver fondos proporcionalmente.

**REQ-WF-076:** CUANDO no se presenten comprobantes en 48 horas ENTONCES el estado DEBERÁ cambiar a `INCUMPLIDA` y suspender temporalmente al auxiliar.

#### Modelo de Datos para Crowdfunding de Transporte

```typescript
// Estados de Crowdfunding para Transporte
enum CrowdfundingTransporteState {
  CREADA = 'CREADA',
  ACTIVA = 'ACTIVA',
  META_ALCANZADA = 'META_ALCANZADA',
  FONDOS_TRANSFERIDOS = 'FONDOS_TRANSFERIDOS',
  COMPROBANTES_VALIDADOS = 'COMPROBANTES_VALIDADOS',
  EXPIRADA = 'EXPIRADA',
  INCUMPLIDA = 'INCUMPLIDA'
}

// Modelo de Crowdfunding para Transporte
interface CrowdfundingTransporte {
  id: string;
  auxiliarId: string;
  solicitudAuxilioId: string;
  descripcionCaso: string;
  ubicacionOrigen: Coordenadas;
  ubicacionDestino: Coordenadas;
  costosEstimados: {
    viajeIda: number;
    viajeVuelta: number;
    total: number;
  };
  metaRecaudacion: number;
  montoRecaudado: number;
  plazoLimite: Date;
  estado: CrowdfundingTransporteState;
  donaciones: {
    donante: string;
    monto: number;
    fecha: Date;
    metodoPago: string;
  }[];
  comprobantesGasto: {
    tipo: 'VIAJE_IDA' | 'VIAJE_VUELTA';
    proveedor: 'UBER' | 'DIDI' | 'INDRIVER' | 'TAXI' | 'OTRO';
    monto: number;
    comprobante: string; // URL del recibo
    fecha: Date;
  }[];
  fechaCreacion: Date;
  fechaCompletado?: Date;
  motivoIncumplimiento?: string;
}

// Validación de elegibilidad para crowdfunding
function validateCrowdfundingEligibility(auxiliar: Auxiliar): ValidationResult {
  const errors: string[] = [];
  
  // Máximo 2 solicitudes por mes
  const solicitudesEsteMes = auxiliar.crowdfundingHistorial.filter(
    cf => isCurrentMonth(cf.fechaCreacion)
  ).length;
  
  if (solicitudesEsteMes >= 2) {
    errors.push('Máximo 2 solicitudes de crowdfunding por mes');
  }
  
  // Verificar que no tenga transporte propio
  if (auxiliar.tieneTransportePropio) {
    errors.push('Auxiliar tiene transporte propio registrado');
  }
  
  // Verificar historial de rescates exitosos
  if (auxiliar.rescatesCompletados < 1) {
    errors.push('Requiere al menos 1 rescate completado exitosamente');
  }
  
  // Verificar que no tenga crowdfundings incumplidos
  const tieneIncumplimientos = auxiliar.crowdfundingHistorial.some(
    cf => cf.estado === 'INCUMPLIDA'
  );
  
  if (tieneIncumplimientos) {
    errors.push('Auxiliar tiene crowdfundings incumplidos pendientes');
  }
  
  return {
    valid: errors.length === 0,
    errors
  };
}
```

#### Integración con APIs de Transporte

**REQ-TRANS-001: Integración con APIs de cálculo de costos**

CUANDO se calcule el costo estimado de transporte ENTONCES el sistema DEBERÁ integrar con:
- API de Uber para cálculo de tarifas normales y Uber Pets
- API de Didi para tarifas locales donde esté disponible
- API de inDriver para comparación de precios
- Tarifas de taxi locales como referencia

**REQ-TRANS-002: Validación de comprobantes**

CUANDO un auxiliar presente comprobantes de gasto ENTONCES el sistema DEBERÁ:
- Validar que el monto coincida con lo recaudado (±10% de tolerancia)
- Verificar que las ubicaciones coincidan con la solicitud original
- Confirmar que la fecha del viaje sea posterior a la transferencia de fondos
- Aceptar recibos digitales de Uber, Didi, inDriver o fotografías de recibos de taxi

**REQ-TRANS-003: Métricas de efectividad del crowdfunding**

CUANDO se opere el sistema de crowdfunding ENTONCES DEBERÁ generar métricas de:
- Tasa de éxito en alcanzar metas de recaudación
- Tiempo promedio para completar crowdfunding
- Porcentaje de auxiliares que presentan comprobantes a tiempo
- Impacto en la participación de auxiliares sin transporte propio