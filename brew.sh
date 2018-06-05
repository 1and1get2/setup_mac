/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

alias brewup='brew update; brew upgrade; brew prune; brew cleanup; brew doctor'

brew install wget htop nmap  bash-completion watch
Brew install tree cask git
brew cask search chrome
brew cask install google-chrome-beta android-file-transfer sublime-text-dev
brew cask search sublime

brew cask install intellij-idea 

# android-studio
brew cask install java android-studio-preview atom-beta visual-studio-code-insiders


brew cask install charles
brew cask install iterm2

# https://tomlankhorst.nl/brew-bundle-restore-backup/
brew tap Homebrew/bundle
brew bundle dump


# entertainment
brew cask install qq
brew cask install ieasemusic
brew cask install spotify

# tools
brew cask install cakebrew

sudo spctl --master-disable

defaults write com.apple.finder AppleShowAllFiles YES

# CMD + SHIFT + .

cask install sourcetree