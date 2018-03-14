log = require 'winston'
express = require 'express'

router = express.Router()
exports = module.exports = router

config = null

exports.init = (c)->
	config = c

router.get '/api/:api', (req, res)->
	# Return api details
	apiData = config?.api[req.params.api]
	if apiData?
		res.json apiData
	else
		res.sendStatus 404
