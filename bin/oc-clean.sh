#!/bin/bash
# Open Control - Clean build files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

PROJECT_ROOT="${1:-$(pwd)}"
[[ ! -f "$PROJECT_ROOT/platformio.ini" ]] && error "platformio.ini not found"

clear
echo -e "${BOLD}${PROJECT_ROOT##*/}${NC} ${GRAY}clean${NC}"
echo ""

log "Cleaning build artifacts..."
rm -rf "$PROJECT_ROOT/.pio/build"
success "Clean complete"
