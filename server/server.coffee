express = require 'express'
log = require 'winston'
path = require 'path'

config = require './config'

# Configure logger
log.remove log.transports.Console
log.add log.transports.Console,
	timestamp: true
	level: config.server.logLevel

# Configure server
app = express()

# Configure routes
app.use '/play', require './routes/play'
app.use '/shows', require './routes/shows'

app.get '/', (req, res)->
	# Send home page
	res.sendFile path.join __dirname, '../client/index.html'

app.get '/bundle.js', (req, res)->
	# Send bundled js
	res.sendFile path.join __dirname, '../client/build/bundle.js'

# Run server
app.listen config.server.port, ->
	log.info "Server running at http://localhost:#{config.server.port}"

# Catch top level exceptions and log them.
# This should prevent the server from terminating due to a rogue exception.
process.on 'uncaughtException', (error) ->
	log.error "CRITICAL: #{error.stack}"
