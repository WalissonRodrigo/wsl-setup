#!/usr/bin/env bash
set -euo pipefail

export PATH="${HOME}/.local/bin:${PATH}"

echo "RTK_PATH=$(command -v rtk)"
echo "RTK_VERSION=$(rtk --version)"
echo "RTK_GAIN_START"
rtk gain | sed -n '1,20p'
echo "RTK_GAIN_END"
