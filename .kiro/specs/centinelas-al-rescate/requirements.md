# Documento de Requerimientos - Centinelas al Rescate

## Introducción

Centinelas al Rescate es una aplicación móvil desarrollada en Flutter que facilita la protección animal mediante un sistema integral que conecta a ciudadanos, sentinelas y rescatistas. La aplicación permite interponer denuncias anónimas de maltrato animal, coordinar solicitudes de rescate, y gestionar casas cuna para animales rescatados. El objetivo principal es crear una red colaborativa que agilice los procesos de rescate animal y mejore la respuesta ante situaciones de maltrato.

## Arquitectura del Sistema

El sistema está diseñado como una arquitectura distribuida con separación clara de responsabilidades:

### Frontend (Aplicación Móvil Flutter)

- **Responsabilidades principales:**
  - Interfaz de usuario e interacciones
  - Captura y validación básica de datos
  - Gestión de estado local y caché
  - Funcionalidad offline básica
  - Comunicación con APIs del backend
  - Manejo de notificaciones push
  - Geolocalización y mapas
  - Captura de fotos y multimedia

### Backend (API/Servicios)

- **Responsabilidades principales:**
  - Lógica de negocio compleja
  - Autenticación y autorización (RBAC)
  - Procesamiento de pagos y cumplimiento PCI DSS
  - Algoritmos de machine learning y detección de anomalías
  - Gestión de base de datos y persistencia
  - Integración con servicios externos
  - Cumplimiento regulatorio y KYC
  - Generación de reportes y análisis
  - Gestión de notificaciones push
  - Procesamiento de imágenes y archivos

## Requerimientos

### Requerimiento 1: Sistema de Registro de Usuarios y Control de Acceso Basado en Roles (RBAC)

**Historia de Usuario:** Como usuario interesado en participar en el rescate animal, quiero poder registrarme individualmente o como parte de una organización, con roles y permisos específicos según mi función, para acceder a las funcionalidades apropiadas de manera segura y organizada.

#### Criterios de Aceptación

**Frontend (Flutter App):**

1. CUANDO la aplicación se abra por primera vez ENTONCES el sistema DEBERÁ mostrar opciones: "Hacer Denuncia Anónima", "Registrarse como Usuario Individual" y "Registrar Nueva Organización"
2. CUANDO un usuario elija "Hacer Denuncia Anónima" ENTONCES el sistema DEBERÁ permitir acceso directo sin registro
3. CUANDO un usuario elija "Registrarse como Usuario Individual" ENTONCES el sistema DEBERÁ mostrar formularios para: datos personales completos, número de identificación, captura de fotografías del documento, email, teléfono, ubicación, roles deseados (Sentinela, Rescatista, Donante, Veterinario), y si incluye rol de Donante: ocupación, fuente de ingresos, y declaración de origen lícito de fondos
4. CUANDO un usuario se registre individualmente ENTONCES el sistema DEBERÁ mostrar opción adicional: "¿Desea formar parte de una organización existente?"
5. SI el usuario selecciona formar parte de una organización ENTONCES el sistema DEBERÁ permitir buscar y solicitar membresía a organizaciones registradas
6. CUANDO un usuario elija "Registrar Nueva Organización" ENTONCES el sistema DEBERÁ mostrar formularios para: datos de la entidad jurídica, carga de documentación legal, estados financieros, identificación de beneficiarios finales, actividades económicas, y designar al representante legal inicial
7. CUANDO un Administrador de Usuarios reciba una solicitud ENTONCES el sistema DEBERÁ mostrar interfaz para aprobar/rechazar y asignar roles específicos al nuevo miembro

**Backend (API/Services):** 7. CUANDO se registre una organización ENTONCES el sistema DEBERÁ crear automáticamente los roles: Representante Legal y Administrador de Usuarios 8. CUANDO se complete el registro de organización ENTONCES el sistema DEBERÁ asignar al registrante inicial ambos roles (Representante Legal y Administrador de Usuarios) 9. CUANDO un usuario solicite unirse a una organización ENTONCES el sistema DEBERÁ notificar al Administrador de Usuarios de esa organización 11. SI una solicitud de membresía es rechazada ENTONCES el sistema DEBERÁ mantener al usuario registrado como individual sin afiliación organizacional 12. CUANDO se asignen roles ENTONCES el sistema DEBERÁ aplicar permisos específicos según la matriz de control de acceso definida

### Requerimiento 2: Gestión de Organizaciones y Roles

**Historia de Usuario:** Como representante legal o administrador de una organización, quiero gestionar los miembros de mi entidad y sus roles, para mantener control sobre quién representa a la organización y qué permisos tienen.

#### Criterios de Aceptación

**Frontend (Flutter App):** 3. CUANDO un Representante Legal acceda al sistema ENTONCES el sistema DEBERÁ mostrar interfaces para: gestionar todos los miembros, asignar/revocar el rol de Administrador de Usuarios, y aprobar decisiones críticas de la organización 4. CUANDO un Administrador Gubernamental acceda al sistema ENTONCES el sistema DEBERÁ mostrar dashboards para: supervisar toda la actividad en su jurisdicción, mediar conflictos, generar reportes oficiales, y gestionar denuncias ciudadanas 5. CUANDO un Administrador de Usuarios acceda al sistema ENTONCES el sistema DEBERÁ mostrar interfaces para: aprobar/rechazar solicitudes de membresía, asignar roles operativos (Sentinela, Rescatista, Donante, Veterinario), y gestionar permisos de miembros 7. CUANDO se apruebe una membresía ENTONCES el sistema DEBERÁ mostrar selector de roles específicos para el nuevo miembro 8. CUANDO un miembro organizacional actúe en la plataforma ENTONCES el sistema DEBERÁ mostrar claramente que actúa en representación de la organización 10. SI un Representante Legal quiere transferir su rol ENTONCES el sistema DEBERÁ mostrar formularios de verificación adicional y carga de documentación legal

