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

# Create installation directory
mkdir -p $installpath

# Copy bundle folder
cp -r $currentDir/../../build/linux/x64/release/bundle/* $installpath/

# Rename binary file
mv $installpath/$binname $installpath/$appname

# Set permissions # TODO: rwx rights?
chown -R root:root $installpath/

# Create symbolic link to binary folder
ln -s $installpath/$appname /usr/local/bin/$appname

echo "Installation done. Start using command $appname"
