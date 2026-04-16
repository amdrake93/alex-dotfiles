#!/usr/bin/env bash
# -u omitted because jenv's export plugin references PROMPT_COMMAND,
# which isn't always set in non-interactive shells.
set -eo pipefail

# =============================================================================
# Work bootstrap — Java toolchain, jenv, per-repo .java-version.
# Idempotent. Run after install.sh when setting up a machine for Cloud Campaign.
# =============================================================================

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

info() { printf "\033[1;34m==> %s\033[0m\n" "$1"; }
warn() { printf "\033[1;33m==> WARNING: %s\033[0m\n" "$1"; }

# --- Step 1: Brewfile.work ---------------------------------------------------

info "Installing work tools (Java, jenv, maven, localstack)..."
brew bundle install --no-upgrade --file="$REPO_DIR/Brewfile.work" || \
  warn "Brewfile.work had failures — continuing. JDK casks may need manual install (they require sudo)."

# --- Step 2: jenv init in this shell ----------------------------------------

if ! command -v jenv &>/dev/null && [[ -d "$HOME/.jenv/bin" ]]; then
  export PATH="$HOME/.jenv/bin:$PATH"
fi

if ! command -v jenv &>/dev/null; then
  warn "jenv not found on PATH. Ensure Brewfile.work installed cleanly, then re-run."
  exit 1
fi

eval "$(jenv init -)"

info "Enabling jenv export plugin (auto-sets JAVA_HOME)..."
jenv enable-plugin export >/dev/null

# --- Step 3: Register installed JDKs ----------------------------------------

info "Registering installed JDKs with jenv..."
found_any=false
for dir in \
    /Library/Java/JavaVirtualMachines/*/Contents/Home \
    "$HOME"/Library/Java/JavaVirtualMachines/*/Contents/Home; do
  [[ -d "$dir" ]] || continue
  jenv add "$dir" 2>&1 | sed 's/^/  /'
  found_any=true
done

if [[ "$found_any" == false ]]; then
  warn "No JDKs found at standard paths. Install Java first (Brewfile.work casks)."
fi

# --- Step 4: Global default --------------------------------------------------

info "Setting jenv global default..."
versions=$(jenv versions --bare)
if echo "$versions" | grep -qx "1.8"; then
  jenv global 1.8
  echo "  jenv global: 1.8"
elif echo "$versions" | grep -qx "17"; then
  jenv global 17
  warn "1.8 not installed — fell back to 17 as global. Update when 1.8 is available."
else
  warn "No registered JDK versions. Skipping global default."
fi

# --- Step 5: Per-repo .java-version auto-detection --------------------------

detect_java_version() {
  local repo="$1"
  local ver=""

  if [[ -f "$repo/pom.xml" ]]; then
    ver=$(grep -oE '<(maven\.compiler\.(source|target)|java\.version)>[^<]+' "$repo/pom.xml" 2>/dev/null \
      | head -1 | grep -oE '[0-9.]+$' || true)
  fi
  if [[ -z "$ver" ]]; then
    for ci_file in "$repo/Dockerfile" "$repo/bitbucket-pipelines.yml"; do
      [[ -f "$ci_file" ]] || continue
      ver=$(grep -oE '(jdk|corretto|zulu|openjdk)[:-][0-9]+' "$ci_file" \
        | head -1 | grep -oE '[0-9]+$' || true)
      [[ -n "$ver" ]] && break
    done
  fi
  # jenv convention: Java 8 is "1.8", Java 9+ is the major number
  [[ "$ver" == "8" ]] && ver="1.8"
  echo "$ver"
}

info "Auto-detecting .java-version for Cloud Campaign repos..."
for repo in "$HOME"/repos/cloud-campaign-*/; do
  repo="${repo%/}"
  [[ -d "$repo" ]] || continue
  [[ -f "$repo/.java-version" ]] && continue

  ver=$(detect_java_version "$repo")
  if [[ -n "$ver" ]]; then
    echo "$ver" > "$repo/.java-version"
    echo "  $(basename "$repo"): .java-version = $ver"
  fi
done

echo ""
info "Work setup complete. Open a fresh shell and verify with 'java -version' in a CC repo."