**Backend (API/Services):**

1. CUANDO una organización sea creada ENTONCES el sistema DEBERÁ establecer la siguiente jerarquía de roles: Representante Legal (máximo nivel), Administrador de Usuarios, Sentinela Organizacional, Rescatista Organizacional, Donante Organizacional, Veterinario Organizacional
2. CUANDO un gobierno local contrate el servicio ENTONCES el sistema DEBERÁ crear roles gubernamentales: Administrador Gubernamental (máximo nivel jurisdiccional), Supervisor de Rescate Animal, y Mediador de Conflictos
3. CUANDO llegue una solicitud de membresía ENTONCES el sistema DEBERÁ notificar a todos los Administradores de Usuarios de la organización
4. CUANDO se presente una denuncia formal ENTONCES el sistema DEBERÁ escalar automáticamente al Administrador Gubernamental de la jurisdicción correspondiente
5. CUANDO un miembro sea removido de la organización ENTONCES el sistema DEBERÁ mantener su cuenta individual pero revocar todos los permisos organizacionales

### Requerimiento 3: Sistema de Denuncias Anónimas

**Historia de Usuario:** Como ciudadano (persona física) que presencia maltrato animal, quiero poder reportar el incidente de forma anónima sin necesidad de registrarme, para que las autoridades competentes puedan intervenir sin temor a represalias de mi parte.

#### Criterios de Aceptación

**Frontend (Flutter App):**

1. CUANDO un ciudadano (persona física) acceda a la aplicación ENTONCES el sistema DEBERÁ permitir acceso directo a la función de denuncia sin registro previo
2. CUANDO un denunciante complete una denuncia ENTONCES el sistema DEBERÁ capturar ubicación GPS, mostrar formulario para descripción del incidente, permitir captura de evidencia fotográfica opcional y selección de tipo de maltrato
3. CUANDO una denuncia sea procesada ENTONCES el sistema DEBERÁ permitir consultar el estado usando únicamente el código de seguimiento

**Backend (API/Services):** 3. CUANDO se envíe una denuncia anónima ENTONCES el sistema DEBERÁ generar un código de seguimiento único para consultas posteriores 5. SI un denunciante proporciona evidencia fotográfica ENTONCES el sistema DEBERÁ comprimir y almacenar las imágenes de forma segura sin vincularlas a identidad personal

### Requerimiento 4: Gestión de Sentinelas

**Historia de Usuario:** Como usuario individual o miembro de una organización apasionado por el rescate animal que busca casos activamente pero no tengo casa cuna, quiero tener el rol de sentinela para poder enviar solicitudes de rescate a rescatistas cercanos, para que los animales en situación de riesgo reciban ayuda oportuna.

#### Criterios de Aceptación

**Frontend (Flutter App):** 2. CUANDO un sentinela identifique un animal en riesgo ENTONCES el sistema DEBERÁ mostrar formulario para crear una solicitud de rescate con captura de ubicación, descripción, captura de fotos del animal y selección de nivel de urgencia 3. CUANDO un sentinela esté en proceso de rescate ENTONCES el sistema DEBERÁ permitir tomar fotografías adicionales del animal para documentar su estado y progreso 5. CUANDO un rescatista acepte una solicitud ENTONCES el sistema DEBERÁ mostrar actualización de estado y abrir canal de chat directo con el sentinela 6. CUANDO se establezca comunicación entre sentinela y rescatista ENTONCES el sistema DEBERÁ permitir interfaz de chat para intercambio de mensajes, fotos y ubicación en tiempo real

**Backend (API/Services):**

1. CUANDO un usuario solicite el rol de sentinela ENTONCES el sistema DEBERÁ validar que tenga registro completo con documentación, aceptación de términos, ubicación y motivación para validar su compromiso
2. CUANDO se cree una solicitud de rescate ENTONCES el sistema DEBERÁ calcular rescatistas en un radio de 10km, priorizar por reputación, y enviar notificaciones automáticamente
3. SI no hay respuesta en 2 horas ENTONCES el sistema DEBERÁ expandir el radio de búsqueda a 25km

### Requerimiento 5: Red de Rescatistas

**Historia de Usuario:** Como usuario individual o miembro de una organización con casa cuna establecida, quiero tener el rol de rescatista para recibir notificaciones de solicitudes de rescate en mi área y gestionar mis operaciones, para poder coordinar eficientemente los rescates y el cuidado de animales.

#### Criterios de Aceptación

**Frontend (Flutter App):** 2. CUANDO haya una solicitud de rescate en su área ENTONCES el sistema DEBERÁ mostrar notificación push inmediata 3. CUANDO un rescatista acepte una solicitud ENTONCES el sistema DEBERÁ mostrar información de contacto del sentinela y navegación GPS 4. CUANDO un rescate sea completado ENTONCES el sistema DEBERÁ permitir actualizar el estado del animal rescatado mediante formularios 5. SI un rescatista no puede atender una solicitud ENTONCES el sistema DEBERÁ permitir declinar mediante interfaz apropiada

