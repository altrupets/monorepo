#!/bin/bash
# ============================================
# Run Security Scanner as Kubernetes Job in Minikube
# ============================================
#
# This script creates a Kubernetes Job in Minikube to run security scans
#
# Usage:
#   ./run-security-scan-minikube.sh [target]
#
# Targets:
#   all        - Run all scans (default)
#   deps       - Dependency vulnerability scan
#   sast       - Static Application Security Testing
#   secrets    - Secret scanning
#   container  - Container image scanning
#   iac        - Infrastructure as Code scanning
#   fix        - Auto-fix vulnerabilities where possible

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TARGET="${1:-all}"
NAMESPACE="altrupets-dev"
JOB_NAME="security-scan-${TARGET}-$(date +%s)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Security Scanner - Kubernetes Job (Minikube)          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if minikube is running
if ! minikube status &>/dev/null; then
    echo -e "${RED}❌ Minikube is not running. Start it with: make dev-minikube-deploy${NC}"
    exit 1
fi

# Check if namespace exists
if ! kubectl get namespace "$NAMESPACE" &>/dev/null; then
    echo -e "${YELLOW}⚠️  Namespace $NAMESPACE does not exist. Creating...${NC}"
    kubectl create namespace "$NAMESPACE"
fi

echo -e "${BLUE}Creating Kubernetes Job: $JOB_NAME${NC}"
echo -e "${BLUE}Target: $TARGET${NC}"
echo -e "${BLUE}Namespace: $NAMESPACE${NC}"
echo ""

# Create the Job manifest
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: $JOB_NAME
  namespace: $NAMESPACE
  labels:
    app: security-scanner
    scan-type: $TARGET
spec:
  ttlSecondsAfterFinished: 300
  backoffLimit: 0
  template:
    metadata:
      labels:
        app: security-scanner
        scan-type: $TARGET
    spec:
      restartPolicy: Never
      containers:
      - name: scanner
        image: altrupets/security-scanner:latest
        imagePullPolicy: Never
        args: ["$TARGET"]
        volumeMounts:
        - name: workspace
          mountPath: /workspace
        - name: reports
          mountPath: /reports
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "2000m"
      volumes:
      - name: workspace
        hostPath:
          path: $PROJECT_ROOT
          type: Directory
      - name: reports
        hostPath:
          path: $PROJECT_ROOT/.security-reports
          type: DirectoryOrCreate
EOF

echo -e "${GREEN}✓ Job created${NC}"
echo ""

# Wait for the job to start
echo -e "${BLUE}Waiting for job to start...${NC}"
kubectl wait --for=condition=Ready pod -l job-name=$JOB_NAME -n $NAMESPACE --timeout=60s 2>/dev/null || true

# Get the pod name
POD_NAME=$(kubectl get pods -n $NAMESPACE -l job-name=$JOB_NAME -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -z "$POD_NAME" ]; then
    echo -e "${RED}❌ Failed to get pod name${NC}"
    kubectl get jobs -n $NAMESPACE -l app=security-scanner
    exit 1
fi

echo -e "${GREEN}✓ Pod started: $POD_NAME${NC}"
echo ""

# Stream logs
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}                     Scanner Output                             ${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo ""

kubectl logs -f $POD_NAME -n $NAMESPACE 2>/dev/null || true

echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo ""

# Check job status
JOB_STATUS=$(kubectl get job $JOB_NAME -n $NAMESPACE -o jsonpath='{.status.conditions[0].type}' 2>/dev/null || echo "Unknown")

if [ "$JOB_STATUS" = "Complete" ]; then
    echo -e "${GREEN}✅ Security scan completed successfully!${NC}"
    echo ""
    echo -e "${BLUE}Reports saved to: $PROJECT_ROOT/.security-reports${NC}"
    echo ""
    
    # Show summary if it exists
    LATEST_SUMMARY=$(ls -t "$PROJECT_ROOT/.security-reports"/summary-*.md 2>/dev/null | head -1 || echo "")
    if [ -n "$LATEST_SUMMARY" ]; then
        echo -e "${BLUE}Summary Report:${NC}"
        echo ""
        cat "$LATEST_SUMMARY"
    fi
    
    exit 0
else
    echo -e "${RED}❌ Security scan failed${NC}"
    echo ""
    echo -e "${YELLOW}Job status: $JOB_STATUS${NC}"
    echo ""
    echo -e "${BLUE}To debug, run:${NC}"
    echo "  kubectl describe job $JOB_NAME -n $NAMESPACE"
    echo "  kubectl logs $POD_NAME -n $NAMESPACE"
    echo ""
    exit 1
fi
