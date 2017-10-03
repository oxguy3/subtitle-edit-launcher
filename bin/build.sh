#!/usr/bin/env bash

APPNAME="Subtitle Edit Launcher"

# make sure we're in the right place
# TODO: maybe make this check more thorough
if [ ! -d ".git" ]; then
    echo "ERROR: This script must be run from the root of the repository."
    exit
fi

# clear out old build
rm -r dist/*
mkdir -p "dist/$APPNAME.app/"

# copy files
cp -r app/* "dist/$APPNAME.app/"

# compile all applescript
cd "dist/$APPNAME.app/Contents/Resources/Scripts/"
for f in *.applescript
do
    osacompile -o "`basename -s .applescript "$f"`.scpt" "$f"
    rm "$f"
done
