param(
    [string]$DistroName = "altrupets-ubuntu",
    [string]$ConnectionName = "altrupets-ubuntu",
    [switch]$SkipPackageInstall,
    [switch]$InstallInfisical = $true
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

. "$PSScriptRoot\windows-dev-common.ps1"

Require-Command "wsl.exe"
Require-Command "podman"
Require-Command "ssh"
Require-Command "ssh-keygen"

if (-not (Test-WslDistroExists -DistroName $DistroName)) {
    throw "WSL distro '$DistroName' not found. Run setup-windows-dev-env.ps1 first."
}

$null = Ensure-WslKeepAlive -DistroName $DistroName

if (-not $SkipPackageInstall) {
    $installCommand = @(
        "set -euo pipefail",
        "export DEBIAN_FRONTEND=noninteractive",
        "apt-get update",
        "apt-get install -y openssh-server podman uidmap slirp4netns fuse-overlayfs ca-certificates curl gnupg"
    )

    if ($InstallInfisical) {
        $installCommand += "if ! command -v infisical >/dev/null 2>&1; then curl -1sLf 'https://artifacts-cli.infisical.com/setup.deb.sh' | bash; apt-get update; apt-get install -y infisical; fi"
    }

    Invoke-WslBash `
        -DistroName $DistroName `
        -Description "[podman-wsl] Installing Linux prerequisites..." `
        -Command ($installCommand -join "; ")
}

$keyPath = Join-Path $HOME ".ssh\altrupets_podman"
if (Test-Path $keyPath) {
    Remove-Item $keyPath -Force
}
if (Test-Path "$keyPath.pub") {
    Remove-Item "$keyPath.pub" -Force
}

Invoke-ExternalCommand `
    -Description "[podman-wsl] Generating SSH key..." `
    -FilePath "ssh-keygen.exe" `
    -Arguments @("-q", "-t", "ed25519", "-f", $keyPath, "-N", "", "-C", "altrupets-podman")

$pubKey = (Get-Content "$keyPath.pub" -Raw).Trim()
$remoteSetup = @"
set -euo pipefail
install -d -m 700 /root/.ssh
printf '%s\n' '$pubKey' > /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
install -d -m 755 /etc/ssh/sshd_config.d
cat > /etc/ssh/sshd_config.d/altrupets.conf <<'EOF'
PermitRootLogin prohibit-password
PasswordAuthentication no
PubkeyAuthentication yes
EOF
systemctl enable --now ssh >/dev/null
systemctl restart ssh >/dev/null
systemctl enable --now podman.socket >/dev/null
systemctl restart podman.socket >/dev/null
"@

Invoke-WslBash -DistroName $DistroName -Description "[podman-wsl] Configuring sshd and podman.socket..." -Command $remoteSetup

Invoke-ExternalCommand `
    -Description "[podman-wsl] Verifying SSH access..." `
    -FilePath "ssh.exe" `
    -Arguments @("-o", "BatchMode=yes", "-o", "StrictHostKeyChecking=accept-new", "-i", $keyPath, "root@localhost", "echo", "ssh-ok")

& podman system connection remove $ConnectionName -f 2>$null

Invoke-ExternalCommand `
    -Description "[podman-wsl] Registering Podman connection..." `
    -FilePath "podman.exe" `
    -Arguments @("system", "connection", "add", $ConnectionName, "ssh://root@localhost/run/podman/podman.sock", "--identity", $keyPath, "--default")

Invoke-ExternalCommand `
    -Description "[podman-wsl] Verifying Podman connection..." `
    -FilePath "podman.exe" `
    -Arguments @("version")
