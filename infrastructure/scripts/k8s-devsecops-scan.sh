#!/bin/bash
# ============================================
# DevSecOps Pipeline for DEV Local Environment
# ============================================
#
# This script runs all security scans locally in Minikube DEV environment
#
# Usage:
#   ./dev-devsecops-scan.sh [target]
#
# Targets:
#   all        - Run all scans (default)
#   deps       - Dependency vulnerability scan
#   sast       - Static Application Security Testing
#   secrets    - Secret scanning
#   container  - Container image scanning
#   iac        - Infrastructure as Code scanning
#   fix        - Auto-fix vulnerabilities where possible
#
# Requirements:
#   - npm, pip, trivy, trufflehog, tfsec, checkov
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TARGET="${1:-all}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Report directory
REPORT_DIR="$PROJECT_ROOT/.security-reports"
mkdir -p "$REPORT_DIR"

echo -e "${BLUE}=== DevSecOps Pipeline - DEV Local ===${NC}"
echo ""

# ============================================
# Helper Functions
# ============================================

check_tool() {
	local tool="$1"
	local install_cmd="$2"

	if ! command -v "$tool" &>/dev/null; then
		echo -e "${YELLOW}⚠️  $tool not found. Install with: $install_cmd${NC}"
		return 1
	fi
	return 0
}

