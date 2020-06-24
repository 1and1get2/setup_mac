#!/bin/bash

# you can run this script by execution the following command:
# bash -c "$(wget -O- https://raw.githubusercontent.com/hereisderek/setup_mac/master/setup.sh)"

set -e

ENV_FOLDER=/tmp/env
#DEBUG
ORIGINAL_PROFILE=${ENV_FOLDER}/config.sh 
#ORIGINAL_PROFILE=~/.zshrc


RAW_GIT_URL=${RAW_GIT_URL:-"https://raw.githubusercontent.com/hereisderek/setup_mac/master"}
ENV_FOLDER=${ENV_FOLDER:-~/.config/env}
ENV_FILE=$ENV_FOLDER/env.env
ENV_DIRS_FOLDER=${ENV_DIRS_FOLDER:-"${ENV_FOLDER}/env.d"}
BIN_FOLDER=${BIN_FOLDER:-"$ENV_FOLDER/bin"}



################################################
#	helper methods
################################################


# prompt for confirmation with prompt: $1 and default: $2
# $1: prompt message
# $2: default value
# e.g.: `confirmYesOrNo "hello?" && echo hi`
confirmYesOrNo() {
    local defaultValue=${2:-N}
    read -r -p "${1:-Are you sure?} [y/N] [${defaultValue}]:" response
    case "${response:-$defaultValue}" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}


# prompt for user's input with prompt: $1 and default: $2
# e.g. `echo "$(confirmInput prompt default)"`
confirmInput() {
    read -r -p "${1:-Input} [$2]:" response
    echo "${response:-$2}"
}

installBrewFromList() {
	[ -z "$1" ] && return
	echo "installing brew from list:$1"
	# curl $1 | brew bundle --file=-
}

# url=${RAW_GIT_URL}/brew.d/$1
installBrewByFileName() {
	[ -z "$1" ] && return
	local list=${RAW_GIT_URL}/brew.d/$1
	installBrewFromList $list
}




################################################
#	functions
################################################ for file in ${ENV_DIRS_FOLDER}/{..?,.[!.],}*; do echo "\$file"; done

