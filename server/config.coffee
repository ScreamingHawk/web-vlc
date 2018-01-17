module.exports =
	vlc:
		# CLI command to call VLC
		command: "C:\\Program Files (x86)\\VideoLAN\\VLC\\vlc.exe"
		http:
			# https://wiki.videolan.org/VLC_HTTP_requests/
			url: "http://localhost:8080/requests/status.xml"
			password: "XXXXXXXX"
		fullscreen: true
		playAndExit: true
	server:
		port: 3000
		logLevel: "debug"
	files:
		# The locations of the video files
		locations: [
				"E:\\Videos\\Anime"
				"C:\\Users\\MichaelSta\\Videos"
			]
	api:
		omdb:
			url: "http://www.omdbapi.com/"
			key: "XXXXXXXX"
