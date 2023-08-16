#!/bin/bash

# Installation script must be executed with root permissions
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit -1
fi

# Installation path
appname="filetreehasher"
installpath="/opt/$appname"

# Remove desktop entry
rm -f /usr/share/applications/$appname.desktop

# Remove symbolic link
rm -f /usr/local/bin/$appname

# Remove bundle
rm -rf $installpath/
