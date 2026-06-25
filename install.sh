#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Alex's dotfiles installer
#
# Idempotent — safe to re-run. Backs up anything it displaces.
# Run on a fresh Mac or to migrate from an existing setup.
# =============================================================================

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles.bak/$(date +%Y%m%d-%H%M%S)"
BACKED_UP=false

info()  { printf "\033[1;34m==> %s\033[0m\n" "$1"; }
warn()  { printf "\033[1;33m==> WARNING: %s\033[0m\n" "$1"; }
error() { printf "\033[1;31m==> ERROR: %s\033[0m\n" "$1"; }

# Ask before a curl-based one-off install. Defaults to NO — including
# non-interactive / no-TTY runs (so unattended runs skip these installs).
confirm() {
  local reply
  [[ -t 0 ]] || return 1
  read -rp "$(printf '\033[1;33m==> %s [y/N] \033[0m' "$1")" reply || return 1
  [[ "$reply" == [Yy]* ]]
}

# --- Helpers -----------------------------------------------------------------

backup_and_link() {
  local src="$1"   # absolute path to file in repo
  local dest="$2"  # absolute path in $HOME

  # Already correct?
  if [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "$src" ]]; then
    return 0
  fi

  # Back up anything at the destination
  if [[ -e "$dest" ]] || [[ -L "$dest" ]]; then
    local rel="${dest#$HOME/}"
    local backup_path="$BACKUP_DIR/$rel"
    mkdir -p "$(dirname "$backup_path")"
    mv "$dest" "$backup_path"
    echo "  Backed up: ~/$rel"
    BACKED_UP=true
  fi

  # Create parent dir if needed
  mkdir -p "$(dirname "$dest")"
  ln -sf "$src" "$dest"
  echo "  Linked: ~/${dest#$HOME/} -> ${src#$REPO_DIR/}"
}

remove_orphan() {
  local path="$1"
  if [[ -e "$path" ]] || [[ -L "$path" ]]; then
    local rel="${path#$HOME/}"
    local backup_path="$BACKUP_DIR/$rel"
    mkdir -p "$(dirname "$backup_path")"
    mv "$path" "$backup_path"
    echo "  Removed orphan: ~/$rel (backed up)"
    BACKED_UP=true
  fi
}

# --- Step 1: Sanity check ---------------------------------------------------

info "Checking environment..."
MACOS_VERSION=$(sw_vers -productVersion)
MACOS_MAJOR=$(echo "$MACOS_VERSION" | cut -d. -f1)
echo "  macOS: $MACOS_VERSION"

if (( MACOS_MAJOR < 14 )); then
  warn "macOS < 14 detected. Ghostty install will be skipped (requires macOS 14+)."
  warn "After upgrading macOS, re-run this script to complete setup."
  SKIP_GHOSTTY=true
else
  SKIP_GHOSTTY=false
fi

# Xcode Command Line Tools (required by Homebrew for compiling packages)
if ! xcode-select -p &>/dev/null; then
  info "Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "  Waiting for installation to complete..."
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
  echo "  Xcode CLT installed."
else
  echo "  Xcode CLT found at $(xcode-select -p)"
fi

# --- Step 2: Homebrew --------------------------------------------------------

info "Ensuring Homebrew..."
if ! command -v brew &>/dev/null; then
  if confirm "Homebrew not found. Install it?"; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    warn "Skipping Homebrew — brew-dependent steps will be skipped."
  fi
else
  echo "  Homebrew found at $(command -v brew)"
fi

# --- Step 3: Brew bundle ----------------------------------------------------

info "Installing packages from Brewfile..."
if command -v brew &>/dev/null; then
  if [[ "$SKIP_GHOSTTY" == true ]]; then
    # Filter out ghostty from Brewfile for this run
    grep -v 'cask "ghostty"' "$REPO_DIR/Brewfile" | brew bundle install --file=- || true
  else
    brew bundle install --file="$REPO_DIR/Brewfile" || true
  fi
else
  warn "Skipping Brewfile — Homebrew not installed."
fi

# --- Step 4: Starship --------------------------------------------------------

info "Installing/updating starship..."
if command -v starship &>/dev/null; then
  "$REPO_DIR/scripts/install-starship.sh"
elif confirm "Install starship prompt?"; then
  "$REPO_DIR/scripts/install-starship.sh"
