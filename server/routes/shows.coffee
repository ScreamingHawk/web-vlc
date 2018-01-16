log = require 'winston'
express = require 'express'
fs = require 'fs'
path = require 'path'
mime = require 'mime'
request = require 'request'

config = require '../config'

router = express.Router()

exports = module.exports = router

videoList = []
showList = []
# Refresh the list
refreshLists = (callback)->
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
						if fMime.startsWith "video"
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
				count: 1
				videos: [video]
		else
			if video.season? && !(video.season in showListDict[video.show].seasons)
				showListDict[video.show].seasons.push video.season
			showListDict[video.show].count++
			showListDict[video.show].videos.push video
	showList = []
	for name, show of showListDict
		setApiDetails show
		showList.push show

	callback?()

setApiDetails = (show)->
	request "#{config.api.omdb.url}?apikey=#{config.api.omdb.key}&t=#{show.name}", (err, res)=>
		if res.statusCode is 200
			body = JSON.parse res.body
			if body.Response == "True"
				show.image = body.Poster
				show.plot = body.Plot
				show.imdbRating = body.imdbRating

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

	return fMeta

# Call on init
refreshLists()

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
			imdbRating: show.imdbRating
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
	if !videos
		res.sendStatus 404
	else
		res.json videos

router.get '/refresh', (req, res)->
	# Refresh the list
	refreshLists()
	res.sendStatus 200
