#!/bin/sh
 
#########################################################################################################################
# First Boot script that is used along with a launchd item.  Deletes both itself and the launchd item after completion.
#########################################################################################################################
 
# Define 'kickstart' and'systemsetup' variables, built in OS X script that activates and sets options for ARD.
# Define 'networksetup'.
# Defines the location of the generic.ppd in OS X 10.6
 
kickstart="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"
systemsetup="/usr/sbin/systemsetup"
networksetup="/usr/sbin/networksetup"
genericppd="/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/PrintCore.framework/Versions/A/Resources/Generic.ppd"
scutil="/usr/sbin/scutil"
diskutil="/usr/sbin/diskutil"

####################################################
#	DETERMINE MACHINE TYPE
####################################################

# Get the model and search for Book in the result
is_laptop=$(sysctl -n hw.model | grep Book)

# If the model contains Book it's a laptop, otherwise assume it's a desktop
if [ "$IS_LAPTOP" != "" ]; then
computerModel=laptop
else
computerModel=desktop
fi

# Write the computer model to the 4th ARD computer field for later reference
defaults write /Library/Preferences/com.apple.RemoteDesktop Text4 - string "$computerModel"


# Get the computer name
compName=$(scutil --get ComputerName)

# See if the computer name contains 'Lab'
if [[ $compName == *"Lab"* ]]; then
computerType=lab
else
computerType=user
fi

# Write the computer type to the 3rd ARD computer field for later reference
defaults write /Library/Preferences/com.apple.RemoteDesktop Text3 - string "$computerType"

####################################################
#	NETWORK CONFIGURATION
####################################################
# Check for network interfaces (on some models you might end up with no network connection otherwise)
$networksetup -detectnewhardware

# Turn off firewire and thunderbolt
$networksetup -setnetworkserviceenabled FireWire off 
$networksetup -setnetworkserviceenabled "Thunderbolt Bridge" off

# Set ipV6 to LinkLocal
$networksetup -setv6LinkLocal Ethernet
$networksetup -setv6LinkLocal Wi-Fi

# Add search domains 
$networksetup -setsearchdomains Wi-Fi acad.psdn.portsmouth.k12.nh.us admin.psdn.portsmouth.k12.nh.us co.psdn.portsmouth.k12.nh.us psdn.portsmouth.k12.nh.us portsmouth.k12.nh.us
$networksetup -setsearchdomains Ethernet acad.psdn.portsmouth.k12.nh.us admin.psdn.portsmouth.k12.nh.us co.psdn.portsmouth.k12.nh.us psdn.portsmouth.k12.nh.us 

# Make sure wireless is turned on
$networksetup -setairportpower en1 on

# Connect to the proper SSID
$networksetup -setairportnetwork en1 PSDNet u2blackbird

$networksetup -ordernetworkservices Ethernet Wi-Fi "Bluetooth PAN" "Thunderbolt Bridge" Firewire


####################################################
#	TIME CONFIGURATION
####################################################
$systemsetup -settimezone  America/New_York
$systemsetup -setusingnetworktime on
$systemsetup -setnetworktimeserver 10.100.0.8
ntpdate -bvs


####################################################
#	POWER SETTINGS
####################################################
$systemsetup -setsleep Never
$systemsetup -setcomputersleep Never
$systemsetup -setdisplaysleep Never
$systemsetup -setharddisksleep Never
$systemsetup -setwakeonnetworkaccess on
pmset sleep 0
sudo pmset -a hibernatemode 0


####################################################
#	REMOTE ACCESS
####################################################
# Turn on SSH access
$systemsetup -setremotelogin on

#Enable ARD for localadmin
$kickstart -configure -allowAccessFor -specifiedUsers
$kickstart -activate -configure -access -on -users "localadmin" -privs -all -restart -agent -menu

####################################################
#	MISC
####################################################
# Make a shortcut links to Network Utility, Directory Utility, Screen Sharing, Raid Utility, and Archive Utility under "Utilities" Folder
ln -s /System/Library/CoreServices/Applications/Network\ Utility.app /Applications/Utilities/Network\ Utility.app
ln -s /System/Library/CoreServices/Applications/Directory\ Utility.app /Applications/Utilities/Directory\ Utility.app
ln -s /System/Library/CoreServices/Applications/Screen\ Sharing.app /Applications/Utilities/Screen\ Sharing.app
ln -s /System/Library/CoreServices/Applications/RAID\ Utility.app /Applications/Utilities/RAID\ Utility.app
ln -s /System/Library/CoreServices/Applications/Archive\ Utility.app /Applications/Utilities/Archive\ Utility.app
ln -s /System/Library/CoreServices/Applications/Wireless\ Diagnostics.app /Applications/Utilities/Wireless\ Diagnostics.app
ln -s /Library/Desktop\ Pictures/backgroundDefault2Wide.png /System/Library/CoreServices/DefaultDesktop.jpg

