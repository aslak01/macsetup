#!/usr/bin/env bash

source scripts/_utils.sh

DOTFILESGIT="git@github.com:aslak01/dotfiles.git"

refresh_header

subheading "Allow your current terminal emulator full disk access"

get_consent "The script will attempt to run an Apple script automation to achieve this"
if ! has_consent; then
    e_failure "Please restart the script"
    killall caffeinate
    exit 0
fi

osascript -e "./scripts/grant_terminal_access.scpt"

echo "If the Apple script didn't work, grant access manually. To do this, open ${bold}System Settings${normal} and go to ${bold}Privacy and Security${normal}."
e_anykey "Press any key to continue when this is done"

get_consent "Have you granted disk access to your terminal?"

if ! has_consent; then
    e_failure "Please restart the script"
    killall caffeinate
    exit 0
fi

refresh_header

subheading "Caffeinating so system sleep doesn't abort the script"

caffeinate -u &

refresh_header
# LOCATION="$(curl ipinfo.io | jq '.city')"
# WEATHERURL="http://wttr.in/$LOCATION?format=%l:+%c+%f"
# the_weather="$(curl -sm2 "$WEATHERURL")"
# printf "%${COLUMNS}s\n" "${the_weather:-I hope the weather is nice}"

# Ask for user variables up front
#
source ./scripts/get_details.sh

refresh_header

e_success "Details set"

subheading "Setup start"

e_bold "This script will install"
printf "\n"
echo "* xcode-select"
echo "* brew packages as configured in the Brewfile"
echo "* configure global git variables with the information previously provided"
echo "* generate ssh key"
echo "* enable filevault"
echo "* tune various macos system preferences, as defined in scripts/macos_settings.sh"
echo ""
echo "At the end of the installation process you will be prompted to add your fresh ssh key to github"
echo "to clone and stow dotfiles."
printf "\n\n"

get_consent "Ready to start the installation process?"

if ! has_consent; then
    e_failure "Please rerun the script if you wish to carry out the installation"
    killall caffeinate
    exit 0
fi

subheading "Installing xcode tools"

if ! xcode-select --print-path &>/dev/null; then

    # Prompt user to install the XCode Command Line Tools
    xcode-select --install &>/dev/null

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Wait until the XCode Command Line Tools are installed
    until xcode-select --print-path &>/dev/null; do
        sleep 5
    done

    print_result $? ' XCode Command Line Tools Installed'

    # Prompt user to agree to the terms of the Xcode license
    # https://github.com/alrra/dotfiles/issues/10

    sudo xcodebuild -license
    print_result $? 'Agree with the XCode Command Line Tools licence'

fi

subheading "Installing homebrew"

# Check for Homebrew, install if we don't have it
if test ! "$(which brew)"; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "eval '$(/opt/homebrew/bin/brew shellenv)'" >>~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Opt out of brew analytics
brew analytics off

subheading "Installing brew packages"

brew update
brew upgrade

brew bundle --file=./Brewfile

# start brew services
brew services start borders

subheading "Cleaning up"

brew cleanup

subheading "Installing rust"
# install rust noninteractively
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

export RUSTPATH="$HOME/.cargo"
sudo chown -R "$(whoami)" "$HOME/.cargo"

subheading "Installing bob"

cargo install bob-nvim

subheading "Installing version managed neovim"

bob install latest
bob use latest

# subheading "Configuring git"
#
# git config --global user.name "${YOUR_NAME}"
# git config --global user.email "${YOUR_EMAIL}"
# git config --global pull.rebase true
# git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"

subheading "Generating SSH keys"

# gen ssh key with empty passphrase (-N "")
ssh-keygen -t ed25519 -C "${YOUR_EMAIL}" -f ~/.ssh/id_ed25519 -N ""
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cp -f ./assets/config ~/.ssh/config

echo "Enable sudo so the script has the necessary permissions"
sudo -v
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

subheading "Setting DNS to Cloudflare and Google servers"

sudo networksetup -setdnsservers Wi-Fi 1.1.1.1 8.8.8.8 8.8.4.4
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder

subheading "Allow touchID to sudo"
sudo cp -f ./assets/sudo /etc/pam.d/sudo

subheading "Tuning MacOS settings"

sudo chmod +x scripts/macos_settings.sh
source scripts/macos_settings.sh

# subheading "Checking for MacOS software updates"

# Run a MacOS software update
# sudo softwareupdate -ia

refresh_header

e_success "Most installations are done!"

printf "\n\n"
echo "Take a moment to add the public key where neccessary"
echo ""
cat ~/.ssh/id_ed25519.pub
echo ""

e_anykey "Press any key to continue when this is done"

get_consent "Did you add the new ssh public key to your github?"

if has_consent; then
    subheading "Cloning dotfiles to ~/dotfiles and stowing them"
    echo "(dotfiles repo: $DOTFILES)"
    git clone $DOTFILESGIT ~/dotfiles
    # remove files so symlinking can work:
    rm ~/.zshrc ~/.zprofile ~/.zshenv
    (
        cd ~/dotfiles || exit
        stow .
    )
fi

subheading "Done!"
e_success "The script has reached the end"
echo ""
e_anykey "Press any key to finish and reboot…"

sudo shutdown -r now
