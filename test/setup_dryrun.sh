#!/usr/bin/env bash

source _utils.sh

refresh_header

echo "Enable sudo so the script has the necessary permissions"
# sudo -v
# while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "Pretend to enter sudo password"
read -r PWD

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
# open /System/Applications/App\ Store.app/
e_pending "Sign in to the App Store to get xcode tools and App Store apps with mas"
e_anykey "Press any key when you're done, to continue."

clear

subheading "Setup start"

e_bold "This script will install"
printf "\n\n"
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

echo "Running xcode-select --install"
# xcode-select --install

# Check for Homebrew, install if we don't have it
if test ! "$(which brew)"; then
    echo "Installing homebrew as it was not found on the system"
    # /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # echo "eval '$(/opt/homebrew/bin/brew shellenv)'" >> ~/.zprofile
    # eval "$(/opt/homebrew/bin/brew shellenv)"
    else
	echo "Homebrew already installed"
fi
sleep 0.3

# Opt out of brew analytics
echo "Turning off brew analytics"
sleep 0.3
# brew analytics off

subheading "Install brew packages"

echo 'Running brew update'
sleep 0.3
# brew update

echo "Installing all packages from brewfile"
# brew bundle --file=./Brewfile
source brewfile_dryrun.sh

subheading "Cleaning up"

echo 'Running brew cleanup'
sleep 0.3
# brew cleanup

subheading "Installing non-brew binaries"

# Zip Zsh plugin manager
echo 'Installing zip zsh, a minimal zsh plugin manager'
sleep 0.3
# zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh)

echo 'Installing deno'
sleep 0.3
# Deno (updated too frequently to want to manage it with brew)
# curl -fsSL https://deno.land/x/install/install.sh | sh


subheading "Installing App Store apps"

# MAC APP STORE
echo 'mas install vimari'
# mas install 1480933944 # Vimari
echo 'mas install json peep'
# mas install 1458969831 # JSON Peep
echo 'mas install whatfont'
# mas install 1437138382 # WhatFont
sleep 0.6


subheading "Configuring git"
sleep 0.3

echo "git config --global user.name ${YOUR_NAME}"
echo "git config --global user.email ${YOUR_EMAIL}"
echo "git config --global pull.rebase true"
# Add diff-so-fancy config
echo 'git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"'

sleep 0.5

subheading "Generating SSH keys"

echo "ssh-keygen -t rsa -b 4096 -C ${YOUR_EMAIL} -f ~/.ssh/id_rsa"
echo 'eval $(ssh-agent -s)'
echo 'ssh-add -K ~/.ssh/id_rsa'

sleep 0.5

subheading "Making hosts file"

echo 'curl "https://someonewhocares.org/hosts/zero/hosts" | sudo tee -a /etc/hosts'
sleep 0.4

subheading "Setting DNS for WiFi"

echo 'sudo networksetup -setdnsservers Wi-Fi 1.1.1.1 8.8.8.8 8.8.4.4'
echo 'sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
sleep 0.3

subheading "Setting computer name"

echo "sudo scutil --set ComputerName ${COMPUTER_NAME}"
echo "sudo scutil --set HostName ${COMPUTER_NAME}"
echo "sudo scutil --set LocalHostName ${COMPUTER_NAME}"
echo "sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string ${COMPUTER_NAME}"

sleep 0.5

subheading "Enable Filevault"

# Enable FileVault
echo "sudo fdesetup enable"
sleep 0.3


subheading "Enable firewall"

sleep 0.3
# Turn on the firewall, and enable logging and stealth mode
echo "sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on"
sleep 0.3
echo "sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on"
# sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
sleep 0.3


subheading "Setting up a new admin account"
## So I don't have to give up my real password to Apple, in case I need to hand
## the machine over at some point.
## =============================================================================
ADMINTWO_PASSWORD=$(openssl rand -base64 8)
echo "sudo dscl . create /Users/admintwo"
echo 'sudo dscl . create /Users/admintwo RealName "Extra Admin Account"'
echo 'sudo dscl . create /Users/admintwo hint ""'
echo "sudo dscl . passwd /Users/admintwo ${ADMINTWO_PASSWORD}"
echo "sudo dscl . create /Users/admintwo UniqueID 550"
echo "sudo dscl . create /Users/admintwo PrimaryGroupID 80"
echo "sudo dscl . create /Users/admintwo UserShell /bin/bash"
echo "sudo dscl . create /Users/admintwo NFSHomeDirectory /Users/admintwo"
echo "sudo createhomedir -u admintwo"


subheading "Allow touchID to sudo"
# Setup sudo config (New one to allow TouchID to sudo)
echo "sudo cp -f ./assets/sudo /etc/pam.d/sudo"


subheading "Tuning MacOS settings"
# Always boot in verbose mode
# sudo nvram boot-args="-v"

# Setup lock screen message
echo "sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText If found call ${YOUR_PHONE} or email ${YOUR_EMAIL}"

# MacOS settings:
# source scripts/macos_settings.sh
source macos_settings_dryrun.sh


subheading "Restarting affected processes"

# Kill all affected apps and services
echo 'for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" \'
echo '"Dock" "Finder" "Mail" "Messages" "Safari" "SystemUIServer"; do'
echo 'killall "$app" >/dev/null 2>&1'
echo 'done'

subheading "Checking for MacOS software updates"

# Run a MacOS software update
echo 'sudo softwareupdate -ia'

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
echo "Admin two is useful when the computer needs to go to the doctor."
echo ""

e_anykey "Press any key to finish and reboot…"

killall caffeinate

echo 'sudo shutdown -r now'

