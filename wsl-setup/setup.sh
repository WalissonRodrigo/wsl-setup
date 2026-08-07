#!/usr/bin/env bash
set -euo pipefail

ASDF_VERSION="${ASDF_VERSION:-v0.14.1}"
RTK_INSTALL_SCRIPT_URL="${RTK_INSTALL_SCRIPT_URL:-https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh}"
GH_INSTALL_BASE_URL="${GH_INSTALL_BASE_URL:-https://github.com/cli/cli/releases/download}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_CONFIG_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
TOOL_VERSIONS_FILE="${WORKSPACE_CONFIG_DIR}/.tool-versions"
ASDF_DIR="${HOME}/.asdf"
BASHRC_FILE="${HOME}/.bashrc"

log() {
    printf '\n[%s] %s\n' "setup" "$1"
}

append_if_missing() {
    local line="$1"
    local file="$2"

    if ! grep -Fqx "$line" "$file" 2>/dev/null; then
        printf '%s\n' "$line" >> "$file"
    fi
}

install_system_packages() {
    log "Atualizando pacotes do sistema"
    sudo apt update
    sudo apt upgrade -y

    log "Instalando dependencias base e utilitarios de desenvolvimento"
    sudo apt install -y \
        apt-transport-https \
        build-essential \
        ca-certificates \
        curl \
        dirmngr \
        fd-find \
        git \
        gnupg \
        jq \
        libicu-dev \
        libbz2-dev \
        libffi-dev \
        liblzma-dev \
        libncursesw5-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        libxml2-dev \
        libxmlsec1-dev \
        llvm \
        pipx \
        ripgrep \
        shellcheck \
        shfmt \
        tk-dev \
        unzip \
        xz-utils \
        zip \
        zlib1g-dev
}

install_asdf() {
    log "Garantindo instalacao do ASDF"

    if [ ! -d "${ASDF_DIR}" ]; then
        git clone https://github.com/asdf-vm/asdf.git "${ASDF_DIR}" --branch "${ASDF_VERSION}"
    else
        log "ASDF ja esta instalado em ${ASDF_DIR}"
    fi

    append_if_missing '. "$HOME/.asdf/asdf.sh"' "${BASHRC_FILE}"
    append_if_missing '. "$HOME/.asdf/completions/asdf.bash"' "${BASHRC_FILE}"
    append_if_missing '[ -f "$HOME/.asdf/plugins/dotnet/set-dotnet-home.bash" ] && . "$HOME/.asdf/plugins/dotnet/set-dotnet-home.bash"' "${BASHRC_FILE}"
    append_if_missing 'export PATH="$HOME/.local/bin:$PATH"' "${BASHRC_FILE}"

    # shellcheck disable=SC1091
    . "${ASDF_DIR}/asdf.sh"
    if [ -f "${ASDF_DIR}/completions/asdf.bash" ]; then
        # shellcheck disable=SC1091
        . "${ASDF_DIR}/completions/asdf.bash"
    fi
}

ensure_asdf_plugin() {
    local plugin_name="$1"
    local plugin_url="$2"

    if ! asdf plugin list | grep -Fxq "${plugin_name}"; then
        asdf plugin add "${plugin_name}" "${plugin_url}"
    fi
}

install_asdf_plugins() {
    log "Configurando plugins ASDF"

    ensure_asdf_plugin "python" "https://github.com/asdf-community/asdf-python.git"
    ensure_asdf_plugin "nodejs" "https://github.com/asdf-vm/asdf-nodejs.git"
    ensure_asdf_plugin "java" "https://github.com/halcyon/asdf-java.git"
    ensure_asdf_plugin "dotnet" "https://github.com/emersonsoares/asdf-dotnet-core.git"

    if [ -f "${ASDF_DIR}/plugins/nodejs/bin/import-release-team-keyring" ]; then
        bash "${ASDF_DIR}/plugins/nodejs/bin/import-release-team-keyring"
    fi
}

install_tool_versions() {
    log "Instalando ferramentas declaradas em ${TOOL_VERSIONS_FILE}"

    if [ ! -f "${TOOL_VERSIONS_FILE}" ]; then
        printf 'Arquivo nao encontrado: %s\n' "${TOOL_VERSIONS_FILE}" >&2
        exit 1
    fi

    cp "${TOOL_VERSIONS_FILE}" "${HOME}/.tool-versions"

    (
        cd "${HOME}"
        asdf install
    )

    log "Atualizando shims do ASDF"
    asdf reshim
}

install_python_clis() {
    log "Instalando CLIs Python auxiliares"

    python -m pip install --upgrade pip
    pipx ensurepath

    if ! pipx list 2>/dev/null | grep -Fq 'package localstack'; then
        pipx install localstack
    else
        log "LocalStack CLI ja esta instalado via pipx"
    fi
}

