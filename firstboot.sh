#!/bin/sh
 
###
# First Boot script that is used along with a launchd item.  Delets both itself and the launchd item after completion.
###
 
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

$networksetup -setairportpower en1 on
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

# Hide the following applications: Game Center, Time Machine, Boot Camp
sudo chflags hidden /Applications/Game\ Center.app/
# sudo chflags hidden /Applications/Time\ Machine.app/
sudo chflags hidden /Applications/Utilities/Boot\ Camp\ Assistant.app/

# Download custom admin and district wallpaper
curl -o /Library/Desktop\ Pictures/admin.png http://brego/nobrain.png
curl -o /Library/Caches/com.apple.desktop.admin.png http://brego/backgroundDefault2Wide.png
curl -o /Library/Desktop\ Pictures/backgroundDefault2Wide.png http://brego/backgroundDefault2Wide.png


# Add osascript & terminal to the Accessability database
sudo tccutil.py -i /usr/bin/osascript
sudo tccutil.py --insert com.apple.Terminal

# Remove the LaunchDaemon so the script doesn't run on subsequent boots
srm /Library/LaunchDaemons/us.nh.k12.portsmouth.firstboot.plist