else
  echo "  Skipped starship."
fi

# --- Step 5: Claude Code -----------------------------------------------------

info "Ensuring Claude Code (standalone native build)..."
if [[ -x "$HOME/.local/bin/claude" ]]; then
  echo "  Claude Code found: $("$HOME/.local/bin/claude" --version 2>/dev/null || echo 'present')"
elif confirm "Install standalone Claude Code?"; then
  curl -fsSL https://claude.ai/install.sh | bash
else
  echo "  Skipped Claude Code."
fi

# --- Step 6: Symlinks --------------------------------------------------------

info "Linking dotfiles..."

# Individual files in $HOME root
backup_and_link "$REPO_DIR/home/.zshenv"     "$HOME/.zshenv"
backup_and_link "$REPO_DIR/home/.gitconfig"  "$HOME/.gitconfig"
backup_and_link "$REPO_DIR/home/.ideavimrc"  "$HOME/.ideavimrc"

# Directories (symlink the whole dir)
backup_and_link "$REPO_DIR/home/.config/zsh"     "$HOME/.config/zsh"
backup_and_link "$REPO_DIR/home/.config/nvim"    "$HOME/.config/nvim"
backup_and_link "$REPO_DIR/home/.config/ghostty" "$HOME/.config/ghostty"

# Individual files inside .config
backup_and_link "$REPO_DIR/home/.config/starship.toml" "$HOME/.config/starship.toml"
backup_and_link "$REPO_DIR/home/.config/git/ignore"    "$HOME/.config/git/ignore"

# bin/ scripts (individual files, not the whole dir)
mkdir -p "$HOME/bin"
backup_and_link "$REPO_DIR/bin/aws-keys-rotate.sh" "$HOME/bin/aws-keys-rotate.sh"

# --- Step 7: Orphan cleanup --------------------------------------------------

info "Cleaning up known orphans..."
remove_orphan "$HOME/.zshrc"
remove_orphan "$HOME/.zprofile"
remove_orphan "$HOME/.bashrc"
remove_orphan "$HOME/.bash_profile"
remove_orphan "$HOME/.config/alacritty/alacritty.toml"
remove_orphan "$HOME/bin/claudew"

# --- Step 8: Antidote plugins ------------------------------------------------

info "Compiling antidote plugins..."
ANTIDOTE_ZSH="/opt/homebrew/opt/antidote/share/antidote/antidote.zsh"
if [[ -f "$ANTIDOTE_ZSH" ]]; then
  export ZDOTDIR="$HOME/.config/zsh"
  zsh -c "source '$ANTIDOTE_ZSH' && antidote load" 2>/dev/null || true
  echo "  Antidote plugins compiled."
else
  warn "antidote not found — plugins will be compiled on first shell launch."
fi

# --- Step 9: Generate cleanup script -----------------------------------------

if [[ "$BACKED_UP" == true ]]; then
  cat > "$BACKUP_DIR/cleanup.sh" << 'CLEANUP_EOF'
#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "About to delete: $DIR"
echo "Contents:"
find "$DIR" -type f -o -type l | grep -v cleanup.sh | head -100
read -rp "Delete? (y/N) " yn
case "$yn" in
  y|Y) rm -rf "$DIR" && echo "Deleted." ;;
  *) echo "Cancelled." ;;
esac
CLEANUP_EOF
  chmod +x "$BACKUP_DIR/cleanup.sh"
fi

# --- Done --------------------------------------------------------------------

echo ""
info "Done! Restart your terminal to pick up changes."
echo ""
echo "  Next steps:"
echo "  1. Open a new terminal — your new prompt, aliases, and plugins should load."
echo "  2. Run ',h' to see your git command reference."
if [[ "$SKIP_GHOSTTY" == true ]]; then
  echo "  3. After upgrading macOS, re-run install.sh to install Ghostty."
fi
echo ""
echo "  Work-specific setup (Java/jenv/Maven/localstack, plus per-repo .java-version):"
echo "    $REPO_DIR/scripts/setup-work.sh"
echo ""
if [[ "$BACKED_UP" == true ]]; then
  echo "  Backed-up files: $BACKUP_DIR"
  echo "  When confident, clean up: $BACKUP_DIR/cleanup.sh"
fi