**Backend (API/Services):**

1. CUANDO un usuario solicite el rol de rescatista ENTONCES el sistema DEBERÁ verificar documentación completa, credenciales, capacidad de casa cuna, ubicación y experiencia en rescate animal
2. SI un rescatista no puede atender una solicitud ENTONCES el sistema DEBERÁ redirigir automáticamente a otros rescatistas

### Requerimiento 6: Gestión Financiera y Contable de Rescatistas

**Historia de Usuario:** Como rescatista individual u organizacional, quiero registrar todos los gastos e ingresos relacionados con el cuidado animal y generar informes de rendición de cuentas, para mantener transparencia financiera y facilitar la gestión contable de mi operación de rescate.

#### Criterios de Aceptación

**Frontend (Flutter App):**

1. CUANDO un rescatista ingrese un animal a su casa cuna ENTONCES el sistema DEBERÁ mostrar formularios para registrar gastos asociados: alimentación, atención veterinaria, medicamentos, alojamiento y otros insumos
2. CUANDO un rescatista reciba donaciones ENTONCES el sistema DEBERÁ mostrar formularios para registrar: tipo de donación (dinero/insumos), monto o descripción, fecha, y donante (si no es anónimo)
3. CUANDO un rescatista gaste dinero propio ENTONCES el sistema DEBERÁ permitir categorizar y registrar estos gastos con captura de comprobantes fotográficos opcionales
4. CUANDO un rescatista solicite un informe ENTONCES el sistema DEBERÁ mostrar configurador de reportes por período: semanal, mensual, trimestral o anual
5. SI un rescatista quiere exportar datos ENTONCES el sistema DEBERÁ permitir descarga en formatos PDF y Excel para uso contable externo

**Backend (API/Services):** 5. CUANDO se genere un informe individual ENTONCES el sistema DEBERÁ procesar y incluir: número de animales rescatados, gastos por categoría, donaciones recibidas, gastos propios, y balance general 6. CUANDO una organización solicite un informe consolidado ENTONCES el sistema DEBERÁ generar un reporte anonimizado que combine datos de todos sus rescatistas miembros 7. CUANDO se genere un informe organizacional ENTONCES el sistema DEBERÁ procesar y presentar datos como estado contable: ingresos totales, gastos por categoría, balance, y métricas de impacto

### Requerimiento 7: Gestión de Casas Cuna

**Historia de Usuario:** Como rescatista con casa cuna, quiero gestionar el inventario de animales bajo mi cuidado y su disponibilidad para adopción, para mantener un registro actualizado y facilitar las adopciones.

#### Criterios de Aceptación

**Frontend (Flutter App):**

1. CUANDO un animal ingrese a una casa cuna ENTONCES el sistema DEBERÁ mostrar formularios para registrar datos médicos, captura de fotos, comportamiento y necesidades especiales
2. CUANDO un animal esté listo para adopción ENTONCES el sistema DEBERÁ permitir marcarlo como disponible con formulario de perfil completo
3. CUANDO se actualice el estado de un animal ENTONCES el sistema DEBERÁ mostrar formularios de actualización y visualizar historial médico y de cuidados
4. SI un animal requiere atención veterinaria urgente ENTONCES el sistema DEBERÁ permitir marcar la prioridad, mostrar veterinarios colaboradores cercanos, y enviar solicitud de atención con datos del animal
5. CUANDO una casa cuna reciba donaciones ENTONCES el sistema DEBERÁ mostrar formularios para registrar en inventario y sistema financiero simultáneamente
6. CUANDO una casa cuna necesite insumos específicos ENTONCES el sistema DEBERÁ permitir publicar lista de necesidades con estimación de costos para donantes

**Backend (API/Services):** 4. CUANDO una casa cuna alcance su capacidad máxima ENTONCES el sistema DEBERÁ actualizar automáticamente su disponibilidad 8. CUANDO se utilicen insumos del inventario ENTONCES el sistema DEBERÁ actualizar automáticamente los registros financieros con el costo asociado

### Requerimiento 8: Red de Veterinarios Colaboradores

**Historia de Usuario:** Como veterinario individual o clínica veterinaria especializada en rescate animal, quiero registrarme en el sistema para recibir solicitudes de atención médica de rescatistas y ofrecer servicios con tarifas preferenciales, para contribuir al bienestar animal y formar parte de la red de rescate.

#### Criterios de Aceptación

**Frontend (Flutter App):**

1. CUANDO un veterinario se registre individualmente ENTONCES el sistema DEBERÁ mostrar formularios para: datos personales, número de colegiado, especialidades, ubicación de consulta, tarifas preferenciales para rescate, y horarios de atención
2. CUANDO una clínica veterinaria se registre como organización ENTONCES el sistema DEBERÁ mostrar formularios para: datos de la entidad, carga de licencias sanitarias, veterinarios miembros con sus credenciales, servicios ofrecidos, y políticas de atención para rescate animal
3. CUANDO un rescatista necesite atención veterinaria urgente ENTONCES el sistema DEBERÁ mostrar veterinarios colaboradores cercanos con disponibilidad, especialidades requeridas, y puntuación de reputación
4. CUANDO un veterinario reciba una solicitud de atención ENTONCES el sistema DEBERÁ mostrar interfaz para aceptar/declinar con justificación y proporcionar información de contacto directo
5. CUANDO se complete una atención veterinaria ENTONCES el sistema DEBERÁ mostrar formularios para que el veterinario registre: diagnóstico, tratamiento aplicado, medicamentos recetados, costo del servicio, y seguimiento requerido
6. CUANDO un veterinario organizacional atienda un caso ENTONCES el sistema DEBERÁ mostrar claramente que actúa en representación de la clínica
7. SI un animal requiere atención especializada ENTONCES el sistema DEBERÁ mostrar opciones de derivación entre veterinarios colaboradores

