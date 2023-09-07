---
layout: post
title: Introduction
author: nilshenrich
date: 2023-07-01 16:00:00 +0200
order: 1
permalink: documentation/introduction/
pin: true
---

## Motivation

If you are as computer fascinated as I am, you might have the same issue I had:

I created myself a bootable USB stick containing many different operating systems ready for live boot or installation. To do so I had to download all the desired ISO-files from the official download pages. To make sure the files were downloaded properly over my weak home internet connection, creating and checking hashes is highly recommended. So I searched the internet for a free tool to generate hashes from files and found so many nice looking tools. So I took one of them and started to hash my downloaded files and checked the hash code.

But all tools I found had a common annoying issue to me:

I always have to select all files to hash manually and compare the hash code by hand. This can be very annoying when having many files of big size to hash. The facts that OS manufacturers don't provide hashes from the same algorithm and that hashing files of big size takes a long time made me creating my own file hashing and comparing tool.

The goal of this tool is the following:\
I wanted a tool I can give many big files to be hashed (probably using different hash algorithms), enter the comparison hashes somewhere and let the tool do the whole rest for me, so I can leave my desk for some time and when I'm back I want to see what files are proper or corrupted.

You might find this graphical application a bit ugly, simple or unintuitive. That's because as a hacker I put my focus on functionality and reliability more than on styling. If you have any hints for styling improvements to make my app more beautiful, please feel free to let me know.

## Quick overview

This tool called **File Tree Hasher** can load a complete folder with all its containing subfolders and files to generate hashes for all those loaded files. Beside that it can also load single files for hashing.

The used hash algorithm can be chosen for each file individually. To have deeper information about hashing and hash algorithms please refer to [Hash generation](../user-manual/#hash-generation).

File hashing is one feature part of **File Tree Hasher**, the other part is hash comparison including saving and loading hash lists. Each file has a text input where a comparison hash can be entered. Also a hash list can be created for a folder of hashed files. Loading this hash list into comparison view is also possible. This is good for checking file transfer over a network or something like that.
