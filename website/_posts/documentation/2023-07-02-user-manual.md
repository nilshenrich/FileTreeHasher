---
# TODO: More details
layout: post
title: User Manual
author: nilshenrich
date: 2023-07-02 16:00:00 +0200
order: 2
permalink: documentation/user-manual/
pin: true
---

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