**Backend (API/Services):** 6. CUANDO un veterinario organizacional atienda un caso ENTONCES el sistema DEBERÁ registrar los datos en el sistema financiero organizacional 7. SI un animal requiere atención especializada ENTONCES el sistema DEBERÁ enviar notificación automática al veterinario derivado 8. CUANDO se generen reportes veterinarios ENTONCES el sistema DEBERÁ procesar y incluir estadísticas de casos atendidos, tipos de tratamientos, y impacto en la red de rescate

### Requerimiento 9: Sistema de Donaciones y Patrocinios

**Historia de Usuario:** Como persona física o jurídica interesada en apoyar el rescate animal, quiero poder donar insumos o dinero a casas cuna específicas o múltiples, mediante suscripciones o crowdfunding, para contribuir de manera sostenible al bienestar animal.

#### Criterios de Aceptación

**Frontend (Flutter App):**

1. CUANDO un donante se registre ENTONCES el sistema DEBERÁ mostrar selector de tipo de donación: insumos, dinero, o ambos
2. CUANDO un donante elija donar dinero ENTONCES el sistema DEBERÁ mostrar opciones: transferencia bancaria, SINPE móvil, tarjeta de crédito/débito, suscripción mensual o donación única
3. CUANDO un donante configure una suscripción ENTONCES el sistema DEBERÁ mostrar selector de casa cuna específica o distribución entre múltiples casas cuna, mostrando reputación de cada rescatista
4. CUANDO se active un crowdfunding ENTONCES el sistema DEBERÁ mostrar meta, progreso actual, casas cuna beneficiarias y transparencia en el uso de fondos
5. CUANDO una casa cuna reciba donación ENTONCES el sistema DEBERÁ mostrar interfaz para confirmar recepción y enviar agradecimiento al donante
6. SI un donante quiere donar insumos ENTONCES el sistema DEBERÁ mostrar lista de necesidades actuales de las casas cuna cercanas

**Backend (API/Services):** 2. CUANDO un donante elija donar dinero ENTONCES el sistema DEBERÁ aplicar controles de KYC según el monto y estándares PCI DSS para datos de tarjetas 5. CUANDO un donante realice una donación ENTONCES el sistema DEBERÁ generar comprobante digital, registrar en el sistema financiero del rescatista, aplicar controles de debida diligencia según el monto, y notificar a las casas cuna beneficiarias 6. CUANDO una casa cuna reciba donación ENTONCES el sistema DEBERÁ actualizar registros financieros automáticamente

### Requerimiento 10: Sistema de Geolocalización

**Historia de Usuario:** Como usuario de la aplicación, quiero que el sistema utilice mi ubicación para conectarme con rescatistas y casos cercanos, para optimizar los tiempos de respuesta y la eficiencia del rescate.

#### Criterios de Aceptación

**Frontend (Flutter App):**

1. CUANDO un usuario permita acceso a ubicación ENTONCES el sistema DEBERÁ solicitar permisos de GPS de forma clara
2. CUANDO se reporte un incidente ENTONCES el sistema DEBERÁ capturar coordenadas GPS precisas automáticamente
3. CUANDO un usuario esté offline ENTONCES el sistema DEBERÁ almacenar ubicaciones localmente hasta recuperar conectividad
4. SI la ubicación GPS no está disponible ENTONCES el sistema DEBERÁ permitir selección manual en mapa

**Backend (API/Services):** 3. CUANDO se busquen rescatistas ENTONCES el sistema DEBERÁ calcular distancias y priorizar por proximidad

### Requerimiento 11: Sistema de Chat Interno

**Historia de Usuario:** Como sentinela, rescatista o veterinario, quiero poder comunicarme directamente con otros usuarios involucrados en un caso a través de un chat interno, para coordinar eficientemente los rescates, tratamientos y compartir información en tiempo real.

#### Criterios de Aceptación

**Frontend (Flutter App):** 3. CUANDO un usuario envíe un mensaje ENTONCES el sistema DEBERÁ mostrar el mensaje instantáneamente con confirmación de lectura 4. CUANDO un usuario comparta una foto en el chat ENTONCES el sistema DEBERÁ permitir visualización inmediata y descarga opcional 5. CUANDO se comparta ubicación en el chat ENTONCES el sistema DEBERÁ mostrar la posición en mapa integrado 6. CUANDO un veterinario comparta información médica ENTONCES el sistema DEBERÁ permitir adjuntar diagnósticos, recetas y recomendaciones de tratamiento 8. SI la conectividad es intermitente ENTONCES el sistema DEBERÁ almacenar mensajes localmente y sincronizar al recuperar conexión

**Backend (API/Services):**

1. CUANDO un rescatista acepte una solicitud ENTONCES el sistema DEBERÁ crear automáticamente un chat privado entre sentinela y rescatista
2. CUANDO un veterinario acepte atender un caso ENTONCES el sistema DEBERÁ crear un chat entre rescatista y veterinario, y opcionalmente incluir al sentinela si es relevante
3. CUANDO un usuario envíe un mensaje ENTONCES el sistema DEBERÁ entregar el mensaje instantáneamente a través de WebSockets o similar
4. CUANDO un caso se complete ENTONCES el sistema DEBERÁ archivar todos los chats relacionados manteniendo el historial para referencia futura

