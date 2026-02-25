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
import re
from http.server import HTTPServer, BaseHTTPRequestHandler
from pathlib import Path


def clean_ansi(text: str) -> str:
    """Remove ANSI escape codes and convert \n to actual newlines."""
    ansi_escape = re.compile(r"\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])")
    text = ansi_escape.sub("", text)
    return text


HOST = "localhost"
PORT = 3002

SCRIPT_DIR = Path(__file__).parent.resolve()
PROJECT_DIR = SCRIPT_DIR.parent
LOG_DIR = PROJECT_DIR / "logs" / "backend"


def get_log_filename():
    ts = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    return LOG_DIR / f"admin-server-{ts}.log"


LOG_FILE = get_log_filename()


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


BACKEND_COMMANDS = [
    "make setup",
    "make dev-minikube-deploy",
    "make dev-terraform-deploy",
    "make dev-harbor-deploy",
    "make dev-images-build",
    "make dev-argocd-push-and-deploy",
    "make dev-gateway-start",
]


def run_command_streaming(command: str, request_id: str) -> tuple[bool, str]:
    """Run a command with streaming output to stdout."""
    log(f"[{request_id}] ▶️  {command}")
    try:
        process = subprocess.Popen(
            command,
            shell=True,
            cwd=PROJECT_DIR,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
        )
        output_lines = []
        if process.stdout:
            for line in iter(process.stdout.readline, ""):
                print(line.rstrip())
                output_lines.append(line)
        process.wait()
        output = "".join(output_lines)
        success = process.returncode == 0
        if success:
            log(f"[{request_id}] ✅ {command} - OK")
        else:
            log(
                f"[{request_id}] ❌ {command} - FAILED (exit code {process.returncode})"
            )
        return success, output
    except Exception as e:
        log(f"[{request_id}] ❌ {command} - EXCEPTION: {str(e)}")
        return False, str(e)


def execute_backend_command() -> dict:
    """Execute the backend start commands sequentially with streaming output."""
    request_id = str(uuid.uuid4())[:8]

    log(f"[{request_id}] 🚀 Starting full backend deployment...")
    commands_to_run = BACKEND_COMMANDS

    start_time = datetime.datetime.now()
    all_success = True
    full_output = ""

    for cmd in commands_to_run:
        success, output = run_command_streaming(cmd, request_id)
        full_output += output + "\n"
        if not success:
            all_success = False
            break

    duration = (datetime.datetime.now() - start_time).total_seconds()
    cleaned_output = clean_ansi(full_output[-5000:]) if full_output else ""

    if all_success:
        log(f"[{request_id}] ✅ Backend deployment completed in {duration:.1f}s")
        return {
            "success": True,
            "request_id": request_id,
            "duration_seconds": duration,
            "output": cleaned_output,
        }
    else:
        log(f"[{request_id}] ❌ Backend deployment failed after {duration:.1f}s")
        return {
            "success": False,
            "request_id": request_id,
            "duration_seconds": duration,
            "error": "One or more commands failed",
            "output": cleaned_output,
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
