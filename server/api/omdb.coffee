log = require 'winston'
moment = require 'moment'
path = require 'path'
request = require 'request'

exports = module.exports = {}

config = null
data = null
common = null

exports.init = (c, d, f)->
	config = c
	data = d
	common = f

checkAndSet = (show, key, value)->
	if config?.api?.prefer == "omdb"
		show[key] = value
	else if !show[key]
		show[key] = value

setValues = (show, apiData)->
	checkAndSet show, "api", "omdb"
	checkAndSet show, "source", "https://www.imdb.com/title/#{apiData.imdbID}"
	checkAndSet show, "image", apiData.Poster
	checkAndSet show, "plot", apiData.Plot
	checkAndSet show, "imdbRating", apiData.imdbRating
	checkAndSet show, "rating", apiData.Rated

exports.update = (show, forceApi=false)->
	if !data.omdb?
		# Set up omdb in data if required
		data.omdb = {}

	if !forceApi
		# Check the stored data for cached API
		dataOmdbShow = data.omdb[show.name]
		if dataOmdbShow?
			cacheLimit = moment().subtract (config?.api?.cacheDays || 0), 'days'
			cachedAt = moment dataOmdbShow._timestamp
			log.debug "Comparing #{cacheLimit} and #{cachedAt} for #{show.name}"
			if cachedAt.isValid() && cachedAt.isAfter cacheLimit
				log.debug "Using OMDB data for #{show.name} from cache"
				setValues show, dataOmdbShow
				return
			else
				log.debug "OMDB data for #{show.name} is too old"

	if config?.api?.omdb?.enabled
		log.debug "Updating OMDB data for #{show.name}"
		request "#{config.api.omdb.url}?apikey=#{config.api.omdb.key}&t=#{show.name}", (err, res)=>
			if err?
				log.error "Error contacting OMDB: #{err}"
			else if res?.statusCode is 200
				body = JSON.parse res.body
				if body.Response == "True"
					setValues show, body
					# Update stored data
					body._timestamp = moment()
					data.omdb[show.name] = body
					common.storeData()
				else
					log.warn "OMDB couldn't find data for #{show.name}"
			else if res?.statusCode is 401
				log.error "The OMDB API key in your config is invalid"
			else
				log.error "Request failed from OMDB with code #{res?.statusCode}"