install_rtk() {
    log "Instalando RTK no WSL"

    export PATH="${HOME}/.local/bin:${PATH}"

    if command -v rtk >/dev/null 2>&1; then
        if rtk gain >/dev/null 2>&1; then
            log "RTK correto ja esta instalado em $(command -v rtk)"
            return
        fi

        printf 'Foi encontrado um binario chamado rtk, mas nao parece ser o RTK Token Killer.\n' >&2
        printf 'Remova o binario incorreto e execute novamente o setup.\n' >&2
        exit 1
    fi

    curl -fsSL "${RTK_INSTALL_SCRIPT_URL}" | sh

    if ! command -v rtk >/dev/null 2>&1; then
        printf 'RTK foi instalado, mas nao entrou no PATH atual.\n' >&2
        exit 1
    fi

    if ! rtk gain >/dev/null 2>&1; then
        printf 'RTK instalado, mas a validacao `rtk gain` falhou.\n' >&2
        exit 1
    fi
}

install_github_cli() {
    log "Instalando GitHub CLI no WSL"

    local gh_version
    local gh_version_number
    local archive_name
    local download_url
    local tmp_dir

    if command -v gh >/dev/null 2>&1; then
        log "GitHub CLI ja esta instalado em $(command -v gh)"
        return
    fi

    gh_version="$(curl -fsSL https://api.github.com/repos/cli/cli/releases/latest | jq -r '.tag_name')"
    gh_version_number="${gh_version#v}"
    archive_name="gh_${gh_version_number}_linux_amd64.tar.gz"
    download_url="${GH_INSTALL_BASE_URL}/${gh_version}/${archive_name}"
    tmp_dir="$(mktemp -d)"

    curl -fsSL "${download_url}" -o "${tmp_dir}/${archive_name}"
    tar -xzf "${tmp_dir}/${archive_name}" -C "${tmp_dir}"
    install -m 0755 "${tmp_dir}/gh_${gh_version_number}_linux_amd64/bin/gh" "${HOME}/.local/bin/gh"
    rm -rf "${tmp_dir}"

    if ! command -v gh >/dev/null 2>&1; then
        printf 'GitHub CLI foi instalado, mas nao entrou no PATH atual.\n' >&2
        exit 1
    fi
}

show_versions() {
    log "Resumo do ambiente"
    asdf current || true
    printf 'python: '
    python --version
    printf 'node: '
    node --version
    printf 'java: '
    java --version | head -n 1
    printf '.NET SDK: '
    dotnet --version
    printf 'rtk: '
    rtk --version
    printf 'gh: '
    gh --version | head -n 1
    printf 'localstack: '
    localstack --version
}

validate_dotnet() {
    log "Validando instalacao do .NET"

    local default_dotnet_version
    local installed_sdks
    local validation_root

    if [ -f "${ASDF_DIR}/plugins/dotnet/set-dotnet-home.bash" ]; then
        # shellcheck disable=SC1091
        . "${ASDF_DIR}/plugins/dotnet/set-dotnet-home.bash"
        asdf_update_dotnet_home
    fi

    default_dotnet_version="$(dotnet --version)"
    installed_sdks="$(dotnet --list-sdks)"

    printf '.NET default: %s\n' "${default_dotnet_version}"
    printf '.NET SDKs:\n%s\n' "${installed_sdks}"

    if [ "${default_dotnet_version}" != "10.0.301" ]; then
        printf 'Versao default esperada do .NET: 10.0.301. Atual: %s\n' "${default_dotnet_version}" >&2
        exit 1
    fi

    validation_root="$(mktemp -d)"

    printf 'dotnet 8.0.302\n' > "${validation_root}/.tool-versions"
    (
        cd "${validation_root}"
        if [ -f "${ASDF_DIR}/plugins/dotnet/set-dotnet-home.bash" ]; then
            asdf_update_dotnet_home
        fi
        [ "$(dotnet --version)" = "8.0.302" ]
        dotnet new console -n net8-check -f net8.0 >/dev/null
        dotnet build net8-check >/dev/null
    )

    printf 'dotnet 10.0.301\n' > "${validation_root}/.tool-versions"
    (
        cd "${validation_root}"
        if [ -f "${ASDF_DIR}/plugins/dotnet/set-dotnet-home.bash" ]; then
            asdf_update_dotnet_home
        fi
        [ "$(dotnet --version)" = "10.0.301" ]
        dotnet new console -n net10-check -f net10.0 >/dev/null
        dotnet build net10-check >/dev/null
    )

    rm -rf "${validation_root}"
}

main() {
    log "Iniciando setup do ambiente WSL para o repositorio wsl-setup"
    install_system_packages
    install_asdf
    install_asdf_plugins
    install_tool_versions
    install_python_clis
    install_rtk
    install_github_cli
    show_versions
    validate_dotnet

    printf '\n[setup] Concluido. Reabra o terminal ou execute: source "%s"\n' "${BASHRC_FILE}"
}

main "$@"
