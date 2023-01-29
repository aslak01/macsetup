#!/bin/bash

source "scripts/_utils.sh"

clear

INTRO="
███    ███  █████   ██████     ███████ ███████ ████████ ██    ██ ██████  
████  ████ ██   ██ ██          ██      ██         ██    ██    ██ ██   ██ 
██ ████ ██ ███████ ██          ███████ █████      ██    ██    ██ ██████  
██  ██  ██ ██   ██ ██               ██ ██         ██    ██    ██ ██      
██      ██ ██   ██  ██████     ███████ ███████    ██     ██████  ██"

printf "%s" "$INTRO"
printf "\n"

SEP="========================================================================"

printf "%s" "$SEP"
printf "\n\n\n"

# from https://raw.githubusercontent.com/jlom/macsetup/master/setup.sh

# echo "Enable sudo so the script has the necessary permissions"
# sudo -v
# while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Ask for user variables up front
echo "SET COMPUTER NAME"
read -r COMPUTER_NAME

echo "========================================================================"
echo "SET YOUR LOCK SCREEN, GITHUB and SSH INFORMATION"
echo "Your name:"
read -r YOUR_NAME
echo "Your email:"
read -r YOUR_EMAIL
echo "Your phone number:"
read -r YOUR_PHONE

echo "========================================================================"

echo "Are your details correct?"
echo 
echo "Computer name: $COMPUTER_NAME"
echo "Name: $YOUR_NAME"
echo "Email: $YOUR_EMAIL"
echo "Phone: $YOUR_PHONE"

get_consent "Confirm or deny"
if ! has_consent; then
    echo "SET DETAILS AGAIN (PAY MORE ATTENTION THIS TIME)"
    echo
    printf "%s" "$SEP"
    echo
    echo "Computer name:"
    read -r COMPUTER_NAME
    echo "Your name:"
    read -r YOUR_NAME
    echo "Your email:"
    read -r YOUR_EMAIL
    echo "Your phone number:"
    read -r YOUR_PHONE
    get_consent "Are details correct now?"
    if has_consent; then
        e_success "Details set"
    else
        e_failure "Please rerun script and set the details correctly"
        exit 0
    fi
fi
e_success "Details set"

echo "========================================================================"
echo "SIGN IN TO THE MAC APP STORE"
open /System/Applications/App\ Store.app/
anykey "Sign in to the App Store. Press any key when you're done, to continue.\n"
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

echo "========================================================================"
echo "Adding assorted preference files"
echo "========================================================================"

# Add diff-so-fancy config
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"

echo "========================================================================"
echo "Setting up Git"
echo "========================================================================"
git config --global user.name "${YOUR_NAME}"
git config --global user.email "${YOUR_EMAIL}"
git config --global pull.rebase true

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
sudo cp -f ./assets/hosts /private/etc/hosts
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
read -r -p "Set firmware password (reccomended)? [y/n] " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    FW_PWD=$(openssl rand -base64 8)
    copy "${FW_PWD}"
    echo "Prompt for FW password when booting from a different volume"
    echo "If you need to set a new Firmware password, may I suggest:"
    echo "${FW_PWD}"
    echo "Randomly generated by openssl - SAVE THIS SOMEWHERE SAFE"
    echo "(The suggested password is on the pasteboard as well)"
    sudo firmwarepasswd -setpasswd -setmode command
fi


echo "========================================================================"
echo "Setting computer name"
echo "========================================================================"
# Set computer name (Variable up top)
# Note: Always a good idea not to include your name in the computer name
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
echo "Turn on the firewall, and enable logging and stealth mode"
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

# Require password as soon as screensaver or sleep mode starts
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Enable tap-to-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Set fast key repeat rate
# defaults write NSGlobalDomain KeyRepeat -int 0

# Set graphite appearance
# defaults write NSGlobalDomain AppleAquaColorVariant -int 6

# Show battery percentage
# defaults write com.apple.menuextra.battery ShowPercent -bool true

# Check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Expand save panel
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

## TOP RIGHT SCREEN CORNER → START SCREEN SAVER
# defaults write com.apple.dock wvous-tr-corner -int 5
# defaults write com.apple.dock wvous-tr-modifier -int 0

# Disable press-and-hold for keys in favor of key repeat
# defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Enable full keyboard access for all controls
# (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

## FINDER
## =============================================================================
# No delay for proxy icons
defaults write -g NSToolbarTitleViewRolloverDelay -float 0

# Wide alerts
# defaults write -g NSAlertMetricsGatheringEnabled -bool false

# Show filename extensions by default
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show all files
defaults write com.apple.finder AppleShowAllFiles -bool true
chflags nohidden ~/Library

# Hide desktop icons
defaults write com.apple.finder CreateDesktop -bool false

# Set default location for new Finder windows
# For other paths, use `PfLo` and `file:///full/path/here/`
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Open finder in column view
defaults write com.apple.finder AlwaysOpenInColumnView true
defaults write com.apple.finder FXPreferredViewStyle Clmv

# Set sidebar font size to small
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Expand the following File Info panes:
# “General”, “Open with”, and “Sharing & Permissions”
defaults write com.apple.finder FXInfoPanesExpanded -dict \
  General -bool true \
  OpenWith -bool true \
  Privileges -bool true

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

## TEXTEDIT
## =============================================================================
# Use plain text mode for new TextEdit documents
defaults write com.apple.TextEdit RichText -int 0

# Open and save files as UTF-8 in TextEdit
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

# Start with a blank document, instead of open dialog
defaults write -g NSShowAppCentricOpenPanelInsteadOfUntitledFile -bool false

## PHOTOS
## =============================================================================
# Disable Photos.app from starting everytime a device is plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

## SAFARI
## =============================================================================
# Safari devtools
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# Prevent Safari from opening ‘safe’ files automatically after downloading
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# Privacy: don’t send search queries to Apple
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

# Show the full URL in the address bar (note: this still hides the scheme)
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# Add a context menu item for showing the Web Inspector in web views
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# Warn about fraudulent websites
defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

# Enable “Do Not Track”
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

# Update extensions automatically
defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

# Hide Safari’s bookmarks bar by default
defaults write com.apple.Safari ShowFavoritesBar -bool false

# Press Tab to highlight each item on a web page
defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true

## iTUNES
## =============================================================================
# Stop iTunes from responding to the keyboard media keys
launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null

## MAIL
## =============================================================================
# Add the keyboard shortcut CMD + Enter to send an email
defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" "@\U21a9"

# Set email addresses to copy as 'foo@example.com' instead of 'Foo Bar <foo@example.com>'
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

## DOCK
## =============================================================================
# Change dock hiding and sizing prefs
defaults write com.apple.Dock autohide -bool true
defaults write com.apple.dock tilesize -int 24

# instant dock show/hide
defaults write com.apple.Dock autohide-delay -float 0.0001

# Disable autocorrect
# defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

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
sudo shutdown -r now