### Requerimiento 12: Sistema de Notificaciones

**Historia de Usuario:** Como usuario activo de la plataforma, quiero recibir notificaciones relevantes sobre casos, solicitudes y actualizaciones, para mantenerme informado y poder responder oportunamente.

#### Criterios de Aceptación

**Frontend (Flutter App):** 2. CUANDO llegue un mensaje de chat ENTONCES el sistema DEBERÁ mostrar notificación con vista previa del mensaje 3. CUANDO un usuario configure sus preferencias ENTONCES el sistema DEBERÁ mostrar configurador de tipos de notificación 4. CUANDO una notificación sea crítica ENTONCES el sistema DEBERÁ usar sonido y vibración distintivos 6. CUANDO un usuario reciba una nueva calificación ENTONCES el sistema DEBERÁ mostrar notificación con resumen de la calificación recibida 7. SI las notificaciones push fallan ENTONCES el sistema DEBERÁ mantener un centro de notificaciones interno

**Backend (API/Services):**

1. CUANDO ocurra un evento relevante ENTONCES el sistema DEBERÁ enviar notificación push personalizada según el tipo de usuario
2. CUANDO un usuario configure sus preferencias ENTONCES el sistema DEBERÁ almacenar y respetar los tipos de notificación seleccionados
3. CUANDO un usuario esté inactivo por más de 24 horas ENTONCES el sistema DEBERÁ enviar recordatorio de casos pendientes

### Requerimiento 13: Cumplimiento Regulatorio, KYC y PCI DSS

**Historia de Usuario:** Como plataforma que intermedia fondos y procesa pagos con tarjetas, necesito cumplir con las regulaciones de SUGEF, obligaciones de KYC y estándares PCI DSS para operar legalmente, prevenir lavado de dinero y proteger los datos financieros sensibles, para mantener la confianza y legalidad del sistema de donaciones.

#### Criterios de Aceptación

**Frontend (Flutter App):**

1. CUANDO un donante se registre para donaciones monetarias ENTONCES el sistema DEBERÁ mostrar formularios para: ocupación, fuente de ingresos, propósito de la donación, y declaración de origen lícito de fondos
2. CUANDO un donante realice donaciones superiores a $1000 USD (o equivalente) ENTONCES el sistema DEBERÁ mostrar formularios para documentación adicional: carga de comprobantes de ingresos, declaración patrimonial, y justificación de la donación
3. CUANDO una organización se registre como donante ENTONCES el sistema DEBERÁ mostrar formularios para: carga de estados financieros, certificación de personería jurídica vigente, identificación de beneficiarios finales, y declaración de actividades económicas
4. SI se requiere verificación adicional ENTONCES el sistema DEBERÁ mostrar formularios para solicitar: referencias bancarias, certificaciones de contador público, y validación de actividad económica
5. CUANDO se transmitan datos sensibles de KYC ENTONCES la aplicación móvil DEBERÁ transmitir estos datos de forma segura con encriptación punto a punto

**Backend (API/Services):** 4. CUANDO se detecten patrones de donación inusuales ENTONCES el sistema DEBERÁ generar alertas automáticas mediante algoritmos de machine learning para revisión manual y posible reporte a autoridades 5. CUANDO un rescatista reciba donaciones ENTONCES el sistema DEBERÁ mantener registros detallados de: origen de fondos, fecha, monto, propósito específico, y uso final de los recursos 6. CUANDO se procesen transferencias internacionales ENTONCES el sistema DEBERÁ aplicar controles adicionales de debida diligencia y reportes regulatorios correspondientes 7. CUANDO un usuario sea identificado en listas de sanciones ENTONCES el sistema DEBERÁ bloquear automáticamente las transacciones y notificar a las autoridades competentes 8. CUANDO se generen reportes financieros ENTONCES el sistema DEBERÁ incluir información requerida para auditorías regulatorias y reportes de operaciones sospechosas 10. CUANDO se almacenen datos sensibles de KYC ENTONCES el sistema DEBERÁ aplicar encriptación de nivel bancario y controles de acceso estrictos 11. CUANDO se procesen pagos con tarjeta ENTONCES el sistema DEBERÁ cumplir con todos los requisitos del estándar PCI DSS nivel 1, incluyendo:
a. No almacenar datos sensibles de tarjetas (PAN completo, CVV, PIN)
b. Utilizar tokenización para referencias de pago recurrentes
c. Implementar encriptación punto a punto para transmisión de datos
d. Realizar escaneos trimestrales de vulnerabilidades y pruebas de penetración anuales
e. Mantener firewalls de aplicación web y sistemas de detección de intrusiones 12. CUANDO se integre con pasarelas de pago ENTONCES el sistema DEBERÁ utilizar proveedores certificados PCI DSS que asuman la responsabilidad de almacenamiento de datos de tarjetas 13. CUANDO se requiera almacenar información para pagos recurrentes ENTONCES el sistema DEBERÁ utilizar únicamente tokens de pago proporcionados por el procesador certificado 14. CUANDO se realicen auditorías de seguridad ENTONCES el sistema DEBERÁ demostrar cumplimiento con los 12 requisitos principales del estándar PCI DSS

### Requerimiento 14: Seguridad y Privacidad

