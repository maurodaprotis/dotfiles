#!/bin/bash
# Dotfiles installer
# - Idempotent: safe to re-run anytime
# - Symlinks .zshrc (backs up existing one first)
# - Symlinks configs so a `git pull` updates everything instantly
# - Copies templates for files with secrets (won't overwrite filled-in versions)

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# ─── Helpers ──────────────────────────────────────────────────────────

symlink() {
  local source="$1"
  local target="$2"
  local target_dir="$(dirname "$target")"

  mkdir -p "$target_dir"

  if [[ -L "$target" ]]; then
    local current=$(readlink "$target")
    if [[ "$current" == "$source" ]]; then
      echo "  ✓ $target (already linked)"
      return
    fi
    rm "$target"
  elif [[ -f "$target" ]]; then
    mv "$target" "$target.backup.$(date +%Y%m%d%H%M%S)"
    echo "  ⚠ backed up existing $target"
  fi

  ln -s "$source" "$target"
  echo "  → $target"
}

copy_template() {
  local source="$1"
  local target="$2"

  mkdir -p "$(dirname "$target")"

  if [[ -f "$target" ]]; then
    echo "  ✓ $target (already exists, not overwriting)"
    return
  fi

  cp "$source" "$target"
  echo "  📋 $target (copied template — fill in your tokens)"
}

echo "╔══════════════════════════════════════╗"
echo "║        Dotfiles Installer            ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "Source: $DOTFILES_DIR"
echo ""

# ─── 0. Packages ─────────────────────────────────────────────────────
echo "── Packages ──"
if [[ "$(uname)" == "Darwin" ]]; then
  if ! command -v brew >/dev/null && [[ ! -x /opt/homebrew/bin/brew ]]; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  eval "$(/opt/homebrew/bin/brew shellenv)"
  brew bundle --file="$DOTFILES_DIR/Brewfile"
else
  sudo apt-get update -qq
  sudo apt-get install -y zsh git curl bat eza zsh-autosuggestions neovim gh
  [[ "$(basename "$SHELL")" == "zsh" ]] || sudo chsh -s "$(command -v zsh)" "$USER"
fi

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
fi
echo ""

# ─── 1. ZSH ──────────────────────────────────────────────────────────
echo "── ZSH ──"
symlink "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
echo ""

# ─── 2. Git ──────────────────────────────────────────────────────────
echo "── Git ──"
symlink "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"
symlink "$DOTFILES_DIR/git/ignore" "$HOME/.config/git/ignore"
echo ""

# ─── 3. GitHub CLI ───────────────────────────────────────────────────
echo "── GitHub CLI ──"
symlink "$DOTFILES_DIR/gh/config.yml" "$HOME/.config/gh/config.yml"
echo ""

# ─── 4. Claude Code ─────────────────────────────────────────────────
echo "── Claude Code ──"
symlink "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
echo ""

# ─── 5. Templates (secrets — copy, don't symlink) ───────────────────
echo "── Templates (files with secrets) ──"
copy_template "$DOTFILES_DIR/templates/npmrc.template" "$HOME/.npmrc"
echo ""

# ─── 6. macOS only: SSH, fonts, Cursor MCP, system defaults ─────────
if [[ "$(uname)" == "Darwin" ]]; then
  echo "── macOS ──"
  symlink "$DOTFILES_DIR/ssh/config" "$HOME/.ssh/config"
  copy_template "$DOTFILES_DIR/templates/mcp.json.template" "$HOME/.cursor/mcp.json"
  for font in "$DOTFILES_DIR"/fonts/*.otf; do
    target="$HOME/Library/Fonts/$(basename "$font")"
    [[ -f "$target" ]] || { cp "$font" "$target"; echo "  → $(basename "$font")"; }
  done
  "$DOTFILES_DIR/macos/defaults.sh"
  echo ""
fi

# ─── 7. AI Skills & Agents ──────────────────────────────────────────
echo "── AI Skills & Agents (global) ──"
"$DOTFILES_DIR/ai/setup.sh" --all "$HOME"
symlink "$DOTFILES_DIR/ai/skills-lock.json" "$HOME/.agents/.skill-lock.json"
copy_template "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
symlink "$DOTFILES_DIR/ai/AGENTS.md" "$HOME/.codex/AGENTS.md"
echo ""

# ─── Done ────────────────────────────────────────────────────────────
echo "╔══════════════════════════════════════╗"
echo "║            All done!                 ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "Restart your terminal or run: source ~/.zshrc"
echo ""
echo "To set up AI tools in a project:"
echo "  $DOTFILES_DIR/ai/setup.sh --all /path/to/project"
