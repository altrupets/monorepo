# Flutter Agent Skills

Este proyecto utiliza el patrón de **Agent Skills** para proporcionar conocimiento contextual y capacidades especializadas a los asistentes de IA.

## ¿Qué son los Skills?

Los skills son carpetas con archivos `SKILL.md` que contienen instrucciones y contexto específico. Ofrecen:
- Eficiencia de tokens (carga progresiva)
- Menor carga cognitiva
- Composabilidad entre skills

Basado en [Anthropic y LangChain Deep Agents](https://blog.langchain.com/using-skills-with-deep-agents/).

## Estructura de Skills

```
skills/
├── flutter/           # Skills para desarrollo Flutter
├── cicd/              # Skills para CI/CD (Terraform, ArgoCD, etc.)
├── static-analysis/   # Skills para análisis estático de código
└── figma/             # Skills para integración con Figma Dev Mode
```

## Cómo Usar los Skills

### Invocación por Keywords
```bash
"Crea una app usando mvvm para gestión de usuarios"
"Implementa clean-arch para un módulo de productos"
"Configura cicd con GitHub Actions"
```

### Invocación Explícita
```bash
@skill:flutter/mvvm - Genera una app de notas
@skill:flutter/clean-architecture - Implementa módulo de auth
```

## Skills Disponibles

### Flutter

| Skill | Keywords | Nivel | Descripción |
|-------|----------|-------|-------------|
| [MVVM](skills/flutter/mvvm/SKILL.md) | mvvm, provider | Intermedio | Patrón MVVM con separación UI/lógica |
| [Clean Architecture](skills/flutter/clean-architecture/SKILL.md) | clean-arch, bloc | Avanzado | Arquitectura en capas Domain/Data/Presentation |
| [Project Setup](skills/flutter/project-setup/SKILL.md) | setup, init | Básico | Configuración inicial estándar |
| [Testing](skills/flutter/testing/SKILL.md) | test, tdd | Avanzado | Unit, widget e integration tests |
| [BLoC Avanzado](skills/flutter/bloc-advanced/SKILL.md) | bloc, cubit | Avanzado | Hydrated BLoC, Replay BLoC |
| [Riverpod](skills/flutter/riverpod/SKILL.md) | riverpod | Intermedio | State management reactivo |
| [Feature-First](skills/flutter/feature-first/SKILL.md) | feature-first | Intermedio | Organización por features |
| [Modular](skills/flutter/modular-architecture/SKILL.md) | modular | Avanzado | Módulos independientes |
| [Code Generation](skills/flutter/code-generation/SKILL.md) | code-gen, freezed | Básico | build_runner, json_serializable |
| [Performance](skills/flutter/performance/SKILL.md) | performance | Avanzado | Profiling y optimización |
| [Accessibility](skills/flutter/accessibility/SKILL.md) | a11y, wcag | Intermedio | Semantic widgets, screen readers |
| [Animation](skills/flutter/animation-motion/SKILL.md) | animation, rive | Avanzado | Rive, Lottie, Hero |
| [Theming](skills/flutter/theming/SKILL.md) | theme, dark-mode | Intermedio | Material 3, design system |
| [i18n](skills/flutter/i18n/SKILL.md) | i18n, l10n | Intermedio | Múltiples idiomas |
| [Firebase](skills/flutter/firebase/SKILL.md) | firebase | Intermedio | Auth, Firestore, Messaging |
| [GraphQL](skills/flutter/graphql/SKILL.md) | graphql | Avanzado | Queries, mutations, subscriptions |
| [Offline-First](skills/flutter/offline-first/SKILL.md) | offline, sync | Avanzado | Cache y sincronización |
| [Deep Linking](skills/flutter/deep-linking/SKILL.md) | deep-linking | Intermedio | Universal/App links |
| [Push Notifications](skills/flutter/push-notifications/SKILL.md) | fcm, notifications | Intermedio | Firebase Cloud Messaging |
| [Analytics](skills/flutter/analytics-tracking/SKILL.md) | analytics | Intermedio | Firebase, Mixpanel, Amplitude |
| [Error Tracking](skills/flutter/error-tracking/SKILL.md) | sentry, crashlytics | Intermedio | Monitoreo de errores |
| [Feature Flags](skills/flutter/feature-flags/SKILL.md) | feature-flags | Intermedio | Remote Config, LaunchDarkly |
| [IAP](skills/flutter/in-app-purchases/SKILL.md) | iap, subscriptions | Avanzado | RevenueCat |
| [App Distribution](skills/flutter/app-distribution/SKILL.md) | testflight | Intermedio | TestFlight, Firebase Distribution |
| [Platform Channels](skills/flutter/platform-channels/SKILL.md) | methodchannel | Avanzado | Comunicación nativa |
| [Native Integration](skills/flutter/native-integration/SKILL.md) | swift, kotlin | Avanzado | iOS/Android SDKs |
| [WebView](skills/flutter/webview-integration/SKILL.md) | webview | Intermedio | flutter_inappwebview |
| [Security](skills/flutter/security/SKILL.md) | security | Avanzado | Obfuscation, pinning |

### CI/CD

| Skill | Keywords | Descripción |
|-------|----------|-------------|
| [GitHub Actions](skills/cicd/github-actions/SKILL.md) | ci, cd, pipeline | CI/CD nativo de GitHub |
| [ArgoCD](skills/cicd/argocd/SKILL.md) | gitops, kubernetes | GitOps deployment |
| [Terraform](skills/cicd/terraform/SKILL.md) | iac, hcl | Infrastructure as Code |
| [AWS](skills/cicd/aws/SKILL.md) | eks, rds, lambda | Amazon Web Services |
| [GCP](skills/cicd/gcp/SKILL.md) | gke, cloud-run | Google Cloud Platform |
| [Azure](skills/cicd/azure/SKILL.md) | aks, functions | Microsoft Azure |
| [OVHCloud](skills/cicd/ovhcloud/SKILL.md) | ovh | OVHCloud EU-based |
| [Ansible AWX](skills/cicd/ansible-awx/SKILL.md) | ansible | Configuration management |
| [Crossplane](skills/cicd/crossplane/SKILL.md) | multi-cloud | K8s-native infra |

### Otros

| Skill | Keywords | Descripción |
|-------|----------|-------------|
| [Figma](skills/figma/SKILL.md) | figma, design | Extracción de assets |
| [GraphQL](skills/graphql/SKILL.md) | graphql | Cliente GraphQL |
| [Static Analysis](skills/static-analysis/SKILL.md) | lint, sast | Dart Analyzer, Datadog SAST |

## MCP Servers

Configurados en `mcp.json`:

| Servidor | Uso |
|----------|-----|
| Flutter/Dart | Análisis estático, pub.dev, widgets |
| Figma | Assets, tokens de diseño |
| Apollo GraphQL | Introspección de esquemas |
| Context7 | Documentación técnica |
| Mobile | Gestión de dispositivos |
| Stitch | Generación de UI |

Ver [docs/MCP_SETUP.md](./docs/MCP_SETUP.md) para configuración.

## Documentación Adicional

- [Plantilla IEEE 830](docs/templates/IEEE_830_TEMPLATE.md) - Para especificaciones de requisitos
- [Mapeo de Mejores Prácticas](skills/flutter/BEST_PRACTICES_MAPPING.md) - Prácticas por skill

---

**Última actualización:** Febrero 2025
