#!/bin/bash
# Open Control - Build and upload (no monitor)
# Usage: oc-upload.sh [env]   - run from project dir or subdirectory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT=$(find_project_root) || error "platformio.ini not found (run from project directory)"
cd "$PROJECT_ROOT"

ENV=$(detect_env "$PROJECT_ROOT" "$1")

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
