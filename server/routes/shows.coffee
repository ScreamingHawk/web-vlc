log = require 'winston'
express = require 'express'
fs = require 'fs'
path = require 'path'
mime = require 'mime'

config = require '../config'

router = express.Router()

exports = module.exports = router

showList = []
# Refresh the list
refreshList = (callback)->
	log.debug "Refreshing video list"

	# Get all files in sub folders
	walkSync = (dir, fileList = [])->
		fs.readdirSync dir
			.forEach (file)->
				fPath = path.join dir, file
				if fs.statSync(fPath).isDirectory()
					walkSync fPath, fileList
				else
					fMime = mime.getType file
					if fMime.startsWith "video"
						fileList.push getFileMeta fPath, fMime
		fileList

	# Build the list from all locations
	showList = []
	for loc in config.files.locations
		showList = showList.concat walkSync loc
	callback? showList

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
	episode = fMeta.filename?.match /(?:e|x|episode)?(\d)+/, "i"
	if episode?
		fMeta.episode = episode[0]
	# Get season from folder
	i = 2
	season = parts[parts.length - i]?.match /(?:s|season)?(\d)+/, "i"
	if season?
		fMeta.season = season[0]
		i++
	# Get show
	fMeta.show = parts[parts.length - i]

	return fMeta

# Call on init
refreshList()

router.get '/', (req, res)->
	# List all shows
	res.send showList

router.get '/refresh', (req, res)->
	# Refresh the list
	refreshList()
	res.sendStatus 200
