param(
  [Parameter(Mandatory = $true)]
  [string]$CrdUrl,
  [Parameter(Mandatory = $true)]
  [string]$NginxVersion
)

$ErrorActionPreference = "Stop"

Write-Host "Installing Gateway API CRDs from NGINX (v$NginxVersion)..."
kubectl apply -k $CrdUrl --server-side

Write-Host "Waiting for CRDs to be established..."
kubectl wait --for=condition=established --timeout=180s crd/gatewayclasses.gateway.networking.k8s.io
kubectl wait --for=condition=established --timeout=180s crd/gateways.gateway.networking.k8s.io
kubectl wait --for=condition=established --timeout=180s crd/httproutes.gateway.networking.k8s.io
kubectl wait --for=condition=established --timeout=180s crd/referencegrants.gateway.networking.k8s.io

Write-Host "Gateway API CRDs installation completed!"
