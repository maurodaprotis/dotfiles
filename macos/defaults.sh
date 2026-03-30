#!/bin/bash
# macOS defaults
# Apply preferred system settings. Idempotent — safe to re-run.
# After running, some changes require a logout or restart to take effect.

set -e

echo "── macOS Defaults ──"

# ─── Dock ─────────────────────────────────────────────────────────────

# Auto-hide the Dock
defaults write com.apple.dock autohide -bool true

# Icon size (default: 64)
defaults write com.apple.dock tilesize -int 48

echo "  ✓ Dock"

# ─── Keyboard ─────────────────────────────────────────────────────────

# Fast key repeat rate (default: 6, lower = faster)
defaults write NSGlobalDomain KeyRepeat -int 2

# Short delay before key repeat starts (default: 25, lower = faster)
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable automatic period substitution (double-space → period)
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

echo "  ✓ Keyboard"

# ─── Finder ───────────────────────────────────────────────────────────

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

echo "  ✓ Finder"

# ─── Appearance ───────────────────────────────────────────────────────

# Auto-switch between light and dark mode
defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool true

echo "  ✓ Appearance"

# ─── Screenshots ──────────────────────────────────────────────────────

# Capture window style by default (instead of selection)
defaults write com.apple.screencapture style window

echo "  ✓ Screenshots"

# ─── Apply changes ────────────────────────────────────────────────────

killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

echo "  ✓ Restarted affected processes"
echo ""
