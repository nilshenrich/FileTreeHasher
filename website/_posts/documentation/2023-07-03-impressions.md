---
layout: post
title: Impressions
author: nilshenrich
date: 2023-07-03 16:00:00 +0200
order: 3
permalink: documentation/impressions/
pin: true
---

**All images here are links to full videos.**

## Demonstration

This is how it looks generating hashes from some files:\
[![Demo video](/assets/gallery/img/demo.png){: width="500"}](../../assets/gallery/vid/demo.mp4)

## Select files

Files can be selected in two ways:
1. Selecting an entire folder loads all its nested files.
1. Selecting one or more files individually.

### Load folder

Load entire folder containing file tree:\
[![Load folder](/assets/gallery/img/add-folder.png){: width="250"}](../../assets/gallery/vid/add-folder.mp4)

### Load files

Load some files individually:\
[![Load folder](/assets/gallery/img/add-files.png){: width="250"}](../../assets/gallery/vid/add-files.mp4)

## Change hash algorithm

If a new hash algorithm is selected, the hash is regenerated automatically for corresponding file.\
A hash algorithm can be changed in multiple ways:
1. For a single file: Hash regeneration for this file is triggered.
1. For an entire folder: Hashes of all contained files are updated and regenerated.
1. Globally: Hash algorithm is updated for all loaded files.

Change hash algorithm triggering regeneration:\
[![Load folder](/assets/gallery/img/change-hash.png){: width="250"}](../../assets/gallery/vid/change-hash.mp4)

## Hash comparison

For each loaded file a input box is provided to enter a string for comparing with the generated hash. This comparison is triggered automatically on change of input or hash generation. Depending on comparison result the generated hash is colored green or red:\
[![Load folder](/assets/gallery/img/change-comp.png){: width="250"}](../../assets/gallery/vid/change-comp.mp4)

## Hash file

Generated hashes can be saved in hash list files.\
Each loaded folder will create a separate hash file. The single files hashes are saved in a combined hash file.

### Create hash file

Creating a hash list file from generated hashes and used algorithms:\
[![Load folder](/assets/gallery/img/save-hashfile.png){: width="250"}](../../assets/gallery/vid/save-hashfile.mp4)

### Load hash file

Loading a hash list file overwriting hash algorithms and comparison inputs:\
[![Load folder](/assets/gallery/img/load-hashfile.png){: width="250"}](../../assets/gallery/vid/load-hashfile.mp4)
