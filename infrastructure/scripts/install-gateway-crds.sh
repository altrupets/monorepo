#!/usr/bin/env bash
set -euo pipefail

CRD_URL="${1:?CRD URL is required}"
NGINX_VERSION="${2:?NGINX version is required}"

echo "Installing Gateway API CRDs from NGINX (v${NGINX_VERSION})..."
kubectl apply -k "${CRD_URL}" --server-side

echo "Waiting for CRDs to be established..."
kubectl wait --for=condition=established --timeout=180s crd/gatewayclasses.gateway.networking.k8s.io
kubectl wait --for=condition=established --timeout=180s crd/gateways.gateway.networking.k8s.io
kubectl wait --for=condition=established --timeout=180s crd/httproutes.gateway.networking.k8s.io
kubectl wait --for=condition=established --timeout=180s crd/referencegrants.gateway.networking.k8s.io

echo "Gateway API CRDs installation completed!"
