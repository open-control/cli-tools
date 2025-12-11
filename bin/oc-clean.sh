#!/bin/bash
# Open Control - Clean build files
# Usage: oc-clean.sh   - run from project dir or subdirectory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT=$(find_project_root) || error "platformio.ini not found (run from project directory)"

clear
echo -e "${BOLD}${PROJECT_ROOT##*/}${NC} ${GRAY}clean${NC}"
echo ""

log "Cleaning build artifacts..."
rm -rf "$PROJECT_ROOT/.pio/build"
success "Clean complete"
