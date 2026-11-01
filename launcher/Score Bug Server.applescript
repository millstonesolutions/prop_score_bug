-- Score Bug Server: one click starts the local web server for the score bug page,
-- the next click stops it. Built into /Applications by launcher/install.sh, which
-- replaces __REPO_DIR__ with the folder this repository lives in.

property repoDir : "__REPO_DIR__"
property serverPort : "8765"
property appTitle : "Score Bug Server"

on listeningPids()
	return do shell script "/usr/sbin/lsof -nP -t -iTCP:" & serverPort & " -sTCP:LISTEN 2>/dev/null || true"
end listeningPids

on lanAddress()
	return do shell script "/usr/sbin/ipconfig getifaddr en0 2>/dev/null || /usr/sbin/ipconfig getifaddr en1 2>/dev/null || echo"
end lanAddress

on run
	if listeningPids() is not "" then
		do shell script "/usr/sbin/lsof -nP -t -iTCP:" & serverPort & " -sTCP:LISTEN | xargs kill"
		display notification "Stopped. Click again to start it." with title appTitle
		return
	end if

	-- Prefer Homebrew's Python; /usr/bin/python3 works too once the Command Line Tools are installed.
	do shell script "if [ -x /opt/homebrew/bin/python3 ]; then P=/opt/homebrew/bin/python3; else P=/usr/bin/python3; fi; " & ¬
		"cd " & quoted form of repoDir & " && nohup \"$P\" -m http.server " & serverPort & ¬
		" --bind 0.0.0.0 > /dev/null 2>&1 &"
	delay 1
	if listeningPids() is "" then
		display dialog "The server didn't start. Is Python 3 installed, and is port " & serverPort & " free?" & return & return & ¬
			"Folder: " & repoDir buttons {"OK"} default button "OK" with title appTitle with icon caution
		return
	end if

	set lan to lanAddress()
	set msg to "The score bug server is running." & return & return & ¬
		"This Mac:  http://localhost:" & serverPort & "/" & return
	if lan is not "" then set msg to msg & "Network:  http://" & lan & ":" & serverPort & "/" & return
	set msg to msg & return & "Open Score Bug Server again to stop it."
	set reply to display dialog msg buttons {"Open Preview", "OK"} default button "OK" with title appTitle
	if button returned of reply is "Open Preview" then
		open location "http://localhost:" & serverPort & "/index.html?preview=1"
	end if
end run
