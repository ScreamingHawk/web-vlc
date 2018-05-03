log = require 'winston'
express = require 'express'
path = require 'path'

router = express.Router()
exports = module.exports = router

exports.init = ->

router.get '/', (req, res)->
	sendHome = =>
		# Send home page
		res.sendFile path.join __dirname, '../../client/index.html'
	if req.query.refresh?
		# Refresh the list
		require './shows'
			.refreshLists true, sendHome
	else
		sendHome()

router.get '/bundle.js', (req, res)->
	# Send bundled js
	res.sendFile path.join __dirname, '../../client/build/bundle.js'

router.get '/manifest.json', (req, res)->
	# Send manifest
	res.sendFile path.join __dirname, '../../client/manifest.json'

# Images
router.use '/img', express.static path.join __dirname, '../../client/build/img'

# Favicon
router.get '/favicon.ico', (req, res)->
	res.sendFile path.join __dirname, '../../client/build/img/icon/favicon.ico'
router.get '/favicon.png', (req, res)->
	res.sendFile path.join __dirname, '../../client/build/img/icon/icon-192x192.png'
