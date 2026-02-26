#!/bin/bash

# ==============================================================================
# AltruPets - Stitch Assets Fetcher (Pure Bash)
# ==============================================================================
# Fetches design assets from Stitch (Google's AI design tool)
# Usage:
#   ./fetch_stitch.sh <screen_id>
#   make dev-stitch-fetch SCREEN_ID=<screen_id>
#
# Environment variables (from .env):
#   GOOGLE_CLOUD_PROJECT (required) - GCP project number for quota
#   STITCH_PROJECT_ID (required) - Stitch project ID
# ==============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SCREEN_ID="${1:-}"
STITCH_BASE_URL="https://stitch.googleapis.com/mcp"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

error_exit() {
	echo -e "${RED}❌ Error: $1${NC}" >&2
	exit "$2"
}

if [ -f "$PROJECT_ROOT/.env" ]; then
	source "$PROJECT_ROOT/.env"
fi

if [ -z "${GOOGLE_CLOUD_PROJECT:-}" ]; then
	error_exit "GOOGLE_CLOUD_PROJECT not set in .env (use project number: 344341424155)" 1
fi

if [ -z "${STITCH_PROJECT_ID:-}" ]; then
	error_exit "STITCH_PROJECT_ID not set in .env" 1
fi

if [ -z "$SCREEN_ID" ]; then
	error_exit "No screen_id provided. Usage: ./fetch_stitch.sh <screen_id>" 1
fi

echo -e "${BLUE}🔌 AltruPets - Stitch Assets Fetcher${NC}"
echo "  GCP Project: $GOOGLE_CLOUD_PROJECT (quota project)"
echo "  Stitch Project: $STITCH_PROJECT_ID"
echo "  Screen: $SCREEN_ID"
echo ""

OUTPUT_DIR="$SCRIPT_DIR/$SCREEN_ID"
mkdir -p "$OUTPUT_DIR"

LOG_FILE="$OUTPUT_DIR/fetch.log"
echo "=== Started at $(date) ===" >>"$LOG_FILE"

log() {
	echo -e "$1"
	echo "$(date +%H:%M:%S) - $2" >>"$LOG_FILE"
}

get_oauth_token() {
	local token
	token=$(gcloud auth print-access-token 2>/dev/null || echo "")
	if [ -z "$token" ]; then
		log "$RED" "Failed to get OAuth token"
		echo -e "${ORANGE}⚠️ Run: gcloud auth login${NC}" >&2
	fi
	echo "$token"
}

