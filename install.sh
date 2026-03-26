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
copy_template "$DOTFILES_DIR/templates/mcp.json.template" "$HOME/.cursor/mcp.json"
echo ""

# ─── 6. AI Skills & Agents ──────────────────────────────────────────
echo "── AI Skills & Agents (global) ──"
"$DOTFILES_DIR/ai/setup.sh" --all "$HOME"
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
