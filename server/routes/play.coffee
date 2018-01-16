log = require 'winston'
express = require 'express'
spawn = require 'cross-spawn'

config = require '../config'

router = express.Router()

exports = module.exports = router

router.post '/', (req, res)->
	log.debug req.body
	log.debug "Playing video at path #{req.body?.path}"
	# Open vlc
	child = spawn config.vlc.command
	data = ""
	child.stdout.on 'data', (chunk)->
		data += chunk
	child.on 'error', (err)->
		res.send err
		throw err
	child.on 'close', (code)->
		res.json
			code: code
			data: data