**Historia de Usuario:** Como usuario preocupado por mi privacidad, quiero que mis datos personales estén protegidos y que pueda controlar qué información comparto, para sentirme seguro usando la aplicación.

#### Criterios de Aceptación

**Frontend (Flutter App):** 3. CUANDO se compartan datos entre usuarios ENTONCES el sistema DEBERÁ mostrar solo información necesaria para la operación 4. CUANDO un usuario solicite eliminar su cuenta ENTONCES el sistema DEBERÁ mostrar confirmación y opciones de eliminación

**Backend (API/Services):**

1. CUANDO un usuario se registre ENTONCES el sistema DEBERÁ encriptar todos los datos personales sensibles
2. CUANDO se procesen denuncias anónimas ENTONCES el sistema DEBERÁ garantizar que no se almacene información identificable
3. CUANDO un usuario solicite eliminar su cuenta ENTONCES el sistema DEBERÁ anonimizar todos sus reportes históricos
4. CUANDO se almacenen datos jurisdiccionales ENTONCES el sistema DEBERÁ garantizar segregación completa entre diferentes gobiernos locales, mientras que los datos globales serán accesibles por todos los gobiernos según permisos
5. SI se detecta actividad sospechosa ENTONCES el sistema DEBERÁ bloquear temporalmente la cuenta y notificar tanto al administrador de la plataforma como al Administrador Gubernamental correspondiente

### Requerimiento 15: Arquitectura del Sistema

**Historia de Usuario:** Como usuario de la aplicación móvil, quiero que el sistema funcione de manera eficiente y segura mediante una arquitectura bien definida entre frontend móvil y backend, para tener una experiencia fluida mientras se mantiene la seguridad y cumplimiento regulatorio.

#### Criterios de Aceptación

**Frontend (Flutter App):**

1. CUANDO un usuario interactúe con la aplicación móvil ENTONCES el frontend DEBERÁ manejar: interfaz de usuario, captura de datos, validaciones básicas, y comunicación con el backend
2. CUANDO se procesen pagos ENTONCES el frontend solo DEBERÁ mostrar interfaces de usuario sin procesar directamente datos sensibles de tarjetas
3. CUANDO se generen reportes financieros ENTONCES el frontend DEBERÁ permitir configurar parámetros y descargar resultados
4. CUANDO se sincronicen datos ENTONCES la aplicación móvil DEBERÁ funcionar offline para funciones básicas y sincronizar automáticamente cuando haya conectividad
5. CUANDO se envíen notificaciones ENTONCES el frontend DEBERÁ mostrarlas apropiadamente
6. SI hay problemas de conectividad ENTONCES la aplicación móvil DEBERÁ almacenar datos localmente y sincronizar cuando se restablezca la conexión

**Backend (API/Services):** 2. CUANDO se procesen datos sensibles o transacciones ENTONCES el backend DEBERÁ manejar: lógica de negocio, validaciones complejas, almacenamiento seguro, y cumplimiento regulatorio 3. CUANDO se requiera análisis de patrones ENTONCES el backend DEBERÁ ejecutar algoritmos de machine learning para detección de anomalías en donaciones y comportamientos sospechosos 4. CUANDO se procesen pagos ENTONCES el backend DEBERÁ integrar con pasarelas de pago certificadas PCI DSS y sistemas bancarios 5. CUANDO se generen reportes financieros ENTONCES el backend DEBERÁ procesar los datos y generar documentos 7. CUANDO se envíen notificaciones ENTONCES el backend DEBERÁ gestionar la lógica de notificaciones push

### Requerimiento 16: Sistema de Reputación y Calificaciones

**Historia de Usuario:** Como usuario de la plataforma, quiero poder calificar y comentar sobre la calidad del servicio de otros usuarios, y ver sus reputaciones, para tomar decisiones informadas y mantener altos estándares de calidad en la red de rescate animal.

#### Criterios de Aceptación

**Frontend (Flutter App):**

1. CUANDO se complete una interacción entre usuarios ENTONCES el sistema DEBERÁ mostrar interfaz para calificación mutua con escala de 1 a 5 estrellas y comentario opcional
2. CUANDO un sentinela complete un rescate con un rescatista ENTONCES ambos DEBERÁN poder acceder a formularios de calificación de la experiencia: puntualidad, comunicación, profesionalismo y efectividad
3. CUANDO un rescatista reciba atención veterinaria ENTONCES DEBERÁ poder acceder a formulario para calificar al veterinario: calidad de atención, diagnóstico acertado, trato al animal y costo-beneficio
4. CUANDO un veterinario atienda un caso ENTONCES DEBERÁ poder acceder a formulario para calificar al rescatista: preparación del caso, seguimiento de instrucciones y cuidado del animal
5. CUANDO un donante contribuya a una casa cuna ENTONCES DEBERÁ poder acceder a formulario para calificar la transparencia, comunicación y uso efectivo de la donación
6. CUANDO se muestre el perfil de un usuario ENTONCES el sistema DEBERÁ mostrar: puntuación promedio actual, número de calificaciones vigentes, y comentarios recientes (últimos 10)
7. CUANDO un usuario tenga reputación muy baja (menos de 2 estrellas) ENTONCES el sistema DEBERÁ mostrar advertencia a otros usuarios
8. SI un usuario recibe múltiples reportes por calificaciones falsas ENTONCES el sistema DEBERÁ mostrar opciones de reporte e investigación

