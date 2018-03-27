express = require 'express'
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

# Catch top level exceptions and log them.
# This should prevent the server from terminating due to a rogue exception.
process.on 'uncaughtException', (error) ->
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
dataLoc = path.join __dirname, 'data.json'
if !fs.existsSync dataLoc
	commonFunctions.storeDataSync()
data = require './data.json'

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

# Run server
app.listen config.server.port, ->
	log.info "Server running at http://localhost:#{config.server.port}"
