log = require 'winston'
express = require 'express'
request = require 'request'

router = express.Router()
exports = module.exports = router

config = null

exports.init = (c) ->
	config = c

router.get '/', (req, res)->
	mal = config.api.mal
	reqOptions =
		url: "#{mal.url}v1/oauth2/token"
		form:
			client_id: mal.clientId
			client_secret: mal.clientSecret
			redirect_uri: "#{req.protocol}://#{req.get 'host'}/verify"
			grant_type: "authorization_code"
			code: req.query.code
			# MAl only supports "plain" so the challenge is the verifier
			code_verifier: config.challenge.code_challenge
	request.post reqOptions, (err, tokenRes)->
		if err?
			err = "Error contacting MAL: #{err}"
			log.error err
		if tokenRes?.statusCode is 200 && tokenRes?.body
			body = JSON.parse tokenRes.body
			mal.token = body.access_token
			log.info "MAL authentication complete"
		res.redirect '/'
