#!/usr/bin/env bash

source "scripts/_utils.sh"

refresh_header


echo "Enable sudo so the script has the necessary permissions"
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

refresh_header
echo "Caffeinating so system sleep doesn't abort the script"
caffeinate -u &

refresh_header
# LOCATION="$(curl ipinfo.io | jq '.city')"
# WEATHERURL="http://wttr.in/$LOCATION?format=%l:+%c+%f"
# the_weather="$(curl -sm2 "$WEATHERURL")"
# printf "%${COLUMNS}s\n" "${the_weather:-I hope the weather is nice}"
# Ask for user variables up front
echo "Set your $(e_bold)COMPUTER NAME, LOCK SCREEN, GITHUB and SSH information"
TIP="Tip: Don't include your real name"
e_magenta "$TIP"
echo "Computer name:"
read -r COMPUTER_NAME
echo "Your name:"
read -r YOUR_NAME
echo "Your email:"
read -r YOUR_EMAIL
echo "Your phone number:"
read -r YOUR_PHONE

refresh_header

e_bold "Verify details"
echo 
echo -e "Computer name: ${color_green}$COMPUTER_NAME ${color_reset}"
echo "Name: ${color_green}$YOUR_NAME${color_reset}"
echo "Email: ${color_green}$YOUR_EMAIL${color_reset}"
echo "Phone: ${color_green}$YOUR_PHONE${color_reset}"

get_consent "Are your details correct?"
if ! has_consent; then
    e_failure "Please rerun script and set the details correctly"
    killall caffeinate
    exit 0
fi
e_success "Details set"

echo "========================================================================"
echo "SIGN IN TO THE MAC APP STORE"
open /System/Applications/App\ Store.app/
e_pending "Sign in to the App Store to get xcode tools"
anykey "Press any key when you're done, to continue."

get_consent "Ready to start the installation process?"

if ! has_consent; then
    e_falure "Please rerun the script if you wish to carry out the installation"
    killall caffeinate
    exit 0
fi

echo "========================================================================"
echo "Installing xcode tools and brew"
echo "========================================================================"
# Install xcode tools
xcode-select --install

# Check for Homebrew, install if we don't have it
if test ! "$(which brew)"; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "eval '$(/opt/homebrew/bin/brew shellenv)'" >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Opt out of brew analytics
brew analytics off

echo "========================================================================"
echo "Installing brew packages"
echo "========================================================================"

brew update

brew bundle --file=./Brewfile

echo "========================================================================"
echo "Cleaning up"
echo "========================================================================"

brew cleanup

echo "========================================================================"
echo "Installing non brewed binaries"
echo "========================================================================"

# Zip Zsh plugin manager
zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh)

# Deno (updated too frequently to want to manage it with brew)
curl -fsSL https://deno.land/x/install/install.sh | sh


# MAC APP STORE
mas install 1480933944 # Vimari
mas install 1458969831 # JSON Peep
mas install 1437138382 # WhatFont

echo "========================================================================"
echo "Setting up Git"
echo "========================================================================"
git config --global user.name "${YOUR_NAME}"
git config --global user.email "${YOUR_EMAIL}"
git config --global pull.rebase true
# Add diff-so-fancy config
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"

echo "========================================================================"
echo "Generating SSH keys and config"
echo "========================================================================"
ssh-keygen -t rsa -b 4096 -C "${YOUR_EMAIL}" -f ~/.ssh/id_rsa
eval "$(ssh-agent -s)"
ssh-add -K ~/.ssh/id_rsa
# cp -f ./assets/config ~/.ssh/config

echo "========================================================================"
echo "Making hosts file"
echo "========================================================================"

curl "https://someonewhocares.org/hosts/zero/hosts" | sudo tee -a /etc/hosts

echo "========================================================================"
echo "Setting DNS for Wifi"
echo "========================================================================"

sudo networksetup -setdnsservers Wi-Fi 1.1.1.1 8.8.8.8 8.8.4.4
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder

echo "========================================================================"
echo "Setting Firmware password"
echo "========================================================================"
# Prompt for FW password when booting from a different volume
get_consent "Set firmware password?"
if has_consent; then
    FW_PWD=$(openssl rand -base64 10)
    copy "${FW_PWD}"
    echo "Prompt for FW password when booting from a different volume"
    echo "If you need to set a new Firmware password, may I suggest:"
    echo "${FW_PWD}"
    echo "Randomly generated by openssl - SAVE THIS SOMEWHERE SAFE"
    echo "(The suggested password is on the pasteboard as well)"
    sudo firmwarepasswd -setpasswd -setmode command
    else
	echo "Firmware password skipped"
fi


echo "========================================================================"
echo "Setting computer name"
echo "========================================================================"

sudo scutil --set ComputerName "${COMPUTER_NAME}"
sudo scutil --set HostName "${COMPUTER_NAME}"
sudo scutil --set LocalHostName "${COMPUTER_NAME}"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "${COMPUTER_NAME}"

echo "========================================================================"
echo "Enable Filevault"
echo "========================================================================"
# Enable FileVault
sudo fdesetup enable

echo "========================================================================"
echo "Turn on the firewall, and enable logging"
echo "========================================================================"
# Turn on the firewall, and enable logging and stealth mode
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on
# sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on

echo "========================================================================"
echo "Creating a new admin user"
echo "========================================================================"
## So I don't have to give up my real password to Apple, in case I need to hand
## the machine over at some point.
## =============================================================================
TESTADMIN_PASSWORD=$(openssl rand -base64 8)
sudo dscl . create /Users/testadmin
sudo dscl . create /Users/testadmin RealName "Test Administrator"
sudo dscl . create /Users/testadmin hint ""
sudo dscl . passwd /Users/testadmin "${TESTADMIN_PASSWORD}"
sudo dscl . create /Users/testadmin UniqueID 550
sudo dscl . create /Users/testadmin PrimaryGroupID 80
sudo dscl . create /Users/testadmin UserShell /bin/bash
sudo dscl . create /Users/testadmin NFSHomeDirectory /Users/testadmin
sudo createhomedir -u testadmin

echo "========================================================================"
echo "Setting sudo settings"
echo "========================================================================"
# Setup sudo config (New one to allow TouchID to sudo)
sudo cp -f ./assets/sudo /etc/pam.d/sudo

echo "========================================================================"
echo "Configuring macOS"
echo "========================================================================"
# Always boot in verbose mode
# sudo nvram boot-args="-v"

# Setup lock screen message
sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "If found call ${YOUR_PHONE} or email ${YOUR_EMAIL}"

# MacOS settings:
source "scripts/macos_settings.sh"

# Kill all affected apps and services
for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" \
	"Dock" "Finder" "Mail" "Messages" "Safari" "SystemUIServer"; do
	killall "$app" >/dev/null 2>&1
done

# Run a MacOS software update
sudo softwareupdate -ia

echo "Done!"
echo ""
echo "We've created a testadmin user with the following account info:"
echo "================================================================="
echo "Username: testadmin"
echo "Password: ${TESTADMIN_PASSWORD}"
echo "================================================================="
echo "Save this to 1Password, and keep it for when the computer needs"
echo "to go to the hospital."
echo ""
read -pr "Press any key to finish and reboot… " -n1 -s
killall caffeinate
sudo shutdown -r now
