# Open Control CLI Tools

Build, upload, and monitor tools for Open Control PlatformIO projects.

## Installation

### Linux / macOS

```bash
cd cli-tools
./install.sh
source ~/.bashrc  # or ~/.zshrc
```

### Windows (Git Bash / WSL)

```powershell
cd cli-tools
powershell -ExecutionPolicy Bypass -File install.ps1
# Restart terminal
```

### Manual

Add to your shell config (`~/.bashrc`, `~/.zshrc`, or `~/.profile`):

```bash
export PATH="$PATH:/path/to/open-control/cli-tools/bin"
```

## Commands

Run from any directory within a PlatformIO project:

| Command | Description |
|---------|-------------|
| `oc-build` | Build project |
| `oc-upload` | Build and upload to device |
| `oc-monitor` | Build, upload, and open serial monitor |
| `oc-clean` | Clean build artifacts |

### Examples

```bash
cd my-project
oc-build              # Build with auto-detected env
oc-build dev          # Build with dev environment
oc-upload release     # Build and upload release
oc-monitor            # Full workflow with monitor
```

### Environment Detection

1. **Explicit argument**: `oc-build dev` uses `dev`
2. **Last used**: Auto-detects from most recent `.pio/build/*`
3. **Default**: Falls back to `default_envs` in `platformio.ini`
4. **Fallback**: Uses `dev` if nothing else found

## Output

```
example-project dev

Building ⠋ 3s

Dependencies
  │ framework @ 0.1.3
  │ hal-teensy @ 0.1.3

Memory
  FLASH ░░░░░░░░░░░░░░░░ 92KB/7.8MB (1%)
  RAM1  ███░░░░░░░░░░░░░ 124KB/512KB (24%)
  RAM2  ░░░░░░░░░░░░░░░░ 17KB/512KB (3%)

BUILD OK 3s
```

## Features

- Auto-detect project root (walks up to find `platformio.ini`)
- Works from any subdirectory of the project
- Spinner animation during build/upload
- Memory usage bars (FLASH, RAM1, RAM2, PSRAM)
- Dependency graph display
- Warning/error summary with file:line
- Cross-platform (Linux, macOS, Windows via Git Bash/WSL)
