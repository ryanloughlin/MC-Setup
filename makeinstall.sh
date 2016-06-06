#!/bin/bash

version=$(date +"%Y%m%d")

# Create the folder structure for the package
echo "Creating folders..."
mkdir -p ROOT/Users/localadmin/Library/LaunchDaemons
mkdir -p ROOT/Library/Scripts/PSDN
mkdir ROOT/Library/LaunchDaemons

# Move the files where they need to be
echo "Moving files..."
mv us.nh.k12.portsmouth.adminprefs.plist ROOT/Users/localadmin/Library/LaunchDaemons/
mv us.nh.k12.portsmouth.firstboot.plist ROOT/Library/LaunchDaemons/
mv firstboot.sh ROOT/Library/Scripts/PSDN/
mv admin_default_prefs.sh ROOT/Users/localadmin/.admin_default_prefs.sh

# Set appropriate permissions
echo "Setting permissions..."
sudo chown -R root:wheel ROOT
sudo chmod -R 754 ROOT
sudo chown -R 499:admin ROOT/Users/localadmin
sudo chmod -R 774 ROOT/Users/localadmin

# Build the package
echo "Building package..."
sudo pkgbuild --root ROOT --identifier us.nh.k12.portsmouth.firstboot --version $version firstboot.pkg