mcp_request() {
	local method_name="$1"
	local params_json="$2"

	local response
	local http_code

	local json_payload
	if [ "$params_json" = "null" ] || [ -z "$params_json" ]; then
		json_payload="{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"${method_name}\"}"
	else
		json_payload="{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"${method_name}\",\"params\":${params_json}}"
	fi

	http_code=$(curl -s -o /tmp/stitch_response.json -w "%{http_code}" -X POST "$STITCH_BASE_URL" \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $OAUTH_TOKEN" \
		-H "X-Goog-User-Project: $GOOGLE_CLOUD_PROJECT" \
		-d "$json_payload" 2>>"$LOG_FILE")

	response=$(cat /tmp/stitch_response.json)
	rm -f /tmp/stitch_response.json

	echo "$response"
}

# Get OAuth token
OAUTH_TOKEN=$(get_oauth_token)

if [ -z "$OAUTH_TOKEN" ]; then
	error_exit "No OAuth token. Run: gcloud auth login" 1
fi

log "$BLUE" "Starting MCP handshake..."

# Initialize
RESPONSE=$(mcp_request "initialize" '{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"bash","version":"1.0"}}')

if echo "$RESPONSE" | grep -q '"error"'; then
	log "$RED" "Initialize failed: $RESPONSE"
	echo -e "${RED}❌ MCP Initialize failed${NC}" >&2
	exit 1
fi

log "$BLUE" "MCP initialized successfully"

# Send notifications/initialized
mcp_request "notifications/initialized" "null" >/dev/null

# Now fetch screen
log "$BLUE" "Fetching screen $SCREEN_ID..."

# Note: projectId should be the Stitch project ID (9064173060952920822), not GCP project number
SCREEN_JSON=$(mcp_request "tools/call" '{"name":"get_screen","arguments":{"projectId":"'"${STITCH_PROJECT_ID}"'","screenId":"'"${SCREEN_ID}"'"}}')

if echo "$SCREEN_JSON" | grep -q '"error"'; then
	log "$RED" "API Error: $SCREEN_JSON"
	echo -e "${RED}❌ Stitch API Error:${NC}" >&2
	echo "$SCREEN_JSON" | jq '.error.message' 2>/dev/null || echo "$SCREEN_JSON" >&2
	exit 1
fi

echo "$SCREEN_JSON" >"$OUTPUT_DIR/screen_response.json"
log "$GREEN" "Screen response saved"

SCREEN_NAME=$(echo "$SCREEN_JSON" | jq -r '.result.content[0].text // "unknown"' 2>/dev/null)
log "$BLUE" "Screen name: $SCREEN_NAME"
echo "  Screen name: $SCREEN_NAME"

# Extract and download files from the JSON response
echo "$SCREEN_JSON" | jq -r '.result.content[0].text' >"$OUTPUT_DIR/screen_data.json"
SCREEN_DATA=$(cat "$OUTPUT_DIR/screen_data.json")

# Parse the nested JSON in text field
HTML_CODE_URL=$(echo "$SCREEN_DATA" | jq -r '.htmlCode.downloadUrl // empty' 2>/dev/null)
if [ -n "$HTML_CODE_URL" ] && [ "$HTML_CODE_URL" != "null" ] && [ "$HTML_CODE_URL" != "" ]; then
	log "$BLUE" "Downloading HTML code from $HTML_CODE_URL..."
	if curl -s -o "$OUTPUT_DIR/screen_code.html" "$HTML_CODE_URL"; then
		log "$GREEN" "HTML code saved"
		echo -e "${GREEN}✅ HTML code saved${NC}"
	else
		log "$ORANGE" "Failed to download HTML code"
		echo -e "${ORANGE}⚠️ Failed to download HTML code${NC}"
	fi
else
	log "$ORANGE" "No HTML code URL found"
	echo -e "${ORANGE}⚠️ No HTML code available${NC}"
fi

SCREENSHOT_URL=$(echo "$SCREEN_DATA" | jq -r '.screenshot.downloadUrl // empty' 2>/dev/null)
if [ -n "$SCREENSHOT_URL" ] && [ "$SCREENSHOT_URL" != "null" ] && [ "$SCREENSHOT_URL" != "" ]; then
	log "$BLUE" "Downloading screenshot from $SCREENSHOT_URL..."
	if curl -s -o "$OUTPUT_DIR/screenshot.png" "$SCREENSHOT_URL"; then
		log "$GREEN" "Screenshot saved"
		echo -e "${GREEN}✅ Screenshot saved${NC}"
	else
		log "$ORANGE" "Failed to download screenshot"
		echo -e "${ORANGE}⚠️ Failed to download screenshot${NC}"
	fi
else
	log "$ORANGE" "No screenshot URL found"
	echo -e "${ORANGE}⚠️ No screenshot available${NC}"
fi

CSS_URL=$(echo "$SCREEN_DATA" | jq -r '.cssCode.downloadUrl // empty' 2>/dev/null)
if [ -n "$CSS_URL" ] && [ "$CSS_URL" != "null" ] && [ "$CSS_URL" != "" ]; then
	log "$BLUE" "Downloading CSS from $CSS_URL..."
	if curl -s -o "$OUTPUT_DIR/styles.css" "$CSS_URL"; then
		log "$GREEN" "CSS saved"
		echo -e "${GREEN}✅ CSS saved${NC}"
	fi
fi

echo ""
echo -e "${GREEN}✅ Assets fetched to: $OUTPUT_DIR${NC}"
echo ""
echo "Files:"
ls -la "$OUTPUT_DIR"
