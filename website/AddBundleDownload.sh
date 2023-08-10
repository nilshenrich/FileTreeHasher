#!/bin/bash

# Inputs:
#   - version
#   - bundles dir
#   - description text

# Get version, bundles and description from parameters
version="${1//\//_}"    # Replace / with _
bundlesDir=$2
description=$3

# Get date and time
currentDate=`date +%Y-%m-%d`
currentTime=`date +%H:%M:%S`
timeZone=`date +%z`

# # Create new folder for version
postDir="_posts/downloads"
assetsDir="assets/downloads/$version"
mkdir -p $postDir
mkdir -p $assetsDir

# Move bundles to assets
mv $bundlesDir/bundle-* $assetsDir/

# Create file name from date and version
filename="$postDir/$currentDate-$version.md"

# Get subtitle from description (First line without single quotes)
subtitle=`echo "$description" | head -1`

# Transform description: Add \ before single line breaks
echo -e """$description""" > description-temp.txt
sed -i -E ':a;N;$!ba;s/([^\n])\n([^\n])/\1\\\n\2/g' description-temp.txt
content=`cat description-temp.txt`
rm description-temp.txt

# Create new bundle file
echo -e """---
layout: bundle
title: '$version'
subtitle: 'subtitle'
author: nilshenrich
date: $currentDate $currentTime $timeZone
permalink: 'downloads/$version/'
pin: false
---

$content
""" > $filename
