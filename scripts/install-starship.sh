#!/usr/bin/env bash
set -euo pipefail

# Install or update starship via the official installer.
# This avoids Homebrew's source-build of cmake on older macOS.

if command -v starship &>/dev/null; then
  CURRENT=$(starship --version | head -1 | awk '{print $2}')
  echo "Starship already installed (version $CURRENT). Updating..."
fi

curl -sS https://starship.rs/install.sh | sh -s -- --yes

echo "Starship installed at: $(command -v starship)"
starship --version | head -1
