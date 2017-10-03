# Subtitle Edit Launcher

This is a wrapper application that makes it very easy to run Subtitle Edit on Mac OS X / macOS. It uses Wine to run the Windows app on Mac.

## Installation

1. Install Wine (if you don't have it already). The easiest way to get it is to visit [the official download site](https://dl.winehq.org/wine-builds/macosx/download.html), then download and run "Installer for 'Wine Stable'". (for nerds: if you installed Wine with Homebrew or MacBottler, that should work as well)
1. Download [the latest version of this repository](https://github.com/oxguy3/subtitle-edit-launcher/archive/master.zip), unzip it, and move "Subtitle Edit Launcher.app" to your Applications folder (or wherever you like).
1. Run "Subtitle Edit Launcher.app"! The first time it runs, it'll set itself up with [the latest version of Subtitle Edit](https://github.com/SubtitleEdit/subtitleedit/releases), allowing you to pick which version you want. It'll take a few moments to download, and then it'll launch Subtitle Edit (which will also take a few moments to start).

## Troubleshooting

Subtitle Edit Launcher stores all of its files in `~/Library/Application Support/io.schiff.subtitleedit.maclauncher`, so if anything goes wrong, you might try deleting that directory and starting the app again. The easiest way to do that is to open the Terminal application and run this command:

```
rm -r ~/Library/Application Support/io.schiff.subtitleedit.maclauncher
```

Inside that directory, there's a config.plist file that stores info for the launcher (this is not actually used yet -- it gets written the first time you run it and never read). There's also a folder called SubtitleEdit, which is where the portable version of Subtitle Edit is downloaded to.

During download of Subtitle Edit, this directory will also briefly contain latest.json (which is retrieved [from GitHub's API](https://api.github.com/repos/SubtitleEdit/subtitleedit/releases/latest)) and download.zip (the zipped version of Subtitle Edit.)

## To-do list

* Check for updates to Subtitle Edit on launch.
* Allow user to save their preference for which Wine executable to use (if they have multiple Wine instances installed).
* Get some sort of progress indicator for when Subtitle Edit is downloading or launching.
* Create some sort of interface for editing preferences (having users edit config.plist is not ideal).
* Build proper .DMG files to release the app in.
* Add option to install mplayer.
* More thorough testing (what happens when internet/GitHub is down? are there any missing dependencies for Wine? etc)
* i18n of dialog messages?

## Contributing

To contribute to this repository, you'll want to edit files in _app/_. The AppleScript code can be found in _app/Contents/Resources/Scripts/_. To build the app, cd to the root of the respository and run `./bin/build.sh`, and the app will be built inside _dist/_.

All contributions to this project will be licensed under GNU GPL v3 (see below).

## License

Subtitle Edit Launcher
Copyright (C) 2017 Hayden Schiff

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

### Licenses for other components

[Subtitle Edit](https://github.com/SubtitleEdit/subtitleedit) is also released under GNU General Public License version 3.0.

This launcher also includes a compiled version of [jq](https://stedolan.github.io/jq/) (used for parsing the GitHub API response), which is released under MIT License.
