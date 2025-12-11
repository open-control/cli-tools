# Open Control CLI Tools

Build, upload, and monitor tools for Open Control projects.

## Installation

Add to your `platformio.ini`:

```ini
; Release
lib_deps =
    https://github.com/open-control/cli-tools

; Development
lib_deps =
    cli-tools=symlink://../cli-tools
```

## Usage

### Via wrapper script

Create `script/build.sh` in your project:

```bash
#!/bin/bash
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI_TOOLS=""

# Find cli-tools from .pio-link or sibling
PIO_LINK=$(find "$PROJECT_ROOT/.pio/libdeps" -maxdepth 2 -name "cli-tools.pio-link" 2>/dev/null | head -1)
if [[ -n "$PIO_LINK" ]]; then
    URI=$(grep -oP '"uri":\s*"symlink://\K[^"]+' "$PIO_LINK")
    [[ -n "$URI" ]] && CLI_TOOLS="$PROJECT_ROOT/$URI"
fi
[[ -z "$CLI_TOOLS" || ! -d "$CLI_TOOLS" ]] && CLI_TOOLS="$PROJECT_ROOT/../cli-tools"

exec "$CLI_TOOLS/bin/oc-monitor.sh" "$PROJECT_ROOT"
```

Then run:

```bash
./script/build.sh
```

### Direct execution

```bash
/path/to/cli-tools/bin/oc-monitor.sh /path/to/your/project
```

## Tools

| Script | Description |
|--------|-------------|
| `bin/oc-monitor.sh` | Build, upload, and start serial monitor |

## Features

- Spinner animation during build/upload
- Memory usage bars (FLASH, RAM1, RAM2, PSRAM)
- Dependency graph with clickable links (VSCode)
- Warning/error summary with file:line
- Auto-detect environment from `platformio.ini`