**Backend (API/Services):** 6. CUANDO se registre una calificación ENTONCES el sistema DEBERÁ establecer fecha de expiración de 3 meses desde la fecha de creación 7. CUANDO una calificación expire ENTONCES el sistema DEBERÁ removerla automáticamente del cálculo de reputación pero mantener el historial para auditoría 8. CUANDO se calcule la reputación de un usuario ENTONCES el sistema DEBERÁ considerar solo calificaciones vigentes (no expiradas) y mostrar promedio ponderado 10. SI se detecta patrón de calificaciones sospechosas ENTONCES el sistema DEBERÁ generar alerta para revisión manual y posible suspensión temporal de calificaciones 11. CUANDO un usuario tenga reputación muy baja (menos de 2 estrellas) ENTONCES el sistema DEBERÁ limitar su visibilidad en búsquedas 12. SI un usuario recibe múltiples reportes por calificaciones falsas ENTONCES el sistema DEBERÁ procesar investigación y posible penalización de su capacidad de calificar

### Requerimiento 17: Administración Gubernamental y Modelo SaaS

**Historia de Usuario:** Como gobierno local (municipalidad), quiero contratar un servicio SaaS para gestionar la red de rescate animal en mi jurisdicción, con capacidades de supervisión, mediación de conflictos y transparencia, para mejorar el bienestar animal y la confianza ciudadana en mi administración.

#### Criterios de Aceptación

**Frontend (Flutter App):** 2. CUANDO se configure una nueva jurisdicción ENTONCES el sistema DEBERÁ mostrar personalización: logo gubernamental, colores institucionales, información de contacto, y políticas locales específicas 3. CUANDO un administrador gubernamental acceda al sistema ENTONCES DEBERÁ tener acceso a: dashboard de métricas, gestión de usuarios, mediación de conflictos, y reportes de transparencia 6. CUANDO un administrador gubernamental necesite mediar un conflicto ENTONCES el sistema DEBERÁ mostrar: historial completo de interacciones, evidencias, calificaciones, y herramientas de comunicación oficial 7. CUANDO se generen reportes gubernamentales ENTONCES el sistema DEBERÁ mostrar: estadísticas de rescates, uso de fondos públicos, efectividad de la red, y métricas de satisfacción ciudadana 8. CUANDO un ciudadano quiera presentar una queja formal ENTONCES el sistema DEBERÁ mostrar formulario de denuncia 9. SI se requiere auditoría externa ENTONCES el sistema DEBERÁ permitir exportación completa de datos en formatos estándar para revisión gubernamental

**Backend (API/Services):**

1. CUANDO un gobierno local contrate el servicio ENTONCES el sistema DEBERÁ implementar un modelo híbrido donde:
   a. Los datos jurisdiccionales (denuncias locales, mediación de conflictos, reportes territoriales) sean multi-tenant con segregación por gobierno local
   b. Los datos globales (usuarios, red de rescate, veterinarios, donaciones) sean singleton compartidos en todo el sistema
2. CUANDO llegue una denuncia contra un rescatista o sentinela ENTONCES el sistema DEBERÁ notificar automáticamente al administrador gubernamental para investigación
3. CUANDO se reporte malversación de fondos ENTONCES el sistema DEBERÁ generar expediente con toda la documentación financiera relevante y notificar a las autoridades competentes
4. CUANDO un ciudadano quiera presentar una queja formal ENTONCES el sistema DEBERÁ canalizar la denuncia al gobierno local correspondiente según geolocalización
5. CUANDO se detecten actividades sospechosas ENTONCES el sistema DEBERÁ generar alertas automáticas para el administrador gubernamental con recomendaciones de acción
6. SI un gobierno local quiere implementación on-premises ENTONCES el sistema DEBERÁ ofrecer esta opción como servicio premium con esquema de precios diferenciado
7. CUANDO se facture el servicio ENTONCES el sistema DEBERÁ calcular costos basados en: número de usuarios activos, volumen de transacciones, y servicios adicionales contratados

### Requerimiento 18: Integración con Pasarela de Pagos ONVOPay

**Historia de Usuario:** Como desarrollador del sistema, quiero implementar una integración segura y eficiente con la pasarela de pagos ONVOPay, para procesar donaciones con tarjetas de crédito/débito cumpliendo con estándares PCI DSS.

#### Criterios de Aceptación

**Frontend (Flutter App):** 2. CUANDO un donante inicie un proceso de pago ENTONCES la aplicación móvil Flutter DEBERÁ:
a. Mostrar formulario para recolectar información mínima necesaria (monto, concepto, frecuencia)
b. Invocar un WebView seguro que cargue el formulario de pago de ONVOPay
c. No almacenar ni procesar directamente datos de tarjetas en el código de la aplicación 3. CUANDO ONVOPay procese el pago ENTONCES el sistema DEBERÁ:
d. Mostrar notificación al usuario sobre el resultado de la transacción 5. CUANDO se requiera una suscripción recurrente ENTONCES el sistema DEBERÁ:
d. Permitir al usuario cancelar la suscripción en cualquier momento mediante interfaz apropiada 7. SI ONVOPay no está disponible ENTONCES el sistema DEBERÁ mostrar mecanismo de fallback a métodos alternativos como transferencia bancaria o SINPE móvil

**Backend (API/Services):**

