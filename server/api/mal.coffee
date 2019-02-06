cheerio = require 'cheerio'
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

setValues = (show, apiData)->
	show["source"] = apiData.source
	show["image"] = apiData.image
	show["plot"] = apiData.plot
	show["genres"] = apiData.genres
	show["malRating"] = apiData.malRating
	show["rating"] = apiData.rating

exports.update = (show, forceApi=false)->
	if !data.mal?
		# Set up mal in data if required
		data.mal = {}

	if !forceApi && show.api == "mal"
		# Check the stored data for cached API
		dataMalShow = data.mal[show.name]
		if dataMalShow?
			cacheLimit = moment().subtract (config?.api?.cacheDays || 0), 'days'
			cachedAt = moment dataMalShow._timestamp
			if cachedAt.isValid() && cachedAt.isAfter cacheLimit
				log.debug "Using MAL data for #{show.name} from cache"
				setValues show, dataMalShow
				return
			else
				log.debug "MAL data for #{show.name} is too old"

	if config?.api?.mal?.enabled && (forceApi || show.api == "mal")
		log.debug "Updating MAL data for #{show.name}"
		url = "#{config.api.mal.url}anime.php?q=#{show.name}"
		log.debug "Requesting #{url}"
		url = encodeURI url
		request url, (err, res)=>
			if err?
				log.error "Error contacting MAL: #{err}"
			else if res?.statusCode is not 200
				log.error "Request failed from MAL with code #{res?.statusCode}"
			else
				jq = cheerio.load res.body
				pageUrl = jq ".pt4"
						?.find "a"
						?.first()?.attr "href"
				if !pageUrl
					log.warn "MAL couldn't find data for #{show.name}"
				else
					pageUrl = encodeURI pageUrl
					log.debug "Found MAL entry #{pageUrl} for #{show.name}"
					request pageUrl, (err, res)=>
						if err?
							log.error "Error contacting MAL: #{err}"
						else if res?.statusCode is not 200
							log.error "Request failed from MAL with code #{res?.statusCode}"
						else
							jq = cheerio.load res.body
							apiData = {}
							apiData.source = pageUrl
							apiData.image = jq ".ac"
									?.attr("src")
							apiData.plot = jq "span[itemprop=description]"
									?.first()?.text()?.replace "[Written by MAL Rewrite]", ""
									?.trim()
							apiData.malRating = jq ".score"
									?.first()?.text()?.replace /\n/g, ''
									?.trim()
							apiData.rating = jq ".js-scrollfix-bottom span.dark_text"
									?.filter (i, e)->
										jq(e).text() == "Rating:"
									?.parent()?.text()?.replace /\n/g, ''
									?.replace /Rating:/g, ''
									?.trim()
							apiData.genres = jq ".js-scrollfix-bottom span.dark_text"
									?.filter (i, e)->
										jq(e).text() == "Genres:"
									?.parent()?.text()?.replace /\n/g, ''
									?.replace /Genres:/g, ''
									?.trim()
							apiData._timestamp = moment()
							setValues show, apiData
							# Update stored data
							data.mal[show.name] = apiData
							common.storeData()
