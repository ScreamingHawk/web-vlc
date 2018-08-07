log = require 'winston'
express = require 'express'
fs = require 'fs'

router = express.Router()
exports = module.exports = router

config = null

exports.init = (c)->
	config = c

# Download a video
router.get '/*', (req, res)->
	fPath = req.params?[0]
	if !fPath
		# Path required
		log.warn "Video path not supplied"
		res.sendStatus 400
		return

	log.debug "Downloading #{fPath}"
	res.download(fPath)
