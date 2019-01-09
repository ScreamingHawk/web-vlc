log = require 'winston'
express = require 'express'

router = express.Router()
exports = module.exports = router

config = null

exports.init = (c)->
	config = c

router.get '/client', (req, res)->
	# Return client config
	res.json config?.client
