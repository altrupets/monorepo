#!/usr/bin/env python3
"""
AltruPets Backend Admin Server
Serves endpoints to control backend operations from the mobile app.
"""

import os
import sys
import subprocess
import datetime
import uuid
from http.server import HTTPServer, BaseHTTPRequestHandler
from pathlib import Path

HOST = "localhost"
PORT = 3002

SCRIPT_DIR = Path(__file__).parent.resolve()
PROJECT_DIR = SCRIPT_DIR.parent
LOG_DIR = PROJECT_DIR / "logs" / "backend"


def get_log_filename():
    ts = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    return LOG_DIR / f"admin-server-{ts}.log"


LOG_FILE = get_log_filename()

BACKEND_START_COMMAND = (
    "make setup && make dev-minikube-deploy && make dev-terraform-deploy && "
    "make dev-harbor-deploy && make dev-images-build && make dev-argocd-push-and-deploy && "
    "make dev-gateway-start"
)


def ensure_log_dir():
    LOG_DIR.mkdir(parents=True, exist_ok=True)


def log(message: str):
    """Write log message to file and stdout."""
    ensure_log_dir()
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_line = f"[{timestamp}] {message}\n"
    with open(LOG_FILE, "a") as f:
        f.write(log_line)
    print(log_line.strip())


def execute_backend_command() -> dict:
    """Execute the backend start command and return result."""
    request_id = str(uuid.uuid4())[:8]

    log(f"[{request_id}] 🔍 Checking if minikube is running...")
    minikube_running = (
        subprocess.run(
            "minikube status -o json 2>/dev/null | grep -q 'Running'",
            shell=True,
            capture_output=True,
        ).returncode
        == 0
    )

    if minikube_running:
        log(f"[{request_id}] ✅ Minikube already running, starting gateway only")
        COMMAND = "make dev-gateway-start"
    else:
        log(f"[{request_id}] 🚀 Minikube not running, starting full deployment...")
        COMMAND = BACKEND_START_COMMAND

    log(f"[{request_id}] Command: {COMMAND}")

    start_time = datetime.datetime.now()

    try:
        result = subprocess.run(
            BACKEND_START_COMMAND,
            shell=True,
            capture_output=True,
            text=True,
            cwd=PROJECT_DIR,
        )

        duration = (datetime.datetime.now() - start_time).total_seconds()

        if result.returncode == 0:
            log(f"[{request_id}] ✅ Backend deployment completed in {duration:.1f}s")
            return {
                "success": True,
                "request_id": request_id,
                "duration_seconds": duration,
                "output": result.stdout[-5000:] if result.stdout else "",
            }
        else:
            log(
                f"[{request_id}] ❌ Backend deployment failed (exit code {result.returncode})"
            )
            return {
                "success": False,
                "request_id": request_id,
                "duration_seconds": duration,
                "error": result.stderr[-2000:] if result.stderr else "Unknown error",
                "output": result.stdout[-5000:] if result.stdout else "",
            }

    except Exception as e:
        duration = (datetime.datetime.now() - start_time).total_seconds()
        log(f"[{request_id}] ❌ Exception: {str(e)}")
        return {
            "success": False,
            "request_id": request_id,
            "duration_seconds": duration,
            "error": str(e),
        }


class AdminHandler(BaseHTTPRequestHandler):
    """HTTP request handler for admin endpoints."""

    def log_message(self, format, *args):
        """Suppress default HTTP logging."""
        pass

    def send_json_response(self, status_code: int, data: dict):
        """Send JSON response."""
        import json

        self.send_response(status_code)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())

    def do_GET(self):
        """Handle GET requests."""
        if self.path == "/health":
            self.send_json_response(200, {"status": "ok", "service": "altrupets-admin"})
        elif self.path == "/":
            self.send_json_response(
                200,
                {
                    "service": "AltruPets Backend Admin",
                    "version": "1.0.0",
                    "endpoints": {
                        "GET /health": "Health check",
                        "POST /restart-backend": "Restart backend deployment",
                    },
                },
            )
        else:
            self.send_json_response(404, {"error": "Not found"})

    def do_POST(self):
        """Handle POST requests."""
        if self.path == "/restart-backend":
            result = execute_backend_command()
            if result["success"]:
                self.send_json_response(200, result)
            else:
                self.send_json_response(500, result)
        else:
            self.send_json_response(404, {"error": "Not found"})


def main():
    """Start the admin server."""
    ensure_log_dir()

    log(f"🚀 Starting AltruPets Admin Server on {HOST}:{PORT}")
    log(f"📁 Log file: {LOG_FILE}")

    server = HTTPServer((HOST, PORT), AdminHandler)

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        log("🛑 Server stopped")
        server.shutdown()
        sys.exit(0)


if __name__ == "__main__":
    main()
