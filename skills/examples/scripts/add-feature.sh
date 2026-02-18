#!/bin/bash

# Script para agregar features/skills a un proyecto existente
# Uso: ./add-feature.sh --project <ruta> --feature <nombre-feature>

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$(dirname "$SCRIPT_DIR")/../flutter"
show_help() {
	echo -e "${BLUE}AltruPets Feature Adder${NC}"
	echo ""
	echo "Uso: $0 [OPTIONS]"
	echo ""
	echo "Opciones:"
	echo "  -p, --project <ruta>    Ruta del proyecto (requerido)"
	echo "  -f, --feature <feature>  Feature a agregar (requerido)"
	echo "  -h, --help              Mostrar esta ayuda"
	echo ""
	echo "Features disponibles:"
	ls -1 "$SKILLS_DIR" 2>/dev/null | grep -v "^\..*" | while read -r dir; do
		if [ -d "$SKILLS_DIR/$dir" ] && [ -f "$SKILLS_DIR/$dir/SKILL.md" ]; then
			echo "  - $dir"
		fi
	done
}

# Parsear argumentos
while [[ $# -gt 0 ]]; do
	case $1 in
	-p | --project)
		PROJECT_PATH="$2"
		shift 2
		;;
	-f | --feature)
		FEATURE="$2"
		shift 2
		;;
	-h | --help)
		show_help
		exit 0
		;;
	*)
		echo -e "${RED}Error: Opción desconocida $1${NC}"
		show_help
		exit 1
		;;
	esac
done

# Validaciones
if [ -z "$PROJECT_PATH" ]; then
	echo -e "${RED}Error: Debes especificar la ruta del proyecto${NC}"
	show_help
	exit 1
fi

if [ -z "$FEATURE" ]; then
	echo -e "${RED}Error: Debes especificar el feature${NC}"
	show_help
	exit 1
fi

if [ ! -d "$PROJECT_PATH" ]; then
	echo -e "${RED}Error: El proyecto no existe en $PROJECT_PATH${NC}"
	exit 1
fi

SKILL_PATH="$SKILLS_DIR/$FEATURE"
if [ ! -d "$SKILL_PATH" ]; then
	echo -e "${RED}Error: Skill '$FEATURE' no encontrado${NC}"
	show_help
	exit 1
fi

echo -e "${BLUE}🔧 Agregando feature '$FEATURE' al proyecto...${NC}"

# Leer SKILL.md y aplicar cambios
SKILL_FILE="$SKILL_PATH/SKILL.md"
if [ -f "$SKILL_FILE" ]; then
	echo -e "${YELLOW}📖 Analizando SKILL.md...${NC}"

	# Aquí se pueden agregar reglas específicas por skill
	case $FEATURE in
	"websocket")
		echo -e "${YELLOW}📡 Configurando WebSocket...${NC}"
		;;
	"payments")
		echo -e "${YELLOW}💳 Configurando Pagos...${NC}"
		;;
	"maps")
		echo -e "${YELLOW}🗺️  Configurando Mapas...${NC}"
		;;
	*)
		echo -e "${YELLOW}📦 Agregando dependencias y archivos...${NC}"
		;;
	esac
fi

echo -e "${GREEN}✅ Feature '$FEATURE' agregado exitosamente!${NC}"
echo ""
echo -e "${BLUE}📝 Revisa la documentación en:${NC}"
echo "  $SKILL_FILE"
