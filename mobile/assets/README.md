# Assets de AltruPets

Esta carpeta contiene los assets de la aplicación AltruPets.

## 📁 Estructura

```
assets/
├── images/        # Imágenes de la aplicación
│   ├── logos/     # Logos de AltruPets
│   ├── icons/     # Iconos personalizados
│   └── onboarding/ # Imágenes de onboarding
├── icons/         # Iconos SVG/PNG para la app
└── fonts/         # Fuentes personalizadas (opcional)
```

## 🎨 Integración con Figma

Para extraer assets desde Figma, usar el skill `@skill:figma`:

### Ejemplo de uso:

```
Prompt: "Extrae todos los iconos del design system de Figma y guárdalos en assets/icons/"
```

```
Prompt: "Extrae el logo de AltruPets desde Figma y guárdalo en assets/images/logos/"
```

### Configuración

1. Configurar token de Figma en variables de entorno:
```bash
export FIGMA_TOKEN="tu-token-personal-de-figma"
```

2. El servidor MCP de Figma está configurado en `mcp.json` del proyecto raíz.

3. Los assets extraídos aparecerán con URLs localhost que puedes usar directamente en la app.

## 📝 Mejores Prácticas

- **Prioriza assets desde Figma**: Usa siempre los assets del diseño oficial cuando estén disponibles
- **Formato**: Usa SVG para iconos, PNG/JPG para imágenes fotográficas
- **Naming**: Usa nombres descriptivos en snake_case (ej: `icon_pet_rescue.svg`)
- **Organización**: Mantén los assets organizados por tipo y uso

## 🔗 Referencias

- [Skill de Figma](../../skills/figma/SKILL.md)
- [Flutter Assets](https://docs.flutter.dev/development/ui/assets-and-images)
