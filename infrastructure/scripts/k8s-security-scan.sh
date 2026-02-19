#!/bin/bash
# ==============================================================================
# AltruPets - Kubernetes Security Scan Runner
# ==============================================================================
# Runs security scans based on the target argument.
# Targets: all, deps, sast, secrets, container, iac, fix
# ==============================================================================

set -euo pipefail

TARGET="${1:-all}"
WORKSPACE="/workspace"
REPORTS="/reports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  AltruPets Security Scanner                                    ${NC}"
echo -e "${BLUE}  Target: $TARGET                                               ${NC}"
echo -e "${BLUE}  Timestamp: $TIMESTAMP                                         ${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo ""

mkdir -p "$REPORTS"

run_trivy_fs() {
	echo -e "${BLUE}[Trivy] Filesystem vulnerability scan...${NC}"
	trivy fs --quiet --format table --output "$REPORTS/trivy-fs-$TIMESTAMP.txt" "$WORKSPACE" 2>/dev/null || true
	trivy fs --quiet --format json --output "$REPORTS/trivy-fs-$TIMESTAMP.json" "$WORKSPACE" 2>/dev/null || true
	echo -e "${GREEN}[Trivy] Done${NC}"
}

run_trivy_iac() {
	echo -e "${BLUE}[Trivy] IaC configuration scan...${NC}"
	trivy config --quiet --format table --output "$REPORTS/trivy-iac-$TIMESTAMP.txt" "$WORKSPACE/infrastructure" 2>/dev/null || true
	echo -e "${GREEN}[Trivy IaC] Done${NC}"
}

run_trufflehog() {
	echo -e "${BLUE}[TruffleHog] Secret scanning...${NC}"
	trufflehog3 --no-history --output "$REPORTS/trufflehog-$TIMESTAMP.json" "$WORKSPACE" 2>/dev/null || true
	echo -e "${GREEN}[TruffleHog] Done${NC}"
}

run_checkov() {
	echo -e "${BLUE}[Checkov] Terraform/IaC scan...${NC}"
	if [ -d "$WORKSPACE/infrastructure/terraform" ]; then
		checkov --directory "$WORKSPACE/infrastructure/terraform" \
			--output json \
			--output-file-path "$REPORTS" \
			--soft-fail 2>/dev/null || true
		mv "$REPORTS"/results_json.json "$REPORTS/checkov-$TIMESTAMP.json" 2>/dev/null || true
	else
		echo -e "${YELLOW}[Checkov] Terraform directory not found, skipping${NC}"
	fi
	echo -e "${GREEN}[Checkov] Done${NC}"
}

run_tfsec() {
	echo -e "${BLUE}[tfsec] Terraform security scan...${NC}"
	if [ -d "$WORKSPACE/infrastructure/terraform" ]; then
		tfsec "$WORKSPACE/infrastructure/terraform" --format default --out "$REPORTS/tfsec-$TIMESTAMP.txt" 2>/dev/null || true
	else
		echo -e "${YELLOW}[tfsec] Terraform directory not found, skipping${NC}"
	fi
	echo -e "${GREEN}[tfsec] Done${NC}"
}

run_safety() {
	echo -e "${BLUE}[Safety] Python dependency scan...${NC}"
	safety check --json >"$REPORTS/safety-$TIMESTAMP.json" 2>/dev/null || true
	echo -e "${GREEN}[Safety] Done${NC}"
}

run_npm_audit() {
	echo -e "${BLUE}[npm audit] Node.js dependency scan...${NC}"
	if [ -f "$WORKSPACE/apps/backend/package.json" ]; then
		cd "$WORKSPACE/apps/backend"
		npm audit --json >"$REPORTS/npm-audit-backend-$TIMESTAMP.json" 2>/dev/null || true
	fi
	if [ -f "$WORKSPACE/apps/mobile/package.json" ]; then
		cd "$WORKSPACE/apps/mobile"
		npm audit --json >"$REPORTS/npm-audit-mobile-$TIMESTAMP.json" 2>/dev/null || true
	fi
	echo -e "${GREEN}[npm audit] Done${NC}"
}

run_flutter_analyze() {
	echo -e "${BLUE}[Flutter] Static analysis...${NC}"
	if command -v flutter >/dev/null 2>&1 && [ -d "$WORKSPACE/apps/mobile" ]; then
		cd "$WORKSPACE/apps/mobile"
		flutter analyze >"$REPORTS/flutter-analyze-$TIMESTAMP.txt" 2>&1 || true
	fi
	echo -e "${GREEN}[Flutter] Done${NC}"
}

generate_summary() {
	SUMMARY="$REPORTS/summary-$TIMESTAMP.md"
	echo "# Security Scan Summary" >"$SUMMARY"
	echo "" >>"$SUMMARY"
	echo "**Timestamp:** $(date)" >>"$SUMMARY"
	echo "**Target:** $TARGET" >>"$SUMMARY"
	echo "" >>"$SUMMARY"

	echo "## Reports Generated" >>"$SUMMARY"
	for f in "$REPORTS"/*-$TIMESTAMP.*; do
		[ -f "$f" ] && echo "- $(basename "$f")" >>"$SUMMARY"
	done

	echo "" >>"$SUMMARY"
	echo "## Quick Stats" >>"$SUMMARY"

	if [ -f "$REPORTS/trivy-fs-$TIMESTAMP.json" ]; then
		CRITICAL=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity=="CRITICAL")] | length' "$REPORTS/trivy-fs-$TIMESTAMP.json" 2>/dev/null || echo "0")
		HIGH=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity=="HIGH")] | length' "$REPORTS/trivy-fs-$TIMESTAMP.json" 2>/dev/null || echo "0")
		echo "- Trivy: $CRITICAL critical, $HIGH high vulnerabilities" >>"$SUMMARY"
	fi

	if [ -f "$REPORTS/trufflehog-$TIMESTAMP.json" ]; then
		SECRETS=$(jq 'length' "$REPORTS/trufflehog-$TIMESTAMP.json" 2>/dev/null || echo "0")
		echo "- TruffleHog: $SECRETS potential secrets found" >>"$SUMMARY"
	fi

	echo -e "${GREEN}Summary saved to: $SUMMARY${NC}"
	cat "$SUMMARY"
}

case "$TARGET" in
all)
	run_trivy_fs
	run_trivy_iac
	run_trufflehog
	run_checkov
	run_tfsec
	run_safety
	run_npm_audit
	run_flutter_analyze
	;;
deps)
	run_trivy_fs
	run_safety
	run_npm_audit
	;;
sast)
	run_flutter_analyze
	;;
secrets)
	run_trufflehog
	;;
container)
	run_trivy_fs
	;;
iac)
	run_trivy_iac
	run_checkov
	run_tfsec
	;;
fix)
	echo -e "${YELLOW}Auto-fix not yet implemented${NC}"
	;;
*)
	echo -e "${RED}Unknown target: $TARGET${NC}"
	exit 1
	;;
esac

generate_summary

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Security scan completed!                                      ${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"

exit 0
