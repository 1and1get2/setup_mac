#!/bin/sh
# [ "$(whoami)" != "root" ] && echo please use root &&  exec sudo -- "$0" "$@"

if [ "root" != "$USER" ]; then
	echo please use root
	exec sudo -- "$0" "$@"
 	exit
fi


# script absolute path
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
echo $SCRIPTPATH


exit


# loose concurrent open file limitation on mac
# ulimit -S -n 3000

# install brew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

alias brewup='brew update; brew upgrade; brew prune; brew cleanup; brew doctor'

brew tap Homebrew/bundle


brew install wget htop nmap  bash-completion watch
brew install tree cask git
brew cask search chrome
brew cask install google-chrome-beta android-file-transfer sublime-text-dev
brew cask search sublime

brew install mas

brew cask install intellij-idea 

# android-studio
brew cask install java android-studio-preview atom-beta visual-studio-code-insiders


brew cask install charles
brew cask install iterm2

brew tap caskroom/cask
brew cask install google-cloud-sdk

# https://tomlankhorst.nl/brew-bundle-restore-backup/
brew tap Homebrew/bundle
brew bundle dump

brew cask install android-studio intellij-idea 

brew install --HEAD libimobiledevice
brew install ideviceinstaller ios-deploy cocoapods
brew tap dart-lang/dart

brew cask install virtualbox-beta virtualbox-extension-pack-beta

# entertainment
brew cask install qq
brew cask install ieasemusic
brew cask install spotify

# tools
brew cask install cakebrew

sudo spctl --master-disable

defaults write com.apple.finder AppleShowAllFiles YES

# CMD + SHIFT + .

brew cask install sourcetree


# ln -s  /Volumes/Persistence/Data/Data/.android  /Users/derek/.android