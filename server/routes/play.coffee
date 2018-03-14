log = require 'winston'
express = require 'express'
spawn = require 'cross-spawn'
request = require 'request'
path = require 'path'
{ parseString } = require 'xml2js'

router = express.Router()
exports = module.exports = router

config = null

exports.init = (c)->
	config = c

nowPlaying = null

# Request vlc to open a file
router.post '/', (req, res)->
	log.debug req.body
	log.debug "Playing video at path #{req.body?.path}"
	if !req.body?.path?
		# Path required
		log.warn "Video path not supplied"
		res.sendStatus 400
		return

	# Build vlc command
	cmdFlags = ["--one-instance", "--no-playlist-enqueue"]
	if config?.vlc.fullscreen
		cmdFlags.push "-f"
	if config?.vlc.playAndExit
		cmdFlags.push "--play-and-exit"
	cmdFlags.push "#{req.body.path}"

	# Open vlc
	log.debug "Running command #{config?.vlc.command} with flags #{cmdFlags}"
	child = spawn config?.vlc.command, cmdFlags
	child.on 'error', (err)->
		log.error "VLC error: #{err}"
	child.on 'close', (err)->
		nowPlaying = null

	# Get filename
	parts = req.body.path.split path.sep
	nowPlaying = parts[parts.length - 1]

	res.sendStatus 200

# Get VLC status
router.get '/status', (req, res)->
	vlcApi null, null, (ok, xmlStatus)->
		if ok && xmlStatus?
			parseString xmlStatus, (err, status)->
				res.json status.root
		else
			res.sendStatus 503

# Get the filename of the currently playing video
router.get '/nowplaying', (req, res)->
	if !nowPlaying
		res.sendStatus 404
	else
		res.send
			filename: nowPlaying

# Change volume
router.post '/volume', (req, res)->
	if !req.body?.volume?
		log.warn "Volume not supplied"
		res.sendStatus 400
		return
	vol = null
	if req.body.volume == "up"
		log.debug "Upping volume"
		vol = "+10"
	else if req.body.volume == "down"
		log.debug "Lowering volume"
		vol = "-10"
	else if isNaN req.body.volume
		log.warn "Volume value invalid"
		res.sendStatus 400
	else
		log.debug "Setting volume"
		vol = req.body.volume
	# Call volume API
	vlcApi "volume", vol, (ok)->
		res.sendStatus if ok then 200 else 503

# Seek
router.post '/seek', (req, res)->
	if !req.body?.seek?
		log.warn "Seek value not supplied"
		res.sendStatus 400
		return
	# Call seek API
	vlcApi "seek", req.body.seek, (ok)->
		res.sendStatus if ok then 200 else 503

# Pause
router.post '/pause', (req, res)->
	# Call pause API
	vlcApi "pl_pause", null, (ok)->
		res.sendStatus if ok then 200 else 503

vlcApi = (command, value, callback)->
	# Encode value
	if value?
		value = encodeURIComponent value
			.replace /%20/g, "+"
	#Send request
	url = "#{config?.vlc.http.url}"
	if command?
		url += "?command=#{command}"
		if value?
			url += "&val=#{value}"
	log.debug "VLC api: #{url}"
	request
			url: url
			headers:
				Authorization: "Basic #{new Buffer(":#{config?.vlc.http.password}").toString "base64"}"
		, (err, res) =>
			if err?
				log.error "Error contacting VLC"
				log.info "Have you configured the VLC HTTP API?" # Maybe it's just not running
				log.error err
				callback? false
				return
			if res?.statusCode isnt 200
				log.error "Error contact VLC (#{res.statusCode})"
				if res.statusCode is 401
					log.error "Authentication error. Have you configured the VLC HTTP password correctly?"

			callback? res?.statusCode is 200, res.body
