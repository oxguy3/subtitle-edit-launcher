-- make folders for this app's files
tell application "Finder"
	-- create root config folder
	set applicationSupport to path to application support from user domain
	set configFolderName to "io.schiff.subtitleedit.maclauncher"
	set configFolderPath to (POSIX path of applicationSupport) & configFolderName & "/"
	if not (exists configFolderPath as POSIX file) then
		make new folder at applicationSupport with properties {name:configFolderName}
	end if
	set configFolder to folder configFolderName of applicationSupport

	-- create folder for Subtitle Edit executables
	set seFolderName to "SubtitleEdit"
	set seFolderPath to configFolderPath & seFolderName & "/"
	if not (exists seFolderPath as POSIX file) then
		make new folder at configFolder with properties {name:seFolderName}
	end if
end tell

-- find versions of Wine in our PATH
try
	set winePaths to paragraphs of (do shell script "/usr/bin/which -a wine")
on error
	set winePaths to {}
end try

-- find versions of Wine installed via official Wine installers or WineBottler
set altWinePaths to paragraphs of "/Applications/Wine Stable.app/Contents/Resources/wine/bin/wine
/Applications/Wine Staging.app/Contents/Resources/wine/bin/wine
/Applications/Wine Development.app/Contents/Resources/wine/bin/wine
/Applications/Wine.app/Contents/Resources/bin/wine"

repeat with thePath in altWinePaths
	tell application "System Events"
		if exists file thePath then
			set end of winePaths to thePath as text
		end if
	end tell
end repeat

-- figure out which version of Wine we're using
if (count of winePaths) = 0 then
	-- if no versions of Wine are found, prompt user to install Wine
	set downloadWineAnswer to the button returned of (display alert "Could not find Wine" message "Wine must be installed in order to run Subtitle Edit.

Would you like to visit the official download website for Wine? (I recommend downloading and running \"Installer for 'Wine Stable'\")" as critical buttons {"Exit", "Download Wine"} default button 2)
	if downloadWineAnswer = "Download Wine" then
		open location "https://dl.winehq.org/wine-builds/macosx/download.html"
	end if
	set myWinePath to false
else if (count of winePaths) = 1 then
	-- if exactly one version of Wine is found, use that version without prompt
	set myWinePath to item 1 of winePaths as text
else
	-- if multiple versions of Wine are found, ask the user which one they want to use
	set myWinePath to (choose from list winePaths with prompt "Multiple versions of Wine are installed. Please select which version you would like to use.")

	--TODO: add option to remember which Wine they like
	if myWinePath ≠ false then
		set myWinePath to item 1 of myWinePath
		--set useSameWineAnswer to the button returned of (display dialog "Would you like to use \"" & myWinePath & "\" every time?" buttons {"No, ask me every time", "Yes"} default button 2)
	end if
end if

-- we can only continue if we have a usable Wine executable
if myWinePath ≠ false then

	-- check if SubtitleEdit.exe is already installed
	set seExecutableName to "SubtitleEdit.exe"
	set seExecutablePath to seFolderPath & seExecutableName
	set seExecutableExists to false
	tell application "System Events"
		set seExecutableExists to exists file seExecutablePath
	end tell

	-- if Subtitle Edit isn't installed, download it from GitHub
	if not seExecutableExists then

		-- check GitHub API for latest release of Subtitle Edit
		do shell script "curl -L https://api.github.com/repos/SubtitleEdit/subtitleedit/releases/latest -o \"" & configFolderPath & "latest.json\""
		set jq to path to resource "bin/jq"
		set downloadVersionTag to (do shell script "cat \"" & configFolderPath & "latest.json\" | \"" & (POSIX path of jq) & "\" -r '.tag_name'")

		-- create config file
		tell application "System Events"
			set configFilePath to (configFolder as text) & "config.plist"
			set configDict to make new property list item with properties {kind:record}
			set configFile to make new property list file with properties {contents:configDict, name:configFilePath}

			tell property list items of configFile
				make new property list item at end with properties {kind:string, name:"MacLauncherVersion", value:"1.0"}
				make new property list item at end with properties {kind:string, name:"SubtitleEditVersion", value:downloadVersionTag}
			end tell
		end tell

		-- extract download URLs from GitHub API response
		set downloadTypes to {"", "FI", "PL"}
		set downloadUrls to {}
		repeat with suffix in downloadTypes
			set end of downloadUrls to do shell script "cat \"" & configFolderPath & "latest.json\" | \"" & (POSIX path of jq) & "\" -r '.assets | map(select(.name | test(\"^SE\\\\d+\\\\" & suffix & ".zip$\")))[0].browser_download_url'"
		end repeat

		-- build list of download options to present to the user
		set availableDownloadNames to {}
		if item 1 of downloadUrls ≠ "null" then
			set end of availableDownloadNames to "Basic"
		end if
		if item 2 of downloadUrls ≠ "null" then
			set end of availableDownloadNames to "With Finnish dictionaries"
		end if
		if item 3 of downloadUrls ≠ "null" then
			set end of availableDownloadNames to "With Polish dictionaries"
		end if

		if (count of availableDownloadNames) = 0 then
			return display alert "Can't download Subtitle Edit" message "The latest release of Subtitle Edit on GitHub has no downsloads that this app knows how to install. Tweet a screenshot of this error to @oxguy3 and he'll get it fixed in a jiffy." as critical
		end if

		-- prompt user to pick version of Subtitle Edit to install
		set myDownloadName to false
		repeat while myDownloadName = false
			set myDownloadName to (choose from list availableDownloadNames with prompt "Which version of Subtitle Edit would you like to download?")
		end repeat
		set myDownloadName to item 1 of myDownloadName
		set myDownloadUrl to false
		if myDownloadName = "Basic" then
			set myDownloadUrl to item 1 of downloadUrls as text
		else if myDownloadName = "With Finnish dictionaries" then
			set myDownloadUrl to item 2 of downloadUrls as text
		else if myDownloadName = "With Polish dictionaries" then
			set myDownloadUrl to item 3 of downloadUrls as text
		end if

		-- download and unzip Subtitle Edit file
		-- TODO: make really really sure there's no way those rm commands can go rogue
		do shell script "curl -L \"" & myDownloadUrl & "\" -o \"" & configFolderPath & "download.zip\""
		do shell script "rm -r \"" & seFolderPath & "\""
		do shell script "unzip \"" & configFolderPath & "download.zip\" -d \"" & seFolderPath & "\""
		do shell script "rm \"" & configFolderPath & "latest.json\""
		do shell script "rm \"" & configFolderPath & "download.zip\""
	end if

	-- run Subtitle Edit
	do shell script "\"" & myWinePath & "\" \"" & seExecutablePath & "\" > /dev/null 2>&1 &"

end if
