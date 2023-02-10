#!/usr/bin/env bash

source "scripts/_utils.sh"

refresh_header


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

clear

subheading "APP STORE"

echo "SIGN IN TO THE ${color_blue}MAC APP STORE${color_reset}"
open /System/Applications/App\ Store.app/
e_pending "Sign in to the App Store to get xcode tools and App Store apps with mas"
e_anykey "Press any key when you're done, to continue."

clear

subheading "Setup start"

e_bold "This script will install"
printf "\n"
echo "* xcode-select"
echo "* a whole bunch of brew packages as configured by the Brewfile"
echo "* install zip zsh and deno"
echo "* install selected macos packages"
echo "* configure global git variables with the information previously provided"
echo "* generate ssh keys"
echo "* copy someonewhocares' hosts file to /etc/hosts"
echo "* configure wifi dns servers"
echo "* set computer name"
echo "* enable filevault and firewall"
echo "* create a backup admin account"
echo "* tune various macos system preferences, as defined in scripts/macos_settings.sh"
printf "\n\n"

get_consent "Ready to start the installation process?"

if ! has_consent; then
    e_failure "Please rerun the script if you wish to carry out the installation"
    killall caffeinate
    exit 0
fi

subheading "Installing xcode tools and brew"

xcode-select --install

# Check for Homebrew, install if we don't have it
if test ! "$(which brew)"; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "eval '$(/opt/homebrew/bin/brew shellenv)'" >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Opt out of brew analytics
brew analytics off

subheading "Installing brew packages"

brew update

brew bundle --file=./Brewfile

subheading "Cleaning up"

brew cleanup

subheading "Installing non-brew binaries"

# Zip Zsh plugin manager
zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh)

# Deno (updated too frequently to want to manage it with brew)
curl -fsSL https://deno.land/x/install/install.sh | sh


subheading "Installing App Store apps"

# MAC APP STORE
mas install 1480933944 # Vimari
mas install 1458969831 # JSON Peep
mas install 1437138382 # WhatFont


subheading "Configuring git"

git config --global user.name "${YOUR_NAME}"
git config --global user.email "${YOUR_EMAIL}"
git config --global pull.rebase true
# Add diff-so-fancy config
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"


subheading "Generating SSH keys"

# gen ssh key with empty passphrase (-N "")
ssh-keygen -t rsa -b 4096 -C "${YOUR_EMAIL}" -f ~/.ssh/id_rsa -N ""
eval "$(ssh-agent -s)"
ssh-add -K ~/.ssh/id_rsa
# cp -f ./assets/config ~/.ssh/config

subheading "Making hosts file"

curl "https://someonewhocares.org/hosts/zero/hosts" | sudo tee -a /etc/hosts


subheading "Setting DNS for WiFi"

sudo networksetup -setdnsservers Wi-Fi 1.1.1.1 8.8.8.8 8.8.4.4
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder




subheading "Setting computer name"

sudo scutil --set ComputerName "${COMPUTER_NAME}"
sudo scutil --set HostName "${COMPUTER_NAME}"
sudo scutil --set LocalHostName "${COMPUTER_NAME}"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "${COMPUTER_NAME}"


subheading "Enable Filevault"

# Enable FileVault
sudo fdesetup enable


subheading "Enable firewall"

# Turn on the firewall, and enable logging and stealth mode
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on
# sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on


subheading "Setting up a new admin account"
## So I don't have to give up my real password to Apple, in case I need to hand
## the machine over at some point.
## =============================================================================
ADMINTWO_PASSWORD=$(openssl rand -base64 8)
sudo dscl . create /Users/admintwo
sudo dscl . create /Users/admintwo RealName "Extra Admin Account"
sudo dscl . create /Users/admintwo hint ""
sudo dscl . passwd /Users/admintwo "${ADMINTWO_PASSWORD}"
sudo dscl . create /Users/admintwo UniqueID 550
sudo dscl . create /Users/admintwo PrimaryGroupID 80
sudo dscl . create /Users/admintwo UserShell /bin/bash
sudo dscl . create /Users/admintwo NFSHomeDirectory /Users/admintwo
sudo createhomedir -u admintwo


subheading "Allow touchID to sudo"
# Setup sudo config (New one to allow TouchID to sudo)
sudo cp -f ./assets/sudo /etc/pam.d/sudo


subheading "Tuning MacOS settings"
# Always boot in verbose mode
# sudo nvram boot-args="-v"

# Setup lock screen message
sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "If found call ${YOUR_PHONE} or email ${YOUR_EMAIL}"

# MacOS settings:
source "scripts/macos_settings.sh"


subheading "Restarting affected processes"

# Kill all affected apps and services
for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" \
	"Dock" "Finder" "Mail" "Messages" "Safari" "SystemUIServer"; do
	killall "$app" >/dev/null 2>&1
done

subheading "Checking for MacOS software updates"

# Run a MacOS software update
sudo softwareupdate -ia

clear

refresh_header

e_success "Done!"
echo ""
echo "Congrats, $YOUR_NAME. Setup is complete."
echo ""
echo "We've created a ${bold}admintwo${normal} user with the following account info:"
echo "================================================================="
echo "Username: admintwo"
echo "Password: ${ADMINTWO_PASSWORD}"
echo "================================================================="
echo "Save this password in a password manager."
echo "Admin two is useful when the computer needs to go to the doctor."
echo ""

e_anykey "Press any key to finish and reboot…"

killall caffeinate

sudo shutdown -r now
