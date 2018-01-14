express = require 'express'
log = require 'winston'

config = require './config'

# Create logger
log.remove log.transports.Console
log.add log.transports.Console,
	timestamp: true
	level: config.server.logLevel

app = express()

app.get '/', (req, res)->
	res.send "Hello World"

app.listen config.server.port, ->
	log.info "Server running at http://localhost:#{config.server.port}"
