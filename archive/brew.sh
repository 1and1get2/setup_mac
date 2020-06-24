#!/bin/sh
# [ "$(whoami)" != "root" ] && echo please use root &&  exec sudo -- "$0" "$@"

# if [ "root" != "$USER" ]; then
# 	echo please use root
# 	exec sudo -- "$0" "$@"
#  	exit
# fi


# script absolute path
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
echo $SCRIPTPATH

# disable gatekeeper
sudo spctl --master-disable

# CMD + SHIFT + .
defaults write com.apple.finder AppleShowAllFiles YES

# loose concurrent open file limitation on mac
# ulimit -S -n 3000

chmod a+x ./install_xcode_commandline.sh
exec sudo ./install_xcode_commandline.sh

alias brewup='brew update; brew upgrade; brew prune; brew cleanup; brew doctor'

if ! type brew > /dev/null; then
	# install brew
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

brew tap Homebrew/bundle

#backup current brew installs
brew bundle dump --describe --file=./dump.list

brew bundle install --file=./brew.list

brewup

mkdir -p ~/.config

# where I keep some binary command
mkdir -p ~/bin

touch ~/.bash_profile

cp ./envir.sh ~/.config/envir.sh
touch ~/.config/envir.sh

chmod a+x ~/.bash_profile
chmod a+x ~/.config/envir.sh


cat <<EOT >> ~/.bash_profile
if [ -f ~/.config/envir.sh ]; then
  source ~/.config/envir.sh
fi
EOT

source ~/.config/envir.sh

sdkmanager --update







# ln -s  /Volumes/Persistence/Data/Data/.android  /Users/derek/.android