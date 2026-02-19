FROM python:3.12-slim

LABEL maintainer="AltruPets DevSecOps Team"
LABEL description="Security scanner with trivy, trufflehog3, checkov, tfsec"
LABEL version="1.0.0"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    gnupg \
    lsb-release \
    ca-certificates \
    apt-transport-https \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Trivy (binary from GitHub releases)
RUN TRIVY_VERSION=$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/') && \
    wget -q https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz && \
    tar -xzf trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz && \
    mv trivy /usr/local/bin/ && \
    rm trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz

# Install tfsec
RUN curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash

# Install Python security tools via pip
RUN pip install --no-cache-dir \
    trufflehog3 \
    checkov \
    safety \
    bandit

# Install Node.js for npm audit
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /workspace

# Copy scanner script
COPY infrastructure/scripts/k8s-security-scan.sh /usr/local/bin/security-scan
RUN chmod +x /usr/local/bin/security-scan

# Create reports directory
RUN mkdir -p /reports

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/security-scan"]
CMD ["all"]
