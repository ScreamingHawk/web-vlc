log = require 'winston'
express = require 'express'

config = require '../config'

router = express.Router()

exports = module.exports = router

router.get '/api/:api', (req, res)->
	# Return api details
	apiData = config.api[req.params.api]
	if apiData?
		res.json apiData
	else
		res.sendStatus 404
