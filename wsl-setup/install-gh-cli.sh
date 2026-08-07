#!/usr/bin/env bash
set -euo pipefail

GH_INSTALL_BASE_URL="${GH_INSTALL_BASE_URL:-https://github.com/cli/cli/releases/download}"

export PATH="${HOME}/.local/bin:${PATH}"

gh_version="$(curl -fsSL https://api.github.com/repos/cli/cli/releases/latest | jq -r '.tag_name')"
gh_version_number="${gh_version#v}"
archive_name="gh_${gh_version_number}_linux_amd64.tar.gz"
download_url="${GH_INSTALL_BASE_URL}/${gh_version}/${archive_name}"
tmp_dir="$(mktemp -d)"

cleanup() {
    rm -rf "${tmp_dir}"
}

trap cleanup EXIT

curl -fsSL "${download_url}" -o "${tmp_dir}/${archive_name}"
tar -xzf "${tmp_dir}/${archive_name}" -C "${tmp_dir}"
install -m 0755 "${tmp_dir}/gh_${gh_version_number}_linux_amd64/bin/gh" "${HOME}/.local/bin/gh"

gh --version | head -n 1
