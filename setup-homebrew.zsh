#!/usr/bin/env zsh

echo "\n🍺 Starting Homebrew Setup \n"

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install bat
brew install gnupg
brew install nvm
brew install pyenv

brew install --cask iterm2
brew install --cask visual-studio-code
brew install --cask brave-browser
brew install --cask insomnia