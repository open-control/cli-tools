#!/bin/bash
# Open Control CLI - Shared utilities
# Source: source "$SCRIPT_DIR/../lib/common.sh"

set -e

# ═══════════════════════════════════════════════════════════════════
# Colors
# ═══════════════════════════════════════════════════════════════════
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
GRAY='\033[90m'
NC='\033[0m'

HIDE_CURSOR='\033[?25l'
SHOW_CURSOR='\033[?25h'

# ═══════════════════════════════════════════════════════════════════
# Logging
# ═══════════════════════════════════════════════════════════════════
log()     { echo -e "${CYAN}●${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn()    { echo -e "${YELLOW}⚠${NC} $1"; }
error()   { echo -e "${RED}✗${NC} $1" >&2; exit 1; }

# ═══════════════════════════════════════════════════════════════════
# Project root detection (walks up from pwd to find platformio.ini)
# ═══════════════════════════════════════════════════════════════════
find_project_root() {
    local dir="${1:-$(pwd)}"
    while [[ "$dir" != "/" && ! -f "$dir/platformio.ini" ]]; do
        dir="$(dirname "$dir")"
    done
    [[ -f "$dir/platformio.ini" ]] && echo "$dir" || return 1
}

# ═══════════════════════════════════════════════════════════════════
# Spinner
# ═══════════════════════════════════════════════════════════════════
SPIN='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
SPIN_IDX=0

spin_next() {
    echo "${SPIN:$SPIN_IDX:1}"
    SPIN_IDX=$(( (SPIN_IDX + 1) % 10 ))
}

# Run command with spinner: run_with_spinner "Label" command args...
# Sets BUILD_OUTPUT and returns command exit status
run_with_spinner() {
    local label="$1"; shift
    local start=$(date +%s)
    local logfile=$(mktemp)

    "$@" > "$logfile" 2>&1 &
    local pid=$!

    while kill -0 $pid 2>/dev/null; do
        local elapsed=$(($(date +%s) - start))
        printf "\r${GRAY}%s $(spin_next) %ds${NC}   " "$label" "$elapsed"
        sleep 0.1
    done
    wait $pid
    local status=$?
    printf "\r                           \r"

    BUILD_OUTPUT="${BUILD_OUTPUT}$(cat "$logfile")"$'\n'
    rm -f "$logfile"
    return $status
}

# ═══════════════════════════════════════════════════════════════════
# Progress bar
# ═══════════════════════════════════════════════════════════════════
draw_bar() {
    local pct=$1
    local width=${2:-16}
    local filled=$((pct * width / 100))
    local empty=$((width - filled))
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    echo "$bar"
}

# ═══════════════════════════════════════════════════════════════════
# Memory display (Teensy)
# ═══════════════════════════════════════════════════════════════════
show_memory() {
    local output="$1"

    local FLASH_LINE=$(echo "$output" | grep "teensy_size:.*FLASH:")
    local RAM1_LINE=$(echo "$output" | grep "teensy_size:.*RAM1:")
    local RAM2_LINE=$(echo "$output" | grep "teensy_size:.*RAM2:")
    local EXTRAM_LINE=$(echo "$output" | grep "teensy_size:.*EXTRAM:")

    [[ -z "$FLASH_LINE" ]] && return

    echo -e "${GRAY}Memory${NC}"

    # FLASH
    local FLASH_CODE=$(echo "$FLASH_LINE" | grep -oP "code:\K[0-9]+")
    local FLASH_DATA=$(echo "$FLASH_LINE" | grep -oP "data:\K[0-9]+")
    local FLASH_HDR=$(echo "$FLASH_LINE" | grep -oP "headers:\K[0-9]+")
    local FLASH_FREE=$(echo "$FLASH_LINE" | grep -oP "free for files:\K[0-9]+")
    local FLASH_USED=$((FLASH_CODE + FLASH_DATA + FLASH_HDR))
    local FLASH_TOTAL=$((FLASH_USED + FLASH_FREE))
    local FLASH_PCT=$((FLASH_USED * 100 / FLASH_TOTAL))
    local FLASH_KB=$((FLASH_USED / 1024))
    local FLASH_TOTAL_MB=$(awk "BEGIN {printf \"%.1f\", $FLASH_TOTAL/1024/1024}")
    echo -e "  ${GRAY}FLASH $(draw_bar $FLASH_PCT) ${FLASH_KB}KB/${FLASH_TOTAL_MB}MB (${FLASH_PCT}%)${NC}"

    # RAM1
    if [[ -n "$RAM1_LINE" ]]; then
        local RAM1_VARS=$(echo "$RAM1_LINE" | grep -oP "variables:\K[0-9]+" | head -1)
        local RAM1_CODE=$(echo "$RAM1_LINE" | grep -oP "code:\K[0-9]+" | head -1)
        local RAM1_PAD=$(echo "$RAM1_LINE" | grep -oP "padding:\K[0-9]+" | head -1)
        local RAM1_FREE=$(echo "$RAM1_LINE" | grep -oP "free for local variables:\K[0-9]+" | head -1)
        if [[ -n "$RAM1_VARS" && -n "$RAM1_CODE" && -n "$RAM1_PAD" && -n "$RAM1_FREE" ]]; then
            local RAM1_USED=$((RAM1_VARS + RAM1_CODE + RAM1_PAD))
            local RAM1_TOTAL=$((RAM1_USED + RAM1_FREE))
            local RAM1_PCT=$((RAM1_USED * 100 / RAM1_TOTAL))
            local RAM1_KB=$((RAM1_USED / 1024))
            local RAM1_TOTAL_KB=$((RAM1_TOTAL / 1024))
            echo -e "  ${GRAY}RAM1  $(draw_bar $RAM1_PCT) ${RAM1_KB}KB/${RAM1_TOTAL_KB}KB (${RAM1_PCT}%)${NC}"
        fi
    fi

    # RAM2
    if [[ -n "$RAM2_LINE" ]]; then
        local RAM2_VARS=$(echo "$RAM2_LINE" | grep -oP "variables:\K[0-9]+" | head -1)
        local RAM2_FREE=$(echo "$RAM2_LINE" | grep -oP "free for malloc/new:\K[0-9]+" | head -1)
        if [[ -n "$RAM2_VARS" && -n "$RAM2_FREE" ]]; then
            local RAM2_USED=$RAM2_VARS
            local RAM2_TOTAL=$((RAM2_USED + RAM2_FREE))
            local RAM2_PCT=$((RAM2_USED * 100 / RAM2_TOTAL))
            local RAM2_KB=$((RAM2_USED / 1024))
            local RAM2_TOTAL_KB=$((RAM2_TOTAL / 1024))
            echo -e "  ${GRAY}RAM2  $(draw_bar $RAM2_PCT) ${RAM2_KB}KB/${RAM2_TOTAL_KB}KB (${RAM2_PCT}%)${NC}"
        fi
    fi

    # EXTRAM (PSRAM)
    if [[ -n "$EXTRAM_LINE" ]]; then
        local EXTRAM_VARS=$(echo "$EXTRAM_LINE" | grep -oP "variables:\K[0-9]+" | head -1)
        if [[ -n "$EXTRAM_VARS" ]]; then
            local EXTRAM_TOTAL=8388608
            local EXTRAM_PCT=$((EXTRAM_VARS * 100 / EXTRAM_TOTAL))
            local EXTRAM_KB=$((EXTRAM_VARS / 1024))
            echo -e "  ${GRAY}PSRAM $(draw_bar $EXTRAM_PCT) ${EXTRAM_KB}KB/8MB (${EXTRAM_PCT}%)${NC}"
        fi
    fi
    echo ""
}

# ═══════════════════════════════════════════════════════════════════
# Dependencies display
# ═══════════════════════════════════════════════════════════════════
show_dependencies() {
    local output="$1"
    local project_root="$2"
    local env="$3"

    # Parse symlink paths from platformio.ini
    declare -A LIB_PATHS
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*([a-zA-Z0-9_-]+)=symlink://(.+)$ ]]; then
            LIB_PATHS["${BASH_REMATCH[1]}"]="$project_root/${BASH_REMATCH[2]}"
        fi
    done < <(sed -n "/^\[env:$env\]/,/^\[/p" "$project_root/platformio.ini" 2>/dev/null | grep -E "symlink://")

    echo -e "${GRAY}Dependencies${NC}"
    echo "$output" | grep -E "^\|--" | head -10 | while IFS= read -r line; do
        local lib=$(echo "$line" | sed 's/|-- //' | cut -d' ' -f1)
        local ver=$(echo "$line" | grep -oP '@ \K[0-9.]+' || echo "")
        local path="${LIB_PATHS[$lib]}"

        if [[ -n "$path" && -d "$path" ]]; then
            printf "  ${GRAY}│ %s @ %s → %s${NC}\n" "$lib" "$ver" "${path##*/}"
        else
            printf "  ${GRAY}│ %s @ %s${NC}\n" "$lib" "$ver"
        fi
    done
    echo ""
}

# ═══════════════════════════════════════════════════════════════════
# Warnings/Errors display
# ═══════════════════════════════════════════════════════════════════
show_warnings() {
    local output="$1"
    local count
    count=$(echo "$output" | grep -c "warning:" 2>/dev/null || true)
    count=${count:-0}
    count=$(echo "$count" | tr -d '[:space:]')

    [[ "$count" -eq 0 || -z "$count" ]] && return

    echo -e "${YELLOW}Warnings : ${count}${NC}"
    echo "$output" | grep "warning:" | head -5 | while IFS= read -r line; do
        local file=$(echo "$line" | cut -d: -f1)
        local num=$(echo "$line" | cut -d: -f2)
        local msg=$(echo "$line" | sed 's/.*warning: //')
        printf "  ${YELLOW}%s:%s${NC} ${GRAY}%s${NC}\n" "${file##*/}" "$num" "$msg"
    done
    [[ "$count" -gt 5 ]] && echo -e "  ${GRAY}... and $((count-5)) more${NC}"
    echo ""
}

show_errors() {
    local output="$1"
    local count
    count=$(echo "$output" | grep -c "error:" 2>/dev/null || true)
    count=${count:-0}
    count=$(echo "$count" | tr -d '[:space:]')

    [[ "$count" -eq 0 || -z "$count" ]] && return

    echo -e "${RED}Errors : ${count}${NC}"
    echo "$output" | grep "error:" | head -5 | while IFS= read -r line; do
        local file=$(echo "$line" | cut -d: -f1)
        local num=$(echo "$line" | cut -d: -f2)
        local msg=$(echo "$line" | sed 's/.*error: //')
        printf "  ${RED}%s:%s${NC} ${GRAY}%s${NC}\n" "${file##*/}" "$num" "$msg"
    done
    [[ "$count" -gt 5 ]] && echo -e "  ${GRAY}... and $((count-5)) more${NC}"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════
# Environment detection
# ═══════════════════════════════════════════════════════════════════
detect_env() {
    local project_root="$1"
    local explicit="$2"
    local env=""

    if [[ -n "$explicit" ]]; then
        env="$explicit"
    elif [[ -d "$project_root/.pio/build" ]]; then
        # Only list directories (not files like project.checksum), sorted by mtime
        env=$(find "$project_root/.pio/build" -maxdepth 1 -type d ! -name build -printf '%T@ %f\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
    fi

    # Fallback to default_envs or dev
    if [[ -z "$env" ]]; then
        env=$(grep -E "^default_envs" "$project_root/platformio.ini" 2>/dev/null | sed 's/default_envs *= *//')
    fi

    echo "${env:-dev}"
}

# ═══════════════════════════════════════════════════════════════════
# Kill existing monitors
# ═══════════════════════════════════════════════════════════════════
kill_monitors() {
    if command -v taskkill &>/dev/null; then
        taskkill //F //IM python.exe 2>/dev/null || true
    else
        pkill -f "pio device monitor" 2>/dev/null || true
    fi
    sleep 0.5
}

# ═══════════════════════════════════════════════════════════════════
# Build results display
# ═══════════════════════════════════════════════════════════════════
show_results() {
    local output="$1"
    local project_root="$2"
    local env="$3"
    local status="$4"
    local time="$5"

    show_dependencies "$output" "$project_root" "$env"
    show_memory "$output"
    show_warnings "$output"

    if [[ "$status" -ne 0 ]]; then
        show_errors "$output"
        echo -e "${RED}${BOLD}BUILD FAILED${NC} ${GRAY}${time}s${NC}"
        return 1
    fi

    if echo "$output" | grep -q "Uploading"; then
        echo -e "${GREEN}${BOLD}BUILD OK${NC} ${GRAY}Uploaded in ${time}s${NC}"
    else
        echo -e "${GREEN}${BOLD}BUILD OK${NC} ${GRAY}${time}s${NC}"
    fi
    echo ""
}
