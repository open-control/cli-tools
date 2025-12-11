# Open Control CLI Tools

Build, upload, and monitor tools for Open Control projects.

## Installation

Add `cli-tools/bin` to your PATH:

```bash
# In ~/.bashrc or ~/.zshrc
export PATH="$PATH:/path/to/open-control/cli-tools/bin"
```

## Usage

Run commands from any directory within a PlatformIO project:

```bash
cd my-project        # or any subdirectory
oc-build.sh          # Build only
oc-upload.sh         # Build + upload
oc-monitor.sh        # Build + upload + monitor
oc-clean.sh          # Clean build files
```

### Environment selection

By default, scripts auto-detect the last used environment. Override with:

```bash
oc-build.sh dev      # Force dev environment
oc-build.sh release  # Force release environment
```

## Tools

| Script | Description |
|--------|-------------|
| `oc-clean.sh` | Clean build files |
| `oc-build.sh` | Build only |
| `oc-upload.sh` | Build + upload |
| `oc-monitor.sh` | Build + upload + serial monitor |

## Features

- Auto-detect project root (walks up to find `platformio.ini`)
- Auto-detect last used environment
- Spinner animation during build/upload
- Memory usage bars (FLASH, RAM1, RAM2, PSRAM)
- Dependency graph display
- Warning/error summary with file:line
