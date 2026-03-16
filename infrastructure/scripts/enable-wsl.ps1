# Habilitar WSL2 en Windows
# Ejecutar como Administrador (PowerShell)

Write-Host "Habilitando WSL2..." -ForegroundColor Yellow

# Habilitar WSL
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# Habilitar Virtual Machine Platform
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

Write-Host "Configurando WSL2 como predeterminado..." -ForegroundColor Yellow
wsl --set-default-version 2

Write-Host ""
Write-Host "Completado! Reinicia tu PC y luego ejecuta:" -ForegroundColor Green
Write-Host "  wsl --install -d Ubuntu-24.04" -ForegroundColor Cyan
Write-Host ""
Write-Host "O si ya tienes Ubuntu instalado:" -ForegroundColor Cyan
Write-Host "  wsl -d altrupets-ubuntu" -ForegroundColor Cyan
Write-Host ""

Pause