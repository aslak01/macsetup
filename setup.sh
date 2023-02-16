#!/usr/bin/env bash

source scripts/_utils.sh

DOTFILESGIT="git@github.com:aslak01/dotfiles.git"

refresh_header

subheading "Allow your current terminal emulator full disk access"

echo "To do this, open ${bold}System Settings${normal} and go to ${bold}Privacy and Security${normal}."

get_consent "Have you granted disk access to your terminal?"
if ! has_consent; then
    e_failure "Please grant the access and then rerun the script"
    killall caffeinate
    exit 0
fi

echo "Enable sudo so the script has the necessary permissions"
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

refresh_header

subheading "Caffeinating so system sleep doesn't abort the script"

caffeinate -u &

refresh_header
# LOCATION="$(curl ipinfo.io | jq '.city')"
# WEATHERURL="http://wttr.in/$LOCATION?format=%l:+%c+%f"
# the_weather="$(curl -sm2 "$WEATHERURL")"
# printf "%${COLUMNS}s\n" "${the_weather:-I hope the weather is nice}"

# Ask for user variables up front


subheading "Set your COMPUTER NAME, LOCK SCREEN, GIT, and SSH information"
TIP="Tip: Don't include your real name"
rightalign "$TIP"
echo "Computer name:"
read -r COMPUTER_NAME
echo "Your name:"
read -r YOUR_NAME
echo "Your email:"
read -r YOUR_EMAIL
echo "Your phone number:"
read -r YOUR_PHONE

refresh_header


subheading "Verify details"

echo -e "Computer name: ${color_yellow}$COMPUTER_NAME ${color_reset}"
echo "Name: ${color_yellow}$YOUR_NAME${color_reset}"
echo "Email: ${color_yellow}$YOUR_EMAIL${color_reset}"
echo "Phone: ${color_yellow}$YOUR_PHONE${color_reset}"

get_consent "Are your details correct?"
if ! has_consent; then
    e_failure "Please rerun script and set the details correctly"
    killall caffeinate
    exit 0
fi

refresh_header

e_success "Details set"


subheading "APP STORE"

echo "SIGN IN TO THE ${color_blue}MAC APP STORE${color_reset}"
open /System/Applications/App\ Store.app/
e_pending "Sign in to the App Store to get xcode tools and App Store apps with mas"
e_anykey "Press any key when you're done, to continue."


subheading "Setup start"

e_bold "This script will install"
printf "\n"
echo "* xcode-select"
echo "* brew packages as configured in the Brewfile"
echo "* install zip zsh and deno"
echo "* install selected apps from the app store"
echo "* configure global git variables with the information previously provided"
echo "* generate ssh key"
echo "* copy someonewhocares' hosts file to /etc/hosts"
echo "* set computer name"
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

subheading "Installing xcode tools and brew"

if ! xcode-select --print-path &> /dev/null; then

    # Prompt user to install the XCode Command Line Tools
    xcode-select --install &> /dev/null

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Wait until the XCode Command Line Tools are installed
    until xcode-select --print-path &> /dev/null; do
        sleep 5
    done

    print_result $? ' XCode Command Line Tools Installed'

    # Prompt user to agree to the terms of the Xcode license
    # https://github.com/alrra/dotfiles/issues/10

    sudo xcodebuild -license
    print_result $? 'Agree with the XCode Command Line Tools licence'

fi

# Check for Homebrew, install if we don't have it
if test ! "$(which brew)"; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "eval '$(/opt/homebrew/bin/brew shellenv)'" >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Opt out of brew analytics
brew analytics off


subheading "Installing brew packages"

brew update
brew upgrade

brew bundle --file=./Brewfile

subheading "Cleaning up"

brew cleanup

subheading "Installing non-brew binaries"

# Zip Zsh plugin manager
zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh)

# Deno (updated too frequently to want to manage it with brew)
curl -fsSL https://deno.land/x/install/install.sh | sh

# install n (node version manager) and current node lts
curl -L https://bit.ly/n-install | bash

# pnpm through npm to hopefully avoid an issue where pnpm is tied to node version at install time
npm i -g pnpm

# install rust noninteractively
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y


subheading "Installing App Store apps"

# MAC APP STORE
mas install 1480933944 # Vimari
mas install 1458969831 # JSON Peep
mas install 1437138382 # WhatFont


subheading "Configuring git"

git config --global user.name "${YOUR_NAME}"
git config --global user.email "${YOUR_EMAIL}"
git config --global pull.rebase true
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"


subheading "Generating SSH keys"

# gen ssh key with empty passphrase (-N "")
ssh-keygen -t ed25519 -C "${YOUR_EMAIL}" -f ~/.ssh/id_ed25519 -N ""
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cp -f ./assets/config ~/.ssh/config


subheading "Making hosts file"

cp /etc/hosts /etc/hosts.old
curl "https://someonewhocares.org/hosts/zero/hosts" | sudo tee -a /etc/hosts


subheading "Setting DNS for WiFi"

sudo networksetup -setdnsservers Wi-Fi 1.1.1.1 8.8.8.8 8.8.4.4
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder


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
echo "Now please add your new ssh public key to github to clone the dotfiles repo"
echo ""
cat ~/.ssh/id_ed25519.pub
echo ""

e_anykey "Press any key to continue when this is done"

get_consent "Did you add the new ssh public key to your github?"

if has_consent; then
  subheading "Cloning dotfiles to ~/dotfiles and stowing them"
  echo "(dotfiles repo: $DOTFILES)"
  git clone $DOTFILESGIT ~/dotfiles
  rm ~/.zshrc
  (cd ~/dotfiles; stow .)
fi

subheading "Done!"
e_success "The script has reached the end"
echo ""
e_anykey "Press any key to finish and reboot…"

sudo shutdown -r now