################################################
setUpEnvir() {
	mkdir -p ${ENV_DIRS_FOLDER} $ENV_FOLDER $BIN_FOLDER
	touch ${ENV_FILE}

	cat >$ENV_FILE<<EOF
#!/bin/zsh
# user path folder

echo "$SHELL"

if [[ -d "$BIN_FOLDER" ]]; then
	export PATH="\$PATH:$BIN_FOLDER"
fi



for config_file ($ENV_DIRS_FOLDER/*.env); do
	echo \$config_file
done



function forceAllowApp {
	sudo xattr -rd com.apple.quarantine $@
}

function adbForceInstall {
	adb install -f -r -t $@ 
}

function forceSignApp {
	codesign --force --deep --sign - $@
}

EOF

	 printf "\n\nsource ${ENV_FOLDER}/env.env">>$ORIGINAL_PROFILE
}

################################################
updatePrimaryHostName() {
	[ -z "$1" ] && return
	echo "updating updatePrimaryHostName:$1"
	sudo scutil --set HostName $1
}

# not working
updateBonjourHostName() {
	[ -z "$1" ] && return
	echo "updating updateBonjourHostName:$1"
	sudo scutil --set LocalHostName $1
}

updateComputerName() {
	[ -z "$1" ] && return
	echo "updating updateComputerName:$1"
	sudo scutil --set ComputerName $1
}


# update host name
updateHostName() {
	if ! $(confirmYesOrNo 'Do you want to update hostname?' 'N'); then
		echo "updateHostName skipped"
		return 0
	fi

	local _hostname=$(confirmInput "please input new hostname" "`hostname`")
	
	confirmYesOrNo "updatePrimaryHostName to _hostname$" "y" && updatePrimaryHostName $_hostname
	confirmYesOrNo "updateBonjourHostName to _hostname$" "y" && updateBonjourHostName $_hostname
	confirmYesOrNo "updateComputerName to _hostname$" "y" && updateComputerName $_hostname
	echo "updateHostName finished"
	dscacheutil -flushcache
	return 
}



################################################
genSSHKey() {
	if ! $(confirmYesOrNo 'Do you want to generate ssh key?' 'Y'); then
		echo "genSSHKey skipped"
		return 0
	fi
	local keyName=$(confirmInput "ssh key name" "`hostname`")
	cat /dev/zero | ssh-keygen -q -N "" -C "${keyName}" > /dev/null
	
	echo "pub key has been copied to the clip board"
	cat ~/.ssh/id_rsa.pub | tee /dev/tty | pbcopy
	#pbpaste
}

################################################ xcode
installJava() {
	installBrewByFileName "java.list"
	cat >${ENV_DIRS_FOLDER}/java.env<<EOF
export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
EOF
}

# https://gist.github.com/patrickhammond/4ddbe49a67e5eb1b9c03
# sdkmanager --update
installAndroidSDK() {
	# export PATH=$ANDROID_HOME/build-tools/$(ls $ANDROID_HOME/build-tools | sort | tail -1):$PATH
	installJava
	installBrewByFileName "android.list"

	cat >${ENV_DIRS_FOLDER}/android.env<<EOF
# export ANT_HOME=/usr/local/opt/ant
export MAVEN_HOME=/usr/local/opt/maven
export GRADLE_HOME=/usr/local/opt/gradle
# export ANDROID_HOME=/usr/local/opt/android-sdk
# export ANDROID_NDK_HOME=/usr/local/opt/android-ndk
echo "android done"
EOF


}



################################################ xcode


################################################
installBrewCommand() {
	# install brew
	if ! type brew > /dev/null; then
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
	else
		echo "brew has been installed, skipping installation"
	fi
	
	
	brew bundle --file=- <<-EOS
		tap 'Homebrew/bundle'
	EOS
}

installBrewMinCommand() {
	# git curl wget
	brew bundle --file=- <<-EOS
		brew 'git'
		brew 'git-extras'
		brew 'curl'
		brew 'wget'
	EOS
	# vim's dependencies python 3.8 cannot be compiled hence, installed on mac os 10.16(11.0)
}

installBrewFromCommonList() {
	installBrewByFileName "common.list"
}

installBrew() {
	installBrewCommand
	installBrewCommonCommand
}

################################################
showHiddenFiles() {
	local current=$(defaults write com.apple.finder AppleShowAllFiles -bool)
	echo "current:$current"
	# defaults write com.apple.finder AppleShowAllFiles -bool true
	# killall Finder
}


hideHiddenFiles() {
	defaults write com.apple.finder AppleShowAllFiles -bool false
	killall Finder
}


################################################
installBrewZsh() {
	if ! type brew > /dev/null; then
		echo "brew is required for installing zsh but it is not installed. skipping"
		return 1
	fi

	echo "system zsh version:`zsh --version` vs brew version: `brew info zsh`"
	if $(confirmYesOrNo 'Do you want to replace default zsh with brew zsh?' 'N'); then
		brew install zsh
	fi
	# https://rick.cogley.info/post/use-homebrew-zsh-instead-of-the-osx-default/
	echo "zsh installed at `which zsh`, version:`zsh --version`"
	brew install zsh-completions
}

installOhMyZsh() {
	if ! type brew > /dev/null; then
		echo "brew is required for installing OhMyZsh but it is not installed. skipping"
		return 1
	fi
	ZSH=~/.config/.oh-my-zsh
	mkdir -p $ZSH

	sh -c "ZSH=$ZSH $(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

################################################
installRClone() {
	curl https://rclone.org/install.sh | sudo bash -s beta
}

################################################

################################################
################################################
################################################

################################################
################################################
################################################

################################################
################################################
################################################




################################################
#	entry:
################################################

setUpEnvir
# updateHostName
# genSSHKey
# installBrew
# showHiddenFiles
# installBrew
# installBrewMinCommand
# installBrewFromCommonList
installAndroidSDK

# installOhMyZsh

source $ENV_FILE
