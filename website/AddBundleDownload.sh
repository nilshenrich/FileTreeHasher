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

# Create new bundle file
echo -e """---
layout: bundle
title: $version
subtitle: $description
author: nilshenrich
date: $currentDate $currentTime $timeZone
order: $(($NumPrev + 1))
permalink: downloads/$version/
pin: false
---
$description""" > $filename
