cheerio = require 'cheerio'
log = require 'winston'
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
	if config?.api?.prefer == "mal"
		show[key] = value
	else if !show[key]
		show[key] = value

setValues = (show, apiData)->
	checkAndSet show, "api", "mal"
	checkAndSet show, "source", apiData.source
	checkAndSet show, "image", apiData.image
	checkAndSet show, "plot", apiData.plot
	checkAndSet show, "genres", apiData.genres
	checkAndSet show, "malRating", apiData.malRating
	checkAndSet show, "rating", apiData.rating

exports.update = (show, forceApi=false)->
	if !data.mal?
		# Set up mal in data if required
		data.mal = {}

	if !forceApi
		# Check the stored data for cached API
		dataMalShow = data.mal[show.name]
		if dataMalShow?
			log.debug "Using MAL data for #{show.name} from cache"
			setValues show, dataMalShow
			return

	if config?.api?.mal?.enabled
		log.debug "Updating MAL data for #{show.name}"
		url = "#{config.api.mal.url}anime.php?q=#{show.name}"
		log.debug "Requesting #{url}"
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
							apiData._timestamp = Date()
							setValues show, apiData
							# Update stored data
							show._timestamp = Date()
							data.mal[show.name] = apiData
							common.storeData()
