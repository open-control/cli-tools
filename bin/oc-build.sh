#!/bin/bash
# Open Control - Build only (no upload, no monitor)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-$(pwd)}"
PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"
[[ ! -f "$PROJECT_ROOT/platformio.ini" ]] && error "platformio.ini not found"
cd "$PROJECT_ROOT"

ENV=$(detect_env "$PROJECT_ROOT" "$2")

clear
echo -e "${BOLD}${PROJECT_ROOT##*/}${NC} ${GRAY}$ENV${NC}"
echo ""

echo -ne "${HIDE_CURSOR}"
trap "echo -ne '${SHOW_CURSOR}'" EXIT

BUILD_OUTPUT=""
START=$(date +%s)

run_with_spinner "Building" pio run -e "$ENV" -d "$PROJECT_ROOT"
STATUS=$?

TOTAL=$(($(date +%s) - START))
echo -ne "${SHOW_CURSOR}"

show_results "$BUILD_OUTPUT" "$PROJECT_ROOT" "$ENV" "$STATUS" "$TOTAL"
exit $STATUS
