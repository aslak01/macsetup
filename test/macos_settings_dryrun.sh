#!/usr/bin/env bash

echo "========================================================================"
echo "Configuring macOS"
echo "========================================================================"
# Always boot in verbose mode
# sudo nvram boot-args="-v"

# Setup lock screen message
echo "sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText If found call ${YOUR_PHONE} or email ${YOUR_EMAIL}"

echo "Require password as soon as screensaver or sleep mode starts"
echo "defaults write com.apple.screensaver askForPassword -int 1"
echo "defaults write com.apple.screensaver askForPasswordDelay -int 0"

echo "Enable tap-to-click"
echo "defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true"
echo "defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1"

echo "# Check for software updates daily, not just once per week"
echo "defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1"

echo "# Expand save panel"
echo "defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true"
echo "defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true"
echo "defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true"

echo "# Automatically quit printer app once the print jobs complete"
echo "defaults write com.apple.print.PrintingPrefs Quit When Finished -bool true"

echo "# Enable full keyboard access for all controls"
echo "# (e.g. enable Tab in modal dialogs)"
echo "defaults write NSGlobalDomain AppleKeyboardUIMode -int 3"

echo "## FINDER"
echo "## ============================================================================="
echo "# No delay for proxy icons"
echo "defaults write -g NSToolbarTitleViewRolloverDelay -float 0"

echo "# Show filename extensions by default"
echo "defaults write NSGlobalDomain AppleShowAllExtensions -bool true"

echo "# Show all files"
echo "defaults write com.apple.finder AppleShowAllFiles -bool true"
echo "chflags nohidden ~/Library"

echo "# Hide desktop icons"
echo "defaults write com.apple.finder CreateDesktop -bool false"

echo "# Set default location for new Finder windows"
echo "# For other paths, use PfLo and file:///full/path/here/"
echo 'defaults write com.apple.finder NewWindowTarget -string "PfLo"'
echo "defaults write com.apple.finder NewWindowTargetPath -string file://${HOME}/"

echo "# When performing a search, search the current folder by default"
echo "defaults write com.apple.finder FXDefaultSearchScope -string SCcf"

echo "# Open finder in column view"
echo "defaults write com.apple.finder AlwaysOpenInColumnView true"
echo "defaults write com.apple.finder FXPreferredViewStyle Clmv"

echo "# Set sidebar font size to small"
echo "defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1"

echo "# Show status bar"
echo "defaults write com.apple.finder ShowStatusBar -bool true"

echo "# Expand the following File Info panes:"
echo '# “General”, “Open with”, and “Sharing & Permissions”'
echo "defaults write com.apple.finder FXInfoPanesExpanded -dict \""
  echo "General -bool true \""
  echo "OpenWith -bool true \""
  echo "Privileges -bool true"

echo "# Display full POSIX path as Finder window title"
echo "defaults write com.apple.finder _FXShowPosixPathInTitle -bool true"

echo "# Avoid creating .DS_Store files on network or USB volumes"
echo "defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true"
echo "defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true"

echo "## TEXTEDIT"
## =============================================================================
echo "# Use plain text mode for new TextEdit documents"
echo "defaults write com.apple.TextEdit RichText -int 0"

echo "# Open and save files as UTF-8 in TextEdit"
echo "defaults write com.apple.TextEdit PlainTextEncoding -int 4"
echo "defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4"

echo "# Start with a blank document, instead of open dialog"
echo "defaults write -g NSShowAppCentricOpenPanelInsteadOfUntitledFile -bool false"

echo "## PHOTOS"
## =============================================================================
echo "# Disable Photos.app from starting everytime a device is plugged in"
echo "defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true"

echo "## SAFARI"
## =============================================================================
# Safari devtools
echo "defaults write com.apple.Safari IncludeInternalDebugMenu -bool true"
echo "defaults write com.apple.Safari IncludeDevelopMenu -bool true"
echo "defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true"
echo 'defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true'
echo "defaults write NSGlobalDomain WebKitDeveloperExtras -bool true"

echo "# Prevent Safari from opening ‘safe’ files automatically after downloading"
echo "defaults write com.apple.Safari AutoOpenSafeDownloads -bool false"

echo "# Privacy: don’t send search queries to Apple"
echo "defaults write com.apple.Safari UniversalSearchEnabled -bool false"
echo "defaults write com.apple.Safari SuppressSearchSuggestions -bool true"

echo "# Show the full URL in the address bar (note: this still hides the scheme)"
echo "defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true"

echo "# Add a context menu item for showing the Web Inspector in web views"
echo "defaults write NSGlobalDomain WebKitDeveloperExtras -bool true"

echo "# Warn about fraudulent websites"
echo "defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true"

echo '# Enable “Do Not Track”'
echo "defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true"

echo "# Update extensions automatically"
echo "defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true"

echo "# Hide Safari’s bookmarks bar by default"
echo "defaults write com.apple.Safari ShowFavoritesBar -bool false"

# Press Tab to highlight each item on a web page
# defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
# defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true

## iTUNES
## =============================================================================
echo "# Stop iTunes from responding to the keyboard media keys"
echo "launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null"

## MAIL
## =============================================================================
echo "# Add the keyboard shortcut CMD + Enter to send an email"
echo 'defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" "@\U21a9"'

echo "# Set email addresses to copy as 'foo@example.com' instead of 'Foo Bar <foo@example.com>'"
echo "defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false"

## DOCK
## =============================================================================
echo "# autohide dock"
echo "defaults write com.apple.Dock autohide -bool true"
echo "# Remove the auto-hiding Dock delay"
echo "defaults write com.apple.dock autohide-delay -float 0"
echo "# Remove the animation when hiding/showing the Dock"
echo "defaults write com.apple.dock autohide-time-modifier -float 0"
echo "# set dock icon size"
echo "defaults write com.apple.dock tilesize -int 24"
echo "# Don’t show recent applications in Dock"
echo "defaults write com.apple.dock show-recents -bool false"

# Disable autocorrect
# defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
