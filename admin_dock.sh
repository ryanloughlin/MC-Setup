#!/bin/bash

# ==============================================
# Dock
# ==============================================

# Use dockutil to empty and then rebuild the dock
dockutil --remove all
dockutil --add /Applications/Utilities/System\ Information.app
dockutil --add /Applications/Safari.app
dockutil --add /Applications/Utilities/Terminal.app
dockutil --add /Applications/Utilities/Console.app
dockutil --add /Applications/Utilities/Activity\ Monitor.app
dockutil --add /Applications/Utilities/Directory\ Utility.app
dockutil --add /Applications/Utilities/Network\ Utility.app
dockutil --add /Applications/Utilities/Airport\ Utility.app
dockutil --add /Applications/Utilities/Wireless\ Diagnostics.app
dockutil --add /Applications/Utilities/Disk\ Utility.app
dockutil --add /Applications/Utilities/Keychain\ Access.app
dockutil --add /Applications/Time\ Machine.app
dockutil --add /Applications/Utilities/Screen\ Sharing.app
dockutil --add /Applications/Utilities/Migration\ Assistant.app
dockutil --add /Applications/System\ Preferences.app
dockutil --add /Applications/coconutBattery.app
dockutil --add /Applications/TextEdit.app
dockutil --add /Applications/AppStore.app
dockutil --add /Applications/Managed\ Software\ Center.app

# Enable highlight hover effect for the grid view of a stack (Dock)
defaults write com.apple.dock mouse-over-hilte-stack -bool true

# Set the icon size of Dock items to 36 pixels
defaults write com.apple.dock tilesize -int 24

# Set the dock position to left
defaults write com.apple.dock orientation -string left

# Enable spring loading for all Dock items
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true

# Don’t animate opening applications from the Dock
defaults write com.apple.dock launchanim -bool false

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1

# Don’t group windows by application in Mission Control (i.e. use the old Exposé behavior instead)
defaults write com.apple.dock expose-group-by-app -bool false

# Don’t show Dashboard as a Space
defaults write com.apple.dock dashboard-in-overlay -bool true

# Remove the auto-hiding Dock delay
defaults write com.apple.Dock autohide-delay -float 0

# Remove the animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0

# Enable the 2D Dock
defaults write com.apple.dock no-glass -bool true

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool false

# Make Dock icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true

killall Dock

say "Dock configured"
