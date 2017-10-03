#!/usr/bin/env bash

APPNAME="Subtitle Edit Launcher"
VERSIONNO="$1"

# make sure we're in the right place
# TODO: maybe make this check more thorough
if [ ! -d ".git" ]; then
    echo "ERROR: This script must be run from the root of the repository."
    exit
fi

# build it
./bin/build.sh

# make the dmg
cd dist/
create-dmg "$APPNAME.app"
