log = require 'winston'
express = require 'express'

router = express.Router()
exports = module.exports = router

config = null

exports.init = (c)->
	config = c

router.get '/client/:client', (req, res)->
	# Return client config
	clientData = config?.client[req.params.client]
	if clientData?
		res.json
			"#{req.params.client}": clientData
	else
		res.sendStatus 404
