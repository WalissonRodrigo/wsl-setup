#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

chmod +x \
    "${SCRIPT_DIR}/setup.sh" \
    "${SCRIPT_DIR}/install-gh-cli.sh" \
    "${SCRIPT_DIR}/verify-dotnet.sh" \
    "${SCRIPT_DIR}/verify-rtk.sh" \
    "${SCRIPT_DIR}/verify-gh.sh"

"${SCRIPT_DIR}/setup.sh"
"${SCRIPT_DIR}/verify-dotnet.sh"
"${SCRIPT_DIR}/verify-rtk.sh"
"${SCRIPT_DIR}/verify-gh.sh"

printf '\n[bootstrap-workspace] Ambiente WSL provisionado e validado.\n'
