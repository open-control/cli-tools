#!/bin/bash
# Open Control - Build, upload and monitor
# Usage: oc-monitor.sh [env]   - run from project dir or subdirectory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT=$(find_project_root) || error "platformio.ini not found (run from project directory)"
cd "$PROJECT_ROOT"

ENV=$(detect_env "$PROJECT_ROOT" "$1")

kill_monitors

clear
echo -e "${BOLD}${PROJECT_ROOT##*/}${NC} ${GRAY}$ENV${NC}"
echo ""

echo -ne "${HIDE_CURSOR}"
trap "echo -ne '${SHOW_CURSOR}'" EXIT

BUILD_OUTPUT=""
START=$(date +%s)

# Build
if ! run_with_spinner "Building" pio run -e "$ENV" -d "$PROJECT_ROOT"; then
    TOTAL=$(($(date +%s) - START))
    echo -ne "${SHOW_CURSOR}"
    show_results "$BUILD_OUTPUT" "$PROJECT_ROOT" "$ENV" 1 "$TOTAL"
    exit 1
fi

# Upload (nobuild to skip rebuild)
if ! run_with_spinner "Uploading" pio run -e "$ENV" -d "$PROJECT_ROOT" -t nobuild -t upload; then
    TOTAL=$(($(date +%s) - START))
    echo -ne "${SHOW_CURSOR}"
    show_results "$BUILD_OUTPUT" "$PROJECT_ROOT" "$ENV" 1 "$TOTAL"
    exit 1
fi

TOTAL=$(($(date +%s) - START))
echo -ne "${SHOW_CURSOR}"

show_results "$BUILD_OUTPUT" "$PROJECT_ROOT" "$ENV" 0 "$TOTAL"

# Monitor info
PORT=$(echo "$BUILD_OUTPUT" | grep -oP "Uploading.*?(COM[0-9]+|/dev/tty[A-Za-z0-9]+)" | grep -oP "(COM[0-9]+|/dev/tty[A-Za-z0-9]+)" || echo "auto")
SPEED=$(grep -E "^monitor_speed" "$PROJECT_ROOT/platformio.ini" 2>/dev/null | sed 's/monitor_speed *= *//' || echo "115200")
echo -e "${GRAY}Monitor : ${PORT} @ ${SPEED}${NC}"
echo -e "${GRAY}─────────────────────────────────${NC}"

sleep 1
exec pio device monitor -d "$PROJECT_ROOT" --quiet
