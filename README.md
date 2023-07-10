# File Tree Hasher

\<gif for overview\>

- [Introduction](#introduction)
- [Quick overview](#quick-overview)
- [Features](#features)
    - [Hash generation](#hash-generation)
    - [Hash comparison](#hash-comparison)
    - [Hash list](#hash-list)
- [Gallery](#gallery)
- [Release notes](#release-notes)
- [Known issues](#known-issues)

## Introduction

If you are as computer fascinated as I am, you might have the same issue I had:

I created myself a bootable USB stick containing many different operating systems ready for live boot or installation. To do so I had to download all the desired ISO-files from the official download pages. To make sure the files were downloaded properly over my weak home connection, creating and checking a hash is highly recommended. So I searched the internet for a free tool to generate hashes from files and found so many nice looking tools. So I took one of them and started to hash my downloaded files and checked the hash code.

But all tools I found had a common issue that annoys me:

I always have to select all files to hash manually and compare the hash code by hand. This can be very annoying when having many files to hash of big size. The facts that OS manufacturers don't provide hashes from the same algorithm and that hashing files of big size takes a long time made me creating my own file hashing and comparing tool.

The goal of this tool is the following:\
I wanted a tool I can give many big files to be hashed (probably using different hash algorithms), enter the comparison hashes somewhere and let the tool do the whole rest for me, so I can leave my desk for some time and when I'm back I want to see what files are proper or corrupted.

## Quick overview

This tool called **File Tree Hasher** can load a complete folder with all its containing subfolders and files to generate hashes for all those loaded files. Beside that it can also load single files for hashing.

The used hash algorithm can be chosen for each file individually. To have deeper information about hashing and hash algorithms please refer to [Hash generation](#hash-generation).

File hashing is one feature part of **File Tree Hasher**, the other part is hash comparison including saving and loading hash lists. Each file has a text input where a comparison hash can be entered. Also a hash list can be created for a folder of hashed files. Loading this hash list into comparison view is also possible. This is good for checking file transfer over a network or something like that.

## Features

### Hash generation

### Hash comparison

### Hash list

## Gallery

## Release notes

## Known issues
