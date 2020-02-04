log = require 'winston'
express = require 'express'
spawn = require 'cross-spawn'
request = require 'request'
path = require 'path'
{ parseString } = require 'xml2js'

router = express.Router()
exports = module.exports = router

config = null
data = null
common = null
io = null

exports.init = (c, d, f, io)->
	config = c
	data = d
	common = f
	io = io
	# Set vlc ping interval
	setInterval ()->
		vlcStatus (err, status)->
			if err
				io.sockets.emit 'vlc error'
				return
			io.sockets.emit 'status is', status
	, 1000

nowPlaying = null

suppressContactError = false

# Request vlc to open a file
router.post '/', (req, res)->
	if !req.body?.path?
		# Path required
		log.warn "Video path not supplied"
		res.sendStatus 400
		return
	fPath = req.body.path
	log.debug "Playing video at path #{fPath}"

	# Build vlc command
	cmdFlags = ["--one-instance", "--no-playlist-enqueue"]
	if config?.vlc.fullscreen
		cmdFlags.push "-f"
	if config?.vlc.playAndExit
		cmdFlags.push "--play-and-exit"
	cmdFlags.push fPath

	# Open vlc
	log.debug "Running command #{config?.vlc.command} with flags #{cmdFlags}"
	child = spawn config?.vlc.command, cmdFlags
	child.on 'error', (err)->
		log.error "VLC error: #{err}"

	# Get filename
	parts = fPath.split path.sep
	nowPlaying = parts[parts.length - 1]

	# Update stored data
	log.debug "Setting watched for path #{fPath}"
	common.setWatched fPath
	if !data.watched?
		data.watched = []
	data.watched.push fPath
	common.storeData()

	res.sendStatus 200

# Get VLC status
vlcStatus = (callback)->
	vlcApi null, null, (ok, xmlStatus)->
		if ok && xmlStatus?
			parseString xmlStatus, (err, status)->
				callback null, status.root
		else
			callback 503
router.get '/status', (req, res)->
	vlcStatus (err, status)->
		if err
			return res.sendStatus err
		res.json status

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
				if !suppressContactError
					# Make contact before, probably just not running
					log.error "Error contacting VLC"
					log.info "Have you configured the VLC HTTP API?"
					log.error err
				else
					# Log it at debug level this time
					log.verbose "Error contacting VLC"
				callback? false
				return
			if res?.statusCode is 200
				suppressContactError = true
			else
				log.error "Error contact VLC (#{res?.statusCode})"
				if res?.statusCode is 401
					log.error "Authentication error. Have you configured the VLC HTTP password correctly?"

			callback? res?.statusCode is 200, res.body
