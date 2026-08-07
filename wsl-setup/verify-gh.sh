#!/usr/bin/env bash
set -euo pipefail

export PATH="${HOME}/.local/bin:${HOME}/.asdf/bin:${HOME}/.asdf/shims:${PATH}"

if [ -f "${HOME}/.asdf/asdf.sh" ]; then
    # shellcheck disable=SC1091
    . "${HOME}/.asdf/asdf.sh"
fi

gh --version | head -n 1
gh auth status || true