# Reveal IP address, hostname, OS version, etc. when clicking the clock in the login window
defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Set login window to display name and password fields
defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true

# Enable Fast User Switching
defaults write /Library/Preferences/.GlobalPreferences MultipleSessionEnabled -bool YES

# Hide the following applications: Game Center, Time Machine, Boot Camp
sudo chflags hidden /Applications/Game\ Center.app/
sudo chflags hidden /Applications/Utilities/Boot\ Camp\ Assistant.app/

# Download custom admin and district wallpaper
curl -o /Library/Desktop\ Pictures/admin.png http://brego/files/images/admin.png
curl -o /Library/Caches/com.apple.desktop.admin.png http://brego/files/images/default.png
curl -o /Library/Desktop\ Pictures/backgroundDefault2Wide.png http://brego/files/images/default.png

# Make sure the permissions for admin prefs launchdaemon and script are correct
sudo chmod -R 775 /usr/local/sbin

####################################################
#	LOCAL ADMINISTRATOR
####################################################
# Force creation of the home directory
createhomedir -c -u localadmin

# Add to PATH so that NCutil, tccutil & dockutil will work later
echo "export PATH=/usr/local/sbin:$PATH" >> /Users/localadmin/.bash_profile

# Create file needed to skip iCloud & Diagnostics setup on login
defaults write Users/localadmin/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool TRUE
defaults write Users/localadmin/Library/Preferences/com.apple.SetupAssistant GestureMovieSeen none
defaults write Users/localadmin/Library/Preferences/com.apple.SetupAssistant LastSeenCloudProductVersion "${sw_vers}"
touch /var/db/.AppleSetupDone
touch /var/db/.AppleDiagnosticsSetupDone

# Set owner/permissions on home directory to what we want
chown -R 499:admin /Users/localadmin
chmod -R 774 /Users/localadmin

# borrowed from timsutton
# suppress the diagnostic setup message at login
SUBMIT_TO_APPLE=NO
SUBMIT_TO_APP_DEVELOPERS=NO

PlistBuddy="/usr/libexec/PlistBuddy"
os_rev_major=`/usr/bin/sw_vers -productVersion | awk -F "." '{ print $2 }'`
if [ $os_rev_major -ge 10 ]; then
  CRASHREPORTER_SUPPORT="/Library/Application Support/CrashReporter"
  CRASHREPORTER_DIAG_PLIST="${CRASHREPORTER_SUPPORT}/DiagnosticMessagesHistory.plist"

  if [ ! -d "${CRASHREPORTER_SUPPORT}" ]; then
    mkdir "${CRASHREPORTER_SUPPORT}"
    chmod 775 "${CRASHREPORTER_SUPPORT}"
    chown root:admin "${CRASHREPORTER_SUPPORT}"
  fi

  for key in AutoSubmit AutoSubmitVersion ThirdPartyDataSubmit ThirdPartyDataSubmitVersion; do
    $PlistBuddy -c "Delete :$key" "${CRASHREPORTER_DIAG_PLIST}" 2> /dev/null
  done

  $PlistBuddy -c "Add :AutoSubmit bool ${SUBMIT_TO_APPLE}" "${CRASHREPORTER_DIAG_PLIST}"
  $PlistBuddy -c "Add :AutoSubmitVersion integer 4" "${CRASHREPORTER_DIAG_PLIST}"
  $PlistBuddy -c "Add :ThirdPartyDataSubmit bool ${SUBMIT_TO_APP_DEVELOPERS}" "${CRASHREPORTER_DIAG_PLIST}"
  $PlistBuddy -c "Add :ThirdPartyDataSubmitVersion integer 4" "${CRASHREPORTER_DIAG_PLIST}"
fi

# Remove the LaunchDaemon so the script doesn't run on subsequent boots
srm /Library/LaunchDaemons/us.nh.k12.portsmouth.firstboot.plist

cp /private/etc/sudoers /private/etc/sudoers~original
echo "%admin ALL=(ALL) NOPASSWD: ALL" >> /private/etc/sudoers


####################################################
#	LOCAL USERS & GROUPS
####################################################

# Create a local group for computer teachers
dscl . create /Groups/cteach
dscl . create /Groups/cteach RealName "Computer Teachers"
dscl . create /Groups/cteach passwd "*"
dscl . create /Groups/cteach gid 800

# Add the computer teachers group to the admin group
dscl . append /Groups/admin GroupMembership cteach
