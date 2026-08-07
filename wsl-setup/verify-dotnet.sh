#!/usr/bin/env bash
set -euo pipefail

ASDF_DIR="${HOME}/.asdf"

export PATH="${ASDF_DIR}/bin:${ASDF_DIR}/shims:${PATH}"

# shellcheck disable=SC1091
. "${ASDF_DIR}/asdf.sh"

if [ -f "${ASDF_DIR}/plugins/dotnet/set-dotnet-home.bash" ]; then
    # shellcheck disable=SC1091
    . "${ASDF_DIR}/plugins/dotnet/set-dotnet-home.bash"
fi

if command -v asdf_update_dotnet_home >/dev/null 2>&1; then
    asdf_update_dotnet_home
fi

echo "DEFAULT_DOTNET=$(dotnet --version)"
echo "DEFAULT_CURRENT=$(asdf current dotnet)"
echo "DEFAULT_SDKS_START"
dotnet --list-sdks
echo "DEFAULT_SDKS_END"

validation_root="$(mktemp -d)"
trap 'rm -rf "${validation_root}"' EXIT

printf 'dotnet 8.0.302\n' > "${validation_root}/.tool-versions"
(
    cd "${validation_root}"
    if command -v asdf_update_dotnet_home >/dev/null 2>&1; then
        asdf_update_dotnet_home
    fi
    echo "NET8_DOTNET=$(dotnet --version)"
    rm -rf net8-check
    dotnet new console -n net8-check -f net8.0 >/dev/null
    dotnet build net8-check >/dev/null
    echo "NET8_BUILD=OK"
)

printf 'dotnet 10.0.301\n' > "${validation_root}/.tool-versions"
(
    cd "${validation_root}"
    if command -v asdf_update_dotnet_home >/dev/null 2>&1; then
        asdf_update_dotnet_home
    fi
    echo "NET10_DOTNET=$(dotnet --version)"
    rm -rf net10-check
    dotnet new console -n net10-check -f net10.0 >/dev/null
    dotnet build net10-check >/dev/null
    echo "NET10_BUILD=OK"
)
