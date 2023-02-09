#!/usr/bin/env bash

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
# autohide dock
defaults write com.apple.Dock autohide -bool true
# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0
# Remove the animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0
# set dock icon size
defaults write com.apple.dock tilesize -int 24
# Don’t show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

# Disable autocorrect
# defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
