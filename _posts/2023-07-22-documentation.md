---
title: Documentation
author: Nils Henrich
date: 2023-07-22 22:04:25 +0200
pin: true
---

## Introduction

If you are as computer fascinated as I am, you might have the same issue I had:

I created myself a bootable USB stick containing many different operating systems ready for live boot or installation. To do so I had to download all the desired ISO-files from the official download pages. To make sure the files were downloaded properly over my weak home connection, creating and checking a hash is highly recommended. So I searched the internet for a free tool to generate hashes from files and found so many nice looking tools. So I took one of them and started to hash my downloaded files and checked the hash code.

But all tools I found had a common annoying issue to me:

I always have to select all files to hash manually and compare the hash code by hand. This can be very annoying when having many files to hash of big size. The facts that OS manufacturers don't provide hashes from the same algorithm and that hashing files of big size takes a long time made me creating my own file hashing and comparing tool.

The goal of this tool is the following:\
I wanted a tool I can give many big files to be hashed (probably using different hash algorithms), enter the comparison hashes somewhere and let the tool do the whole rest for me, so I can leave my desk for some time and when I'm back I want to see what files are proper or corrupted.

You might find this graphical application a bit ugly, simple or unintuitive. That's because as a hacker I put my focus on functionality and reliability more than on styling. If you have any hints for styling improvements to make my app more beautiful, please feel free to let me know.

## Quick overview

This tool called **File Tree Hasher** can load a complete folder with all its containing subfolders and files to generate hashes for all those loaded files. Beside that it can also load single files for hashing.

The used hash algorithm can be chosen for each file individually. To have deeper information about hashing and hash algorithms please refer to [Hash generation](#hash-generation).

File hashing is one feature part of **File Tree Hasher**, the other part is hash comparison including saving and loading hash lists. Each file has a text input where a comparison hash can be entered. Also a hash list can be created for a folder of hashed files. Loading this hash list into comparison view is also possible. This is good for checking file transfer over a network or something like that.

## Features

### Hash generation

Using **File Tree Hasher** you are able to generate hash for files of any type and size. The following hash algorithms can be selected:
- MD5
- SHA1
- SHA256
- SHA384
- SHA512

The hash algorithm to use can be selected for each file individually.\
If a file is added or the hash algorithm is changed, the hash generation starts automatically.

It is possible to select a folder from your file system. Doing so, **File Tree Hasher** loads all files located in the selected folder and its subfolders and generates hashes with selected hash algorithm.

Alternatively it is also possible to load one or multiple single files from your file system. Single files are hashed automatically as well on loading or change of hash algorithm.

### Hash comparison

Beside generating hashes from files, **File Tree Hasher** also provides a text input for each loaded file to paste a comparison hash into. This comparison hash is automatically compared to the generated hash without case sensitivity.

If a comparison hash is placed in the comparison input, the generated hash is colored either green or red depending on the comparison result. This feature lets you directly see which hashes match and which don't.

### Hash list

When it comes to transfering folders, it could be interesting to hasve a list of many files and their hash codes, so a folder copy can be verified easily.

That's why **File Tree Hasher** comes up with the hash list feature.

#### Hash list format

Here you can see an example for a hash list generated for a folder:
```
*** File Tree Hasher ***
Author: Nils Henrich
Website: https://github.com/nilshenrich/FileTreeHasher
Version: <version>

/path/to/my/folder
da39a3ee5e6b4b0d3255bfef95601890afd80709,sha1,"top-file"
d41d8cd98f00b204e9800998ecf8427e,md5,"top-folder/sub-file"
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855,sha256,"top-folder/sub-file-2"
b2f5ff47436671b6e533d8dc3614845d,md5,"top-folder-2/sub-folder/sub-sub-file"
```

A hash list file has the extension ".hash" and can be opened using a regular text editor or a CSV editor. Using a CSV editor, the following settings should be used for optimal readability:
- field delimiter: **,**
- text delimiter: **"**

The hash file is made prom two parts: A header with general information about the **File Tree Hasher** itself and the actual hash information. The hash information always has three columns: generated hash, used hash algorithm, path to hashed file.

When creating a hash list for a loaded folder, the absolute file path to this folder is given and for each hashed file the relative file path from top-level folder is defined.

When creating a hash list from single files, all files are defined via their absolute file paths.

#### Create a hash list

Creating a hash list is very easy. As soon as all hashes are generated, the button for saving hash lists can be clicked. This opens a dialog to select the hash lists storage paths for each loaded folder and for all loaded single files together. By clicking the apply button, all hash lists are created and saved.

#### Load a hash list

For verifying files or folders containing files, a previously created hash list can be loaded into the current session. When selecting one ore more hash list files, **File Tree Hasher** automatically finds the matching files if loaded and updates the comparison inputs. If the hash algorithm from the loaded hash list differs from currently used hash algorithm, this hash is regenerated and checked automatically.