1. CUANDO se implemente la integración de pagos ENTONCES el sistema DEBERÁ utilizar un patrón de diseño de adaptador que permita cambiar de proveedor de pasarela si fuera necesario
2. CUANDO ONVOPay procese el pago ENTONCES el sistema DEBERÁ:
   a. Recibir notificación de éxito/fracaso vía webhook en el backend
   b. Obtener un token de referencia para pagos recurrentes si aplica
   c. Actualizar el estado de la donación en la base de datos
3. CUANDO se configure la integración ENTONCES el sistema DEBERÁ implementar:
   a. Autenticación mediante API keys almacenadas de forma segura en variables de entorno del backend
   b. Verificación de firmas digitales en todas las comunicaciones con ONVOPay
   c. Manejo de errores y reintentos para transacciones fallidas
   d. Registro detallado de todas las operaciones para auditoría
4. CUANDO se requiera una suscripción recurrente ENTONCES el sistema DEBERÁ:
   a. Utilizar el servicio de tokenización de ONVOPay
   b. Almacenar únicamente el token de referencia, nunca datos de tarjetas
   c. Programar cobros automáticos según la frecuencia seleccionada
5. CUANDO se realicen pruebas ENTONCES el sistema DEBERÁ conectarse al ambiente sandbox de ONVOPay antes de pasar a producción
6. CUANDO se actualice la API de ONVOPay ENTONCES el sistema DEBERÁ estar diseñado para adaptarse con cambios mínimos gracias al patrón adaptador

### Requerimiento 19: Interfaz de Usuario Intuitiva

**Historia de Usuario:** Como usuario de diferentes niveles técnicos, quiero una interfaz simple e intuitiva que me permita usar todas las funciones fácilmente, para poder enfocarme en ayudar a los animales sin complicaciones técnicas.

#### Criterios de Aceptación

**Frontend (Flutter App):**

1. CUANDO un usuario abra la aplicación ENTONCES el sistema DEBERÁ mostrar un dashboard claro con acciones principales
2. CUANDO un usuario navegue entre secciones ENTONCES el sistema DEBERÁ mantener consistencia visual y de navegación
3. CUANDO un usuario complete un formulario ENTONCES el sistema DEBERÁ validar datos en tiempo real con mensajes claros
4. CUANDO ocurra un error ENTONCES el sistema DEBERÁ mostrar mensajes comprensibles con sugerencias de solución
5. SI un usuario es nuevo ENTONCES el sistema DEBERÁ ofrecer un tutorial interactivo opcional

**Backend (API/Services):** 3. CUANDO un usuario complete un formulario ENTONCES el sistema DEBERÁ procesar validaciones complejas del lado del servidor

---

## Resumen de Responsabilidades para Monorepo

### Frontend (Flutter App) - `/mobile`

**Responsabilidades principales:**

- Interfaz de usuario y experiencia del usuario (UI/UX)
- Captura y validación básica de datos de formularios
- Gestión de estado local y caché offline
- Comunicación con APIs del backend
- Manejo de notificaciones push (mostrar)
- Geolocalización y integración con mapas
- Captura de fotos y multimedia
- Navegación y flujos de usuario
- Configuración de preferencias de usuario
- WebViews para pagos seguros
- Chat en tiempo real (interfaz)

**Tecnologías sugeridas:**

- Flutter/Dart
- Provider/Riverpod para gestión de estado
- Hive/SQLite para almacenamiento local
- HTTP/Dio para comunicación con APIs
- Firebase Messaging para notificaciones
- Google Maps/MapBox para mapas
- WebSocket para chat en tiempo real

### Backend (API/Services) - `/backend`

**Responsabilidades principales:**

- Lógica de negocio compleja
- Autenticación y autorización (RBAC)
- Procesamiento de pagos y cumplimiento PCI DSS
- Algoritmos de machine learning y detección de anomalías
- Gestión de base de datos y persistencia
- Integración con servicios externos (ONVOPay, etc.)
- Cumplimiento regulatorio y KYC
- Generación de reportes y análisis
- Gestión de notificaciones push (envío)
- Procesamiento de imágenes y archivos
- Chat en tiempo real (lógica y persistencia)
- Cálculos geoespaciales y búsquedas por proximidad
- Gestión de roles y permisos
- Auditoría y logging
- Multi-tenancy para gobiernos locales

**Tecnologías sugeridas:**

- Node.js/Express o Python/FastAPI o .NET Core
- PostgreSQL/MongoDB para base de datos principal
- Redis para caché y sesiones
- JWT para autenticación
- WebSockets/Socket.io para chat en tiempo real
- Firebase Admin SDK para notificaciones push
- Stripe/ONVOPay SDK para pagos
- AWS S3/CloudFlare para almacenamiento de archivos
- Docker para containerización
- Kubernetes para orquestación

### Estructura de Monorepo Sugerida:

```
centinelasalrescate/
├── mobile/                 # Aplicación Flutter
│   ├── lib/
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
├── backend/               # API y servicios
│   ├── src/
│   ├── config/
│   ├── tests/
│   └── package.json
├── shared/                # Código compartido
│   ├── models/           # Modelos de datos
│   ├── constants/        # Constantes compartidas
│   └── utils/           # Utilidades comunes
├── docs/                 # Documentación
├── scripts/              # Scripts de deployment
└── docker-compose.yml    # Para desarrollo local
```

### Comunicación entre Frontend y Backend:

- **REST APIs** para operaciones CRUD estándar
- **WebSockets** para chat en tiempo real y notificaciones
- **Webhooks** para integraciones con servicios externos
- **GraphQL** (opcional) para consultas complejas de datos
