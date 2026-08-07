#!/usr/bin/env bash
set -euo pipefail

echo "PWD=$(pwd)"
echo "PYTHON=$(python --version 2>&1)"
echo "DOTNET=$(dotnet --version 2>&1)"
echo "RTK=$(rtk --version 2>&1)"
