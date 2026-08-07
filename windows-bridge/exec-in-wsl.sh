#!/usr/bin/env bash
set -euo pipefail

export PATH="${HOME}/.local/bin:${HOME}/.asdf/bin:${HOME}/.asdf/shims:${PATH}"

if [ -f "${HOME}/.asdf/asdf.sh" ]; then
    # shellcheck disable=SC1091
    . "${HOME}/.asdf/asdf.sh"
fi

if [ -f "${HOME}/.asdf/plugins/dotnet/set-dotnet-home.bash" ]; then
    # shellcheck disable=SC1091
    . "${HOME}/.asdf/plugins/dotnet/set-dotnet-home.bash"
    if command -v asdf_update_dotnet_home >/dev/null 2>&1; then
        asdf_update_dotnet_home
    fi
fi

exec "$@"
