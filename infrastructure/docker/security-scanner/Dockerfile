FROM python:3.12-slim

LABEL maintainer="AltruPets DevSecOps Team"
LABEL description="Security scanner with trivy, trufflehog, checkov, tfsec"
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
    && rm -rf /var/lib/apt/lists/*

# Install Trivy
RUN wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add - && \
    echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | tee -a /etc/apt/sources.list.d/trivy.list && \
    apt-get update && \
    apt-get install -y trivy && \
    rm -rf /var/lib/apt/lists/*

# Install tfsec
RUN curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash

# Install Python security tools via pip
RUN pip install --no-cache-dir \
    trufflehog==2.2.1 \
    checkov==3.2.504 \
    safety \
    bandit

# Install Node.js for npm audit
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Flutter/Dart (for dart analyze)
RUN git clone https://github.com/flutter/flutter.git -b stable --depth 1 /opt/flutter && \
    /opt/flutter/bin/flutter precache && \
    /opt/flutter/bin/flutter config --no-analytics

ENV PATH="/opt/flutter/bin:${PATH}"

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
