express = require 'express'
http = require 'http'
socketio = require 'socket.io'
request = require 'request'
log = require 'winston'
path = require 'path'
bodyParser = require 'body-parser'
requireYaml = require 'require-yml'
fs = require 'fs'
pkceChallenge = require 'pkce-challenge'

configPath = path.join __dirname, 'config.yaml'

if !fs.existsSync configPath
	console.log "No config file! Please create a config file."
	console.log "View the README for more information."
	process.exit()

config = requireYaml configPath

# Configure logger
log.remove log.transports.Console
log.add log.transports.Console,
	timestamp: true
	level: config.server.logLevel

# Set up pkce challenge (this should be done per request but eh)
config.challenge = pkceChallenge()
log.debug "Challenge code #{JSON.stringify config.challenge}"

# Secure based configuration
if config.server.secure
	https = require 'https'
	try
		privateKey = fs.readFileSync path.join(__dirname, 'cert/private.pem'), 'utf8'
		publicKey = fs.readFileSync path.join(__dirname, 'cert/public.pem'), 'utf8'
	catch err
		log.error "HTTPS key files not found", err
		process.exit(1)
	url = "https"
else
	http = require 'http'
	url = "http"

url += "://localhost:#{config.server.port}"

server = null
portKillAttempted = false

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
if config.server.secure
	server = https.createServer
			key: privateKey
			cert: publicKey
		, app
else
	server = http.createServer app
s = server.listen config.server.port, (err)->
	log.info "Server running at #{url}"
io = socketio s
app.use bodyParser.json
	limit: '1mb'
app.use bodyParser.urlencoded
	extended: false
app.use (req, res, next)->
	# Prevent 403
	req.headers['if-none-match'] = 'no-match-for-this'
	next()

# Configure routes
showsRoutes = require './routes/shows'
showsRoutes.init config, data, commonFunctions
app.use '/shows', showsRoutes

playRoutes = require './routes/play'
playRoutes.init config, data, commonFunctions, io
app.use '/play', playRoutes

if config.client.downloadEnabled
	log.info "Downloading enabled"
	downloadRoutes = require './routes/download'
	downloadRoutes.init config, data, commonFunctions
	app.use '/download', downloadRoutes

if config.client.streamEnabled
	log.info "Streaming enabled"
	streamRoutes = require './routes/stream'
	streamRoutes.init config, data, commonFunctions
	app.use '/stream', streamRoutes

configRoutes = require './routes/config'
configRoutes.init config, data, commonFunctions
app.use '/config', configRoutes

verifyRoutes = require './routes/verify'
verifyRoutes.init config
app.use '/verify', verifyRoutes

app.use '/', require './routes/client'

app.get '/quit', (req, res)->
	log.info "Quit command received. Closing"
	res.sendStatus 204
	server.close()
	process.exit()

# Configure socketio
io.on 'connection', (socket)->
	log.debug "A user connected"
	socket.on 'disconnect', ()->
		log.debug "A user disconnected"

