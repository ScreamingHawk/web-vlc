express = require 'express'
log = require 'winston'
path = require 'path'
bodyParser = require 'body-parser'

config = require './config'

# Configure logger
log.remove log.transports.Console
log.add log.transports.Console,
	timestamp: true
	level: config.server.logLevel

# Catch top level exceptions and log them.
# This should prevent the server from terminating due to a rogue exception.
process.on 'uncaughtException', (error) ->
	log.error "CRITICAL: #{error.stack}"

# Configure server
app = express()
app.use bodyParser.json
	limit: '1mb'
app.use bodyParser.urlencoded
	extended: false

# Configure routes
showsRoutes = require './routes/shows'
app.use '/play', require './routes/play'
app.use '/shows', showsRoutes
app.use '/config', require './routes/config'

app.get '/', (req, res)->
	sendHome = =>
		# Send home page
		res.sendFile path.join __dirname, '../client/index.html'
	if req.query.refresh?
		# Refresh the list
		showsRoutes.refreshLists sendHome
	else
		sendHome()


app.get '/bundle.js', (req, res)->
	# Send bundled js
	res.sendFile path.join __dirname, '../client/build/bundle.js'

# Run server
app.listen config.server.port, ->
	log.info "Server running at http://localhost:#{config.server.port}"
