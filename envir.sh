
export PATH="/usr/local/sbin:$PATH"


# Load my aliases
if [ -f ~/.config/.aliases ]; then
  . ~/.config/.aliases
fi

# Load my functions
if [ -f ~/.config/.functions ]; then
  . ~/.config/.functions
fi

if [ -d ~/bin ]; then
    export PATH=~/bin:${PATH}
fi


# update brew
alias brewup='brew update; brew upgrade; brew prune; brew cleanup; brew doctor'


export ANDROID_SDK_ROOT="/usr/local/share/android-sdk"
export ANDROID_NDK_HOME="/usr/local/share/android-ndk"

export PATH=$ANDROID_HOME/build-tools/$(ls $ANDROID_HOME/build-tools | sort | tail -1):$PATH
