#!/bin/bash

# Get root directory
root_dir="$(git rev-parse --show-toplevel)"

# Copy all hook files
cp $root_dir/hooks/*-* $root_dir/.git/hooks/
chmod 775 $root_dir/.git/hooks/*
