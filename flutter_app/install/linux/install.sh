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

# Bundle path
p_bundlefiles=$currentDir/../../build/linux/x64/release/bundle/*
p_bundleIcon=$currentDir/../../assets/img/logo.png

# Create installation directory
mkdir -p $installpath

# Copy bundle folder
cp -r $p_bundlefiles $installpath/

# Rename binary file
mv $installpath/$binname $installpath/$appname

# Set permissions:
# Owner:    root
# Folders:  rwx|w-x|r-x 755
# Files:    rw-|r--|r-- 644
# binary:   rwx|r-x|r-x 755
chown -R root:root $installpath/
find $installpath -type d -exec chmod 755 {} \;
find $installpath -type f -exec chmod 644 {} \;
chmod 755 $installpath/$appname

# Create symbolic link to binary folder
ln -s $installpath/$appname /usr/local/bin/$appname

# Create desktop entry by copying the desktop file
convert $p_bundleIcon -resize 256x256 $installpath/favicon.png
echo -e """[Desktop Entry]
Type=Application
Name=File Tree Hasher
GenericName=File hashing and comparing tool
Icon=$installpath/favicon.png
Comment=Load a whole folder or multiple single files, generate all file hashes recurvely, compare in a file tree and store or load hash lists
Exec=$installpath/$appname
Terminal=false
Categories=Utility;
""" > /usr/share/applications/$appname.desktop

# Done
echo "Installation done. Start using command $appname"