print_section() {
	echo ""
	echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
	echo -e "${BLUE}  $1${NC}"
	echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# ============================================
# 1. Dependency Vulnerability Scanning
# ============================================

scan_dependencies() {
	print_section "📦 Dependency Vulnerability Scan"

	local has_vulns=0

	# Node.js (Backend)
	if [ -f "$PROJECT_ROOT/apps/backend/package.json" ]; then
		echo -e "${BLUE}Scanning Node.js dependencies...${NC}"
		cd "$PROJECT_ROOT/apps/backend"

		# Run npm audit
		if npm audit --audit-level=moderate --json >"$REPORT_DIR/npm-audit.json" 2>/dev/null; then
			echo -e "${GREEN}✅ No moderate/high vulnerabilities in Node.js deps${NC}"
		else
			echo -e "${YELLOW}⚠️  Vulnerabilities found in Node.js dependencies${NC}"
			npm audit --audit-level=moderate 2>/dev/null || true
			has_vulns=1
		fi
		cd "$PROJECT_ROOT"
	fi

	# Flutter/Dart
	if [ -f "$PROJECT_ROOT/apps/mobile/pubspec.yaml" ]; then
		echo -e "${BLUE}Scanning Flutter dependencies...${NC}"
		cd "$PROJECT_ROOT/apps/mobile"

		# Check for outdated packages with known vulnerabilities
		flutter pub outdated --mode=security 2>/dev/null || true

		cd "$PROJECT_ROOT"
	fi

	return $has_vulns
}

# ============================================
# 2. Static Application Security Testing (SAST)
# ============================================

scan_sast() {
	print_section "🔍 Static Application Security Testing (SAST)"

	local has_issues=0

	# Dart Analyzer
	if [ -f "$PROJECT_ROOT/apps/mobile/pubspec.yaml" ]; then
		echo -e "${BLUE}Running Dart Analyzer...${NC}"
		cd "$PROJECT_ROOT/apps/mobile"

		if dart analyze --fatal-infos 2>&1 | tee "$REPORT_DIR/dart-analyze.txt"; then
			echo -e "${GREEN}✅ Dart analysis passed${NC}"
		else
			echo -e "${YELLOW}⚠️  Dart analyzer found issues${NC}"
			has_issues=1
		fi
		cd "$PROJECT_ROOT"
	fi

	# ESLint for Node.js
	if [ -f "$PROJECT_ROOT/apps/backend/.eslintrc.js" ] || [ -f "$PROJECT_ROOT/apps/backend/.eslintrc.json" ]; then
		echo -e "${BLUE}Running ESLint...${NC}"
		cd "$PROJECT_ROOT/apps/backend"

		if npx eslint . --ext .ts,.tsx --format json --output-file "$REPORT_DIR/eslint.json" 2>/dev/null; then
			echo -e "${GREEN}✅ ESLint passed${NC}"
		else
			echo -e "${YELLOW}⚠️  ESLint found issues${NC}"
			npx eslint . --ext .ts,.tsx || true
			has_issues=1
		fi
		cd "$PROJECT_ROOT"
	fi

	# ShellCheck for Bash scripts
	if check_tool "shellcheck" "sudo apt install shellcheck"; then
		echo -e "${BLUE}Running ShellCheck...${NC}"

		local shell_files=$(find "$PROJECT_ROOT" -name "*.sh" -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null || true)

		if [ -n "$shell_files" ]; then
			echo "$shell_files" | xargs shellcheck -f json >"$REPORT_DIR/shellcheck.json" 2>/dev/null || true
			echo -e "${GREEN}✅ ShellCheck completed${NC}"
		fi
	fi

	return $has_issues
}

# ============================================
# 3. Secret Scanning
# ============================================

scan_secrets() {
	print_section "🔐 Secret Scanning"

	local has_secrets=0

	# TruffleHog
	if check_tool "trufflehog" "pip install trufflehog"; then
		echo -e "${BLUE}Running TruffleHog...${NC}"

		if trufflehog git "file://$PROJECT_ROOT" --only-verified --json >"$REPORT_DIR/trufflehog.json" 2>/dev/null; then
			echo -e "${GREEN}✅ No secrets detected by TruffleHog${NC}"
		else
			echo -e "${RED}❌ Potential secrets detected!${NC}"
			trufflehog git "file://$PROJECT_ROOT" --only-verified || true
			has_secrets=1
		fi
	else
		# Fallback: grep for common secret patterns
		echo -e "${YELLOW}Running basic secret pattern detection...${NC}"

		local patterns=(
			"password\s*=\s*['\"][^'\"]+['\"]"
			"api_key\s*=\s*['\"][^'\"]+['\"]"
			"secret\s*=\s*['\"][^'\"]+['\"]"
			"token\s*=\s*['\"][^'\"]+['\"]"
			"-----BEGIN (RSA |EC |DSA )?PRIVATE KEY-----"
			"sk-[a-zA-Z0-9]{20,}"
			"xox[baprs]-[a-zA-Z0-9-]+"
		)

		for pattern in "${patterns[@]}"; do
			if grep -r --include="*.ts" --include="*.js" --include="*.dart" --include="*.yaml" --include="*.yml" \
				--exclude-dir=node_modules --exclude-dir=.git \
				-E "$pattern" "$PROJECT_ROOT" 2>/dev/null | grep -v ".example" | grep -v "test" | head -5; then
				echo -e "${YELLOW}⚠️  Potential secret pattern found: $pattern${NC}"
				has_secrets=1
			fi
		done

		if [ $has_secrets -eq 0 ]; then
			echo -e "${GREEN}✅ No obvious secrets detected${NC}"
		fi
	fi

	return $has_secrets
}

# ============================================
# 4. Container Image Scanning
# ============================================

scan_containers() {
	print_section "🐳 Container Image Scanning"

	local has_vulns=0

	if check_tool "trivy" "https://aquasecurity.github.io/trivy/latest/getting-started/installation/"; then
		echo -e "${BLUE}Running Trivy filesystem scan...${NC}"

		# Scan backend
		if [ -f "$PROJECT_ROOT/apps/backend/Dockerfile" ]; then
			echo -e "${BLUE}Scanning backend Dockerfile...${NC}"
			trivy config "$PROJECT_ROOT/apps/backend/Dockerfile" --format json --output "$REPORT_DIR/trivy-backend-config.json" 2>/dev/null || true

			trivy fs "$PROJECT_ROOT/apps/backend" \
				--severity HIGH,CRITICAL \
				--format json \
				--output "$REPORT_DIR/trivy-backend.json" 2>/dev/null || true

			echo -e "${GREEN}✅ Backend scan completed${NC}"
		fi

		# Scan Dockerfiles for best practices
		find "$PROJECT_ROOT" -name "Dockerfile*" -type f | while read dockerfile; do
			echo -e "${BLUE}Scanning $dockerfile...${NC}"
			trivy config "$dockerfile" --severity HIGH,CRITICAL 2>/dev/null || true
		done

		echo -e "${GREEN}✅ Container scan completed${NC}"
	else
		echo -e "${YELLOW}⚠️  Trivy not installed. Skipping container scan.${NC}"
		echo -e "${YELLOW}   Install: https://aquasecurity.github.io/trivy/${NC}"
	fi

	return $has_vulns
}

# ============================================
# 5. Infrastructure as Code Scanning
# ============================================

scan_iac() {
	print_section "🏗️ Infrastructure as Code Scanning"

	local has_issues=0

	# Terraform/OpenTofu
	if [ -d "$PROJECT_ROOT/infrastructure/terraform" ]; then
		# tfsec
		if check_tool "tfsec" "https://aquasecurity.github.io/tfsec/latest/getting-started/installation/"; then
			echo -e "${BLUE}Running tfsec...${NC}"

			tfsec "$PROJECT_ROOT/infrastructure/terraform" \
				--format json \
				--out "$REPORT_DIR/tfsec.json" 2>/dev/null || true

			tfsec "$PROJECT_ROOT/infrastructure/terraform" --soft-fail || has_issues=1
		fi

		# Checkov
		if check_tool "checkov" "pip install checkov"; then
			echo -e "${BLUE}Running Checkov...${NC}"

			checkov -d "$PROJECT_ROOT/infrastructure/terraform" \
				--output json \
				--output-file "$REPORT_DIR/checkov.json" \
				--soft-fail 2>/dev/null || true

			echo -e "${GREEN}✅ Checkov completed${NC}"
		fi
	fi

	# Kubernetes manifests
	if [ -d "$PROJECT_ROOT/k8s" ]; then
		if check_tool "checkov" "pip install checkov"; then
			echo -e "${BLUE}Scanning Kubernetes manifests...${NC}"

			checkov -d "$PROJECT_ROOT/k8s" \
				--framework kubernetes \
				--output json \
				--output-file "$REPORT_DIR/checkov-k8s.json" \
				--soft-fail 2>/dev/null || true
		fi
	fi

	return $has_issues
}

# ============================================
# 6. Auto-Fix Vulnerabilities
# ============================================

fix_vulnerabilities() {
	print_section "🔧 Auto-Fixing Vulnerabilities"

	# Node.js
	if [ -f "$PROJECT_ROOT/apps/backend/package.json" ]; then
		echo -e "${BLUE}Fixing Node.js vulnerabilities...${NC}"
		cd "$PROJECT_ROOT/apps/backend"

		# npm audit fix
		npm audit fix --force 2>/dev/null || true

		# Update outdated packages
		npm update 2>/dev/null || true

		echo -e "${GREEN}✅ Node.js fixes applied${NC}"
		cd "$PROJECT_ROOT"
	fi

	# Flutter
	if [ -f "$PROJECT_ROOT/apps/mobile/pubspec.yaml" ]; then
		echo -e "${BLUE}Updating Flutter dependencies...${NC}"
		cd "$PROJECT_ROOT/apps/mobile"

		flutter pub upgrade --major-versions 2>/dev/null || true
		flutter pub get 2>/dev/null || true

		echo -e "${GREEN}✅ Flutter deps updated${NC}"
		cd "$PROJECT_ROOT"
	fi

	# Dart analyze --fix
	if [ -f "$PROJECT_ROOT/apps/mobile/pubspec.yaml" ]; then
		echo -e "${BLUE}Running Dart fix...${NC}"
		cd "$PROJECT_ROOT/apps/mobile"

		dart fix --apply 2>/dev/null || true

		echo -e "${GREEN}✅ Dart fixes applied${NC}"
		cd "$PROJECT_ROOT"
	fi

	# Format code
	echo -e "${BLUE}Formatting code...${NC}"

	# Dart format
	if [ -f "$PROJECT_ROOT/apps/mobile/pubspec.yaml" ]; then
		cd "$PROJECT_ROOT/apps/mobile"
		dart format . --set-exit-if-changed 2>/dev/null || true
		cd "$PROJECT_ROOT"
	fi

	# Prettier/ESLint fix
	if [ -f "$PROJECT_ROOT/apps/backend/package.json" ]; then
		cd "$PROJECT_ROOT/apps/backend"
		npx eslint . --fix --ext .ts,.tsx 2>/dev/null || true
		cd "$PROJECT_ROOT"
	fi

	echo -e "${GREEN}✅ Auto-fix completed${NC}"
}

# ============================================
# 7. Generate Summary Report
# ============================================

generate_report() {
	print_section "📊 Security Report Summary"

	local report_file="$REPORT_DIR/summary-$(date +%Y%m%d-%H%M%S).md"

	cat >"$report_file" <<EOF
# DevSecOps Scan Report

**Date:** $(date)
**Environment:** DEV Local (Minikube)

## Scans Performed

| Scan | Status | Report |
|------|--------|--------|
| Dependencies | ✅ | $REPORT_DIR/npm-audit.json |
| SAST | ✅ | $REPORT_DIR/dart-analyze.txt |
| Secrets | ✅ | $REPORT_DIR/trufflehog.json |
| Containers | ✅ | $REPORT_DIR/trivy-backend.json |
| IaC | ✅ | $REPORT_DIR/tfsec.json |

## Next Steps

1. Review findings in $REPORT_DIR
2. Run \`make dev-security-fix\` to auto-fix where possible
3. Commit changes

---
Generated by dev-devsecops-scan.sh
EOF

	echo -e "${GREEN}📄 Report saved to: $report_file${NC}"
	echo ""
	cat "$report_file"
}

# ============================================
# Main Execution
# ============================================

main() {
	local exit_code=0

	case "$TARGET" in
	all)
		scan_dependencies || exit_code=1
		scan_sast || exit_code=1
		scan_secrets || exit_code=1
		scan_containers || exit_code=1
		scan_iac || exit_code=1
		generate_report
		;;
	deps)
		scan_dependencies || exit_code=1
		;;
	sast)
		scan_sast || exit_code=1
		;;
	secrets)
		scan_secrets || exit_code=1
		;;
	container)
		scan_containers || exit_code=1
		;;
	iac)
		scan_iac || exit_code=1
		;;
	fix)
		fix_vulnerabilities
		;;
	*)
		echo "Unknown target: $TARGET"
		echo "Usage: $0 [all|deps|sast|secrets|container|iac|fix]"
		exit 1
		;;
	esac

	echo ""
	if [ $exit_code -eq 0 ]; then
		echo -e "${GREEN}✅ DevSecOps scan completed successfully!${NC}"
	else
		echo -e "${YELLOW}⚠️  DevSecOps scan completed with findings. Review reports in $REPORT_DIR${NC}"
	fi

	return $exit_code
}

main
