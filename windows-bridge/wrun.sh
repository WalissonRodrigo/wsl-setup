#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WIN_SCRIPT="$(cygpath -w "${SCRIPT_DIR}/wrun.ps1")"

exec powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${WIN_SCRIPT}" "$@"
