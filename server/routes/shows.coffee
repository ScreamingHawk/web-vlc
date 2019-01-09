log = require 'winston'
express = require 'express'
fs = require 'fs'
path = require 'path'
mime = require 'mime'
request = require 'request'

omdb = require '../api/omdb'
mal = require '../api/mal'

router = express.Router()
exports = module.exports = router

config = null
data = null
common = null

exports.init = (c, d, f)->
	config = c
	data = d
	common = f
	common.setWatched = setWatched
	# Init apis
	omdb.init config, data, common
	mal.init config, data, common
	# Init lists
	refreshLists()

videoList = []
showList = []
# Refresh the list
refreshLists = exports.refreshLists = (forceApi=false, callback=null)->
	log.debug "Refreshing video list"

	# Get all files in sub folders
	walkSync = (dir, fileList = [])->
		try
			fs.readdirSync dir
				.forEach (file)->
					fPath = path.join dir, file
					if fs.statSync(fPath).isDirectory()
						walkSync fPath, fileList
					else
						fMime = mime.getType file
						if fMime?.startsWith "video"
							fileList.push getFileMeta fPath, fMime
		catch err
			log.error "Unable to read directory #{dir}. Is your config file set up correctly?"
			log.error err
		fileList

	# Build the list of videos from all locations
	videoList = []
	for loc in config.files.locations
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

	callback?()

setApiDetails = (show, forceApi=false)->
	omdb.update show, forceApi
	mal.update show, forceApi

setWatched = (path)->
	for video in videoList
		if video.path == path
			video.watched = true
			break

getFileMeta = (fPath, fMime)->
	# Create meta obj
	fMeta =
		path: fPath
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
			image: show.image
			plot: show.plot
			genres: show.genres
			imdbRating: show.imdbRating
			malRating: show.malRating
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
