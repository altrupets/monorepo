#!/bin/bash
# ==============================================================================
# AltruPets Admin Server - Systemd Installation Script
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_NAME="altrupets-admin"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🔧 Installing AltruPets Admin Server as systemd service...${NC}"

# Verify Python is available
if ! command -v python3 >/dev/null 2>&1; then
	echo -e "${RED}❌ Python3 not found. Please install Python 3.${NC}"
	exit 1
fi

# Verify the server script exists
if [ ! -f "$SCRIPT_DIR/backend_admin_server.py" ]; then
	echo -e "${RED}❌ backend_admin_server.py not found in $SCRIPT_DIR${NC}"
	exit 1
fi

# Get current user
CURRENT_USER=$(whoami)

# Create systemd service file
echo -e "${BLUE}📝 Creating systemd service file...${NC}"
cat >"$SERVICE_FILE" <<EOF
[Unit]
Description=AltruPets Backend Admin Server
After=network.target
Wants=network.target

[Service]
Type=simple
User=$CURRENT_USER
WorkingDirectory=$SCRIPT_DIR
ExecStart=/usr/bin/python3 $SCRIPT_DIR/backend_admin_server.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo -e "${GREEN}✅ Service file created at $SERVICE_FILE${NC}"

# Reload systemd daemon
echo -e "${BLUE}🔄 Reloading systemd daemon...${NC}"
sudo systemctl daemon-reload

# Enable service to start on boot
echo -e "${BLUE}📦 Enabling service to start on boot...${NC}"
sudo systemctl enable "$SERVICE_NAME"

# Start the service
echo -e "${BLUE}🚀 Starting service...${NC}"
sudo systemctl start "$SERVICE_NAME"

# Wait a moment and check status
sleep 2

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ Installation complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Service status:"
sudo systemctl status "$SERVICE_NAME" --no-pager
echo ""
echo "Useful commands:"
echo "  sudo systemctl status $SERVICE_NAME   # Check status"
echo "  sudo systemctl restart $SERVICE_NAME   # Restart service"
echo "  sudo systemctl stop $SERVICE_NAME     # Stop service"
echo "  sudo systemctl disable $SERVICE_NAME  # Disable autostart"
echo ""
echo "Log directory: $SCRIPT_DIR/logs/backend/"
echo ""
echo "Test locally:"
echo "  curl http://localhost:3002/health"
echo "  curl -X POST http://localhost:3002/restart-backend"
echo ""
