log = require 'winston'
express = require 'express'

router = express.Router()
exports = module.exports = router

config = null

exports.init = (c)->
	config = c

router.get '/client', (req, res)->
	# Return client config
	c = config?.client || {}
	if config?.api?.mal?.enabled
		c.malUrl = config.api.mal.url
		c.malClientId = config.api.mal.clientId
		c.challenge = config.challenge.code_challenge
		c.malLoggedIn = config.api.mal.token?
	res.json c
