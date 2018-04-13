express = require 'express'
request = require 'request'
log = require 'winston'
path = require 'path'
bodyParser = require 'body-parser'
requireYaml = require 'require-yml'
fs = require 'fs'

config = requireYaml path.join __dirname, 'config.yaml'

# Configure logger
log.remove log.transports.Console
log.add log.transports.Console,
	timestamp: true
	level: config.server.logLevel

server = null
portKillAttempted = false

url = "http://localhost:#{config.server.port}"

# Catch top level exceptions and log them.
# This should prevent the server from terminating due to a rogue exception.
process.on 'uncaughtException', (error) ->
	if error.errno == 'EADDRINUSE' && !portKillAttempted
		portKillAttempted = true
		log.warn "Port in use. Attempting to quit and start again"
		request "#{url}/quit", (err, resp)->
			if err? || resp?.statusCode != 204
				log.error "Did not respond to quit request at #{url}"
				throw error
			log.info "Quit application at #{url}. Starting up again"
			startServer()
	else
		log.error "CRITICAL: #{error.stack}"

# Shared functions
commonFunctions =
	storeData: (callback)->
		fs.writeFile dataLoc, JSON.stringify(data, null, 2), (err)->
			if err?
				log.error "Unable to write data file: #{err}"
			callback? err
	storeDataSync: ->
		try
			# Store it human readable
			fs.writeFileSync dataLoc, JSON.stringify data, null, 2
		catch err
			log.error "Unable to write sync data file: #{err}"

# Stored data
data = {}
dataLoc = path.join __dirname, config.server.dataFile ? "data.json"
if !fs.existsSync dataLoc
	commonFunctions.storeDataSync()
data = require dataLoc

# Configure server
app = express()
app.use bodyParser.json
	limit: '1mb'
app.use bodyParser.urlencoded
	extended: false

# Configure routes
showsRoutes = require './routes/shows'
showsRoutes.init config, data, commonFunctions
app.use '/shows', showsRoutes

playRoutes = require './routes/play'
playRoutes.init config, data, commonFunctions
app.use '/play', playRoutes

configRoutes = require './routes/config'
configRoutes.init config, data, commonFunctions
app.use '/config', configRoutes

app.use '/', require './routes/client'

app.get '/quit', (req, res)->
	log.info "Quit command received. Closing"
	res.sendStatus 204
	server.close()
	process.exit()

startServer = ->
	# Run server
	server = app.listen config.server.port, (err)->
		log.info "Server running at #{url}"
startServer()
