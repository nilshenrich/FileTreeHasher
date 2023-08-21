#!/bin/bash

# Installation script must be executed with root permissions
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit -1
fi

# Get directory of this file
currentDir=$(dirname $(readlink -f $0))

# Installation path
binname="file_tree_hasher"
appname="filetreehasher"
installpath="/opt/$appname"

# Get version number
version=`cat $currentDir/../../build/linux/x64/release/bundle/data/flutter_assets/version.json | jq -r '.version'`

# Create installation directory
mkdir -p $installpath

# Copy bundle folder
cp -r $currentDir/../../build/linux/x64/release/bundle/* $installpath/

# Rename binary file
mv $installpath/$binname $installpath/$appname

# Set permissions
chown -R root:root $installpath/

# Create symbolic link to binary folder
ln -s $installpath/$appname /usr/local/bin/$appname

# Create desktop entry
convert $currentDir/../../assets/img/logo.png -resize 256x256 $installpath/favicon.png
desktopentry="[Desktop Entry]\nVersion=$version\nType=Application\nName=File Tree Hasher\nExec=$installpath/$appname\nIcon=$installpath/favicon.png\nTerminal=false\nCategories=Utility;"
echo -e $desktopentry | tee /usr/share/applications/$appname.desktop > /dev/null

# Done
echo "Installation done. Start using command $appname"
