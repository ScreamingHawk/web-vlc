log = require 'winston'
express = require 'express'
fs = require 'fs'

router = express.Router()
exports = module.exports = router

config = null

exports.init = (c)->
	config = c

# Stream a video
router.get '/*', (req, res)->
	fPath = req.params?[0]
	if !fPath
		# Path required
		log.warn "Video path not supplied"
		res.sendStatus 400
		return

	stat = fs.statSync fPath
	fileSize = stat.size
	range = req.headers.range

	if range
		log.debug "Streaming chunk"

		parts = range.replace /bytes=/, ""
			.split "-"
		start = parseInt parts[0], 10
		end = if parts[1] then parseInt parts[1], 10 else fileSize - 1
		chunkSize = end - start + 1
		file = fs.createReadStream fPath, {start, end}

		res.writeHead 206,
			"Content-Range": "bytes #{start}-#{end}/#{fileSize}"
			"Accept-Ranges": "bytes"
			"Content-Length": chunkSize
			#"Content-Type": FIXME
		file.pipe res

	else
		log.debug "Streaming whole video"

		res.writeHead 200,
			"Content-Length": fileSize
			#"Content-Type": FIXME
		fs.createReadStream fPath
			.pipe res
