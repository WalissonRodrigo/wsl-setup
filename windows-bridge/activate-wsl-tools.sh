#!/usr/bin/env bash

# This file is sourced from Git Bash startup. Avoid shell-wide strict mode here,
# because integrated terminals may run extra bootstrap commands that legitimately
# return non-zero during startup.
case "$-" in
    *i*) ;;
    *) return 0 2>/dev/null || exit 0 ;;
esac

SCRIPT_SOURCE="${BASH_SOURCE[0]:-$0}"
SCRIPT_DIR="$(cd "$(dirname "${SCRIPT_SOURCE}")" && pwd)"
WRUN="${SCRIPT_DIR}/wrun.sh"
USER_BIN="${HOME}/.local/bin"

if [ ! -f "${WRUN}" ]; then
    return 0 2>/dev/null || exit 0
fi

case ":${PATH:-}:" in
    *":${USER_BIN}:"*) ;;
    *) export PATH="${USER_BIN}${PATH:+:${PATH}}" ;;
esac

wrun() { bash "${WRUN}" "$@"; }
python() { bash "${WRUN}" python "$@"; }
pip() { bash "${WRUN}" python -m pip "$@"; }
pytest() { bash "${WRUN}" pytest "$@"; }
node() { bash "${WRUN}" node "$@"; }
npm() { bash "${WRUN}" npm "$@"; }
npx() { bash "${WRUN}" npx "$@"; }
java() { bash "${WRUN}" java "$@"; }
javac() { bash "${WRUN}" javac "$@"; }
dotnet() { bash "${WRUN}" dotnet "$@"; }
docker() { bash "${WRUN}" docker "$@"; }
docker-compose() { bash "${WRUN}" docker-compose "$@"; }
gh() { bash "${WRUN}" gh "$@"; }
rtk() { bash "${WRUN}" rtk "$@"; }

if [ "${WR_BRIDGE_QUIET:-0}" != "1" ] && [ "${TERM_PROGRAM:-}" != "vscode" ]; then
    echo "Atalhos WSL carregados para Git Bash. Exemplos: python --version, dotnet --version, docker ps, rtk gain"
fi
