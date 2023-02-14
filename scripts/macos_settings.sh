#!/usr/bin/env bash

echo "========================================================================"
echo "Configuring macOS"
echo "========================================================================"

echo "Closing System Settings if open to prevent collisions"
osascript -e 'tell application "System Settings" to quit'

# Always boot in verbose mode
# sudo nvram boot-args="-v"

echo "Set lock screen message:"
echo "If found call ${YOUR_PHONE} or email ${YOUR_EMAIL}"

sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "If found call ${YOUR_PHONE} or email ${YOUR_EMAIL}"

echo "Use function F1, F2, etc. keys as standard function keys"
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true


echo "Require password as soon as screensaver or sleep mode starts"
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

echo "Enable tap-to-click for current user and login screen"
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

echo "Disable 'natural' (Lion-style) scrolling"
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Increase sound quality for Bluetooth headphones/headsets
# defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

echo "Disable automatically rearrange spaces based on recent use:"
defaults write com.apple.dock mru-spaces -bool false

# Set fast key repeat rate
# defaults write NSGlobalDomain KeyRepeat -int 0

# Set graphite appearance
# defaults write NSGlobalDomain AppleAquaColorVariant -int 6

# Show battery percentage
# defaults write com.apple.menuextra.battery ShowPercent -bool true

echo "Increase window resize speed for Cocoa applications"
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

echo "Check for software updates daily, not just once per week"
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

echo "Expand save panel"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

echo "Expand print panel by default"
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

echo "Automatically quit printer app once the print jobs complete"
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

echo "Save to disk (not to iCloud) by default"
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Disable press-and-hold for keys in favor of key repeat
# defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

echo "Enable full keyboard access for all controls"
echo "(e.g. enable Tab in modal dialogs)"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

## FINDER
## =============================================================================

echo "place screenshots in Downloads folder instead of desktop"
defaults write com.apple.screencapture location "${HOME}/Downloads"

# Disable shadow in screenshots
# defaults write com.apple.screencapture disable-shadow -bool true

echo "No delay for proxy icons"
defaults write -g NSToolbarTitleViewRolloverDelay -float 0

echo "Show filename extensions by default"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

echo "Show all files"
defaults write com.apple.finder AppleShowAllFiles -bool true
sudo chflags nohidden ~/Library
sudo chflags nohidden /Volumes

echo "Allow quitting via ⌘ + Q (doing so will also hide desktop icons)"
defaults write com.apple.finder QuitMenuItem -bool true

echo "Set default location for new Finder windows to file://${HOME}/"
# For other paths, use `PfLo` and `file:///full/path/here/`
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

echo "When performing a search, search the current folder by default"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

echo "Open finder in column view"
defaults write com.apple.finder AlwaysOpenInColumnView true
defaults write com.apple.finder FXPreferredViewStyle Clmv

echo "Set sidebar font size to small"
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1

echo "Show status bar"
defaults write com.apple.finder ShowStatusBar -bool true

echo "Expand the following File Info panes:"
echo "“General”, “Open with”, and “Sharing & Permissions”"
defaults write com.apple.finder FXInfoPanesExpanded -dict \
  General -bool true \
  OpenWith -bool true \
  Privileges -bool true

echo "Display full POSIX path as Finder window title"
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

echo "Avoid creating .DS_Store files on network or USB volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

## TEXTEDIT
## =============================================================================
echo "Use plain text mode for new TextEdit documents"
defaults write com.apple.TextEdit RichText -int 0

echo "Open and save files as UTF-8 in TextEdit"
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

echo "Start textedit with a blank document, instead of open dialog"
defaults write -g NSShowAppCentricOpenPanelInsteadOfUntitledFile -bool false

## PHOTOS
## =============================================================================
echo "Disable Photos.app from starting everytime a device is plugged in"
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

## SAFARI
## =============================================================================
echo "Enable Safari devtools"
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

echo "Enable continuous spellchecking"
defaults write com.apple.Safari WebContinuousSpellCheckingEnabled -bool true
echo "Disable auto-correct"
defaults write com.apple.Safari WebAutomaticSpellingCorrectionEnabled -bool false

echo "Prevent Safari from opening ‘safe’ files automatically after downloading"
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

echo "Privacy: don’t send search queries to Apple"
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

echo "Show the full URL in the address bar (note: this still hides the scheme)"
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

echo "Add a context menu item for showing the Web Inspector in web views"
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# echo "Warn about fraudulent websites"
# defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

echo "Enable “Do Not Track”"
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

echo "Update extensions automatically"
defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

echo "Hide Safari’s bookmarks bar by default"
defaults write com.apple.Safari ShowFavoritesBar -bool false

echo "Disable Java"
defaults write com.apple.Safari WebKitJavaEnabled -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles -bool false

# echo "Press Tab to highlight each item on a web page"
# defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
# defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true

## iTUNES
## =============================================================================
echo "Stop iTunes from responding to the keyboard media keys"
launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null

## MAIL
## =============================================================================
echo "Add the keyboard shortcut CMD + Enter to send an email"
defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" "@\U21a9"

echo "Set email addresses to copy as 'foo@example.com' instead of 'Foo Bar <foo@example.com>'"
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

echo "Disable send and reply animations in Mail.app"
defaults write com.apple.mail DisableReplyAnimations -bool true
defaults write com.apple.mail DisableSendAnimations -bool true

## DOCK
## =============================================================================

echo "autohide dock"
defaults write com.apple.Dock autohide -bool true

echo "Remove the auto-hiding Dock delay"
defaults write com.apple.dock autohide-delay -float 0

echo "Remove the animation when hiding/showing the Dock"
defaults write com.apple.dock autohide-time-modifier -float 0

echo "set dock icon size"
defaults write com.apple.dock tilesize -int 24

echo "Don’t show recent applications in Dock"
defaults write com.apple.dock show-recents -bool false

echo "Disable hot corners"
defaults write com.apple.dock wvous-tl-corner -int 0
defaults write com.apple.dock wvous-tr-corner -int 0
defaults write com.apple.dock wvous-bl-corner -int 0
defaults write com.apple.dock wvous-br-corner -int 0
# Disable autocorrect
# defaults write NSGlobalDomain NSAutomaticSpelliPreferencesngCorrectionEnabled -bool false
#

running "Speed up Mission Control animations"
defaults write com.apple.dock expose-animation-duration -float 0.1;ok

running "Don’t group windows by application in Mission Control"
# (i.e. use the old Exposé behavior instead)
defaults write com.apple.dock expose-group-by-app -bool false;ok


echo "Enable three finger drag"
defaults write com.apple.AppleMultitouchTrackpad DragLock -bool false
defaults write com.apple.AppleMultitouchTrackpad Dragging -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
