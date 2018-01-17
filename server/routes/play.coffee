log = require 'winston'
express = require 'express'
spawn = require 'cross-spawn'
request = require 'request'

config = require '../config'

router = express.Router()

exports = module.exports = router

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
	if config.vlc.fullscreen
		cmdFlags.push "-f"
	if config.vlc.playAndExit
		cmdFlags.push "--play-and-exit"
	cmdFlags.push "#{req.body.path}"

	# Open vlc
	log.debug "Running command #{config.vlc.command} with flags #{cmdFlags}"
	child = spawn config.vlc.command, cmdFlags
	data = ""
	child.stdout.on 'data', (chunk)->
		data += chunk
	child.on 'error', (err)->
		log.error "VLC error: #{err}"
	child.on 'close', (code)->
		log.debug "VLC closed"

	res.sendStatus 200

# Test if VLC is running
router.get '/', (req, res)->
	res.json
		open: vlcOpen

# Change volume
router.post '/volume', (req, res)->
	if !req.body?.volume?
		log.warn "Volume not supplied"
		res.sendStatus 400
		return
	vol = null
	if req.body.volume == "up"
		log.debug "Upping volume"
		vol = "+5"
	else if req.body.volume == "down"
		log.debug "Lowering volume"
		vol = "-5"
	else if isNaN req.body.volume
		log.warn "Volume value invalid"
		res.sendStatus 400
	else
		log.debug "Setting volume"
		vol = req.body.volume
	# Call volume API
	vlcApi "volume", vol, (ok)->
		res.sendStatus if ok then 200 else 503

vlcApi = (command, value, callback)->
	# Encode value
	if value?
		value = value.replace /%/g, "%25"
			.replace /\+/g, "%2B"
			.replace /#/g, "%23"
			.replace /\s/g, "+"
	#Send request
	url = "#{config.vlc.http.url}?command=#{command}"
	if value?
		url += "&val=#{value}"
	request
			url: url
			headers:
				Authorization: "Basic #{new Buffer(":#{config.vlc.http.password}")}"
		, (err, res) =>
			if err?
				log.error "Error contacting VLC (#{res?.statusCode})"
				log.error err
				callback? false
				return
			log.debug "response:"
			log.debug res.statusCode
			callback? true
