#!/bin/bash

# ==============================================================================
# AltruPets - Flutter Analysis Script
# ==============================================================================
# Run dart analyze and other Flutter static analysis tools
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

usage() {
	echo "Usage: $0 [command]"
	echo ""
	echo "Commands:"
	echo "  analyze     Run dart analyze (default)"
	echo "  test        Run Flutter unit tests"
	echo "  coverage    Run tests with coverage"
	echo "  lint        Run all linting (analyze + custom checks)"
	echo "  all         Run all analysis"
	echo ""
}

check_flutter() {
	if ! command -v flutter >/dev/null 2>&1; then
		echo -e "${RED}❌ Flutter is not installed${NC}"
		exit 1
	fi
}

run_analyze() {
	echo -e "${BLUE}🔍 Running dart analyze...${NC}"
	cd "${SCRIPT_DIR}"
	flutter analyze
	echo -e "${GREEN}✓ Analysis complete${NC}"
}

run_test() {
	echo -e "${BLUE}🧪 Running Flutter unit tests...${NC}"
	cd "${SCRIPT_DIR}"
	flutter test
	echo -e "${GREEN}✓ Tests passed${NC}"
}

run_coverage() {
	echo -e "${BLUE}📊 Running tests with coverage...${NC}"
	cd "${SCRIPT_DIR}"
	flutter test --coverage
	echo -e "${GREEN}✓ Coverage report: ${SCRIPT_DIR}/coverage/lcov.info${NC}"
}

run_lint() {
	echo -e "${BLUE}🔧 Running all linting...${NC}"
	run_analyze

	# Check for formatting issues
	echo -e "${BLUE}Checking formatting...${NC}"
	cd "${SCRIPT_DIR}"
	flutter format --set-exit-if-changed lib/ test/ 2>/dev/null || {
		echo -e "${YELLOW}⚠️  Some files need formatting. Run: flutter format lib/ test/${NC}"
	}

	echo -e "${GREEN}✓ Linting complete${NC}"
}

run_all() {
	echo -e "${BLUE}🚀 Running full analysis...${NC}"
	run_analyze
	run_test
	echo -e "${GREEN}✅ All checks passed!${NC}"
}

# Main
COMMAND="${1:-analyze}"

case "${COMMAND}" in
analyze)
	check_flutter
	run_analyze
	;;
test)
	check_flutter
	run_test
	;;
coverage)
	check_flutter
	run_coverage
	;;
lint)
	check_flutter
	run_lint
	;;
all)
	check_flutter
	run_all
	;;
-h | --help | help)
	usage
	;;
*)
	echo -e "${RED}Unknown command: ${COMMAND}${NC}"
	usage
	exit 1
	;;
esac
