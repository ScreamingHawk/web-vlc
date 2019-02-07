log = require 'winston'
express = require 'express'
fs = require 'fs'
path = require 'path'
chokidar = require 'chokidar'
mime = require 'mime'
request = require 'request'

omdb = require '../api/omdb'
mal = require '../api/mal'

router = express.Router()
exports = module.exports = router

config = null
data = null
common = null

refreshing = false
watchRefresh = false

exports.init = (c, d, f)->
	config = c
	data = d
	common = f
	common.setWatched = setWatched
	# Init apis
	omdb.init config, data, common
	mal.init config, data, common
	# Init watcher
	if c.files?.watch
		for loc in config.files.locations
			if loc.folder?
				# Get folder only
				loc = loc.folder
			log.debug "Watching directory #{loc}"
			chokidar.watch loc,
					ignored: /(^|[\/\\])\../
					ignoreInitial: true
				.on 'all', (event, path)->
					if event in ['add', 'change', 'unlink']
						log.debug "Refreshing due to #{event} in #{loc} with path #{path}"
						watchRefresh = true
						refreshLists false, ->
							watchRefresh = false
	# Init lists
	refreshLists()

videoList = []
showList = []
# Refresh the list
refreshLists = exports.refreshLists = (forceApi=false, callback=null)->
	log.debug "Refreshing video list"

	if refreshing
		log.debug "Currently refreshing list. Skipping..."
		callback?()
		return
	refreshing = true

	# Get all files in sub folders
	walkSync = (location, fileList = [])->
		dir = location.folder
		try
			fs.readdirSync dir
				.forEach (file)->
					fPath = path.join dir, file
					if config.files.ignoreHidden && /(^|\/)\.[^\/\.]/g.test file
						# Ignore hidden files
						log.debug "Ignoring hidden: #{fPath}"
						return
					if fs.statSync(fPath).isDirectory()
						nextLocation =
							folder: fPath
							api: location.api
						walkSync nextLocation, fileList
					else
						fMime = mime.getType file
						if fMime?.startsWith "video"
							fileList.push getFileMeta fPath, fMime, location.api
		catch err
			log.error "Unable to read directory #{dir}. Is your config file set up correctly?"
			log.error err
		fileList

	# Build the list of videos from all locations
	videoList = []
	for loc in config.files.locations
		if typeof loc is "string"
			# Convert string to object (for backwards compatible)
			loc =
				folder: loc
		videoList = videoList.concat walkSync loc

	# Build the list of shows from all videos
	showListDict = {}
	for video in videoList
		if !showListDict[video.show]?
			showListDict[video.show] =
				name: video.show
				seasons: if video.season? then [video.season] else []
				hasUnseasoned: !video.season?
				count: 1
				videos: [video]
				api: video.api
		else
			if video.season? && !(video.season in showListDict[video.show].seasons)
				showListDict[video.show].seasons.push video.season
			else if !video.season?
				showListDict[video.show].hasUnseasoned = true
			showListDict[video.show].count++
			showListDict[video.show].videos.push video
	showList = []
	for name, show of showListDict
		setApiDetails show, forceApi
		show.seasons.sort (a, b)->
			a - b
		showList.push show
	showList.sort (a, b)->
		a.name.localeCompare b.name

	refreshing = false

	callback?()

setApiDetails = (show, forceApi=false)->
	omdb.update show, forceApi
	mal.update show, forceApi

setWatched = (path, watched=true)->
	for video in videoList
		if video.path == path
			video.watched = watched
			break

getFileMeta = (fPath, fMime, api)->
	# Create meta obj
	fMeta =
		path: fPath
		api: api
	# Get filename
	parts = fPath.split path.sep
	fMeta.filename = parts[parts.length - 1]
	# Get mime
	if !fMime?
		fMime = mime.getType fMeta.file
	fMeta.mime = fMime
	# Get episode
	episode = fMeta.filename?.match /(?:e|x|_|-|episode|^)\s*(\d{1,2})/, "i"
	if episode? && !isNaN episode[1]
		fMeta.episode = Number episode[1]
	# Get season from folder
	i = 2
	season = parts[parts.length - i]?.match /(?:s|season)?(\d{1,2})/, "i"
	if season? && !isNaN season[0]
		fMeta.season = Number season[0]
		# Bump folder for getting show
		i++
	# Get show
	fMeta.show = parts[parts.length - i]
	# Check if watched
	fMeta.watched = false
	if data.watched?
		fMeta.watched = fPath in data.watched

	return fMeta

router.get '/', (req, res)->
	# List all shows
	shows = []
	for show in showList
		shows.push
			name: show.name
			seasons: show.seasons
			count: show.count
			api: show.api
			source: show.source
			image: show.image
			plot: show.plot
			genres: show.genres
			score: show.score
			rating: show.rating
			hasUnseasoned: show.hasUnseasoned
	if !shows
		res.sendStatus 404
	else
		res.json shows

router.get '/:showName', (req, res)->
	# List all videos for a show
	videos = []
	for show in showList
		if show.name == req.params.showName
			videos = show.videos
			break
	if !videos
		res.sendStatus 404
	else
		res.json videos

router.get '/:showName/seasons/:season', (req, res)->
	# List all videos for the season
	season = Number req.params.season
	videos = []
	for show in showList
		if show.name == req.params.showName
			for video in show.videos
				if (!video.season? && isNaN season) ||
						(video.season == season)
					videos.push video
	res.send videos

router.get '/:showName/:videoFilename/next', (req, res)->
	# List the next show
	sendNext = false
	for show in showList
		if show.name == req.params.showName
			for video in show.videos
				if sendNext
					# Send this video
					res.json video
					return
				if video.filename == req.params.videoFilename
					# Matched current, send the next one
					sendNext = true
	# Fail over
	res.sendStatus 404

router.post '/unwatch', (req, res)->
	if !req.body?.path?
		# Path required
		log.warn "Video path not supplied"
		res.sendStatus 400
		return
	fPath = req.body.path
	common.setWatched fPath, false
	data.watched.filter (e) ->
		e != fPath
	common.storeData()
	res.sendStatus 200

router.post '/search', (req, res)->
	if !req.body?.filename?
		# Filename required
		log.warn "Video filename not supplied"
		res.sendStatus 400
		return
	log.debug "Filename searching: #{req.body.filename}"

	for show in showList
		for video in show.videos
			log.debug "Testing: #{video.filename}"
			if video.filename.indexOf(req.body.filename) > -1
				# Clone the video
				v = JSON.parse JSON.stringify video
				# Send the show with the video
				v.show = show
				res.json v
				return
	# Fail over
	res.sendStatus 400

router.get '/refresh', (req, res)->
	# Refresh the list
	refreshLists()
	res.sendStatus 200
