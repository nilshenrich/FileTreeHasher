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

# Count number of previous releases
NumPrev=`ls $postDir | wc -l`

# Move bundles to assets
mv $bundlesDir/bundle-* $assetsDir/

# Create file name from date and version
filename="$postDir/$currentDate-$version.md"

# Get subtitle from description (First line without single quotes)
subtitle=`echo "$description" | head -1`

# Transform description: Add \ before single line breaks
# TODO: Don't touch double line breaks
content=`echo "$description" | sed ':a;N;$!ba;s/\n/\\\n/g'`

# Create new bundle file
echo -e """---
layout: bundle
title: '$version'
subtitle: '$subtitle'
author: nilshenrich
date: $currentDate $currentTime $timeZone
order: $(($NumPrev + 1))
permalink: 'downloads/$version/'
pin: false
---
$content""" > $filename
