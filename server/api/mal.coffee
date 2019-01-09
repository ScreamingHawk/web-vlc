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

exports.update = (show, forceApi=false)->
	if !data.mal?
		# Set up mal in data if required
		data.mal = {}

	if !forceApi
		# Check the stored data for cached API
		dataMalShow = data.mal[show.name]
		if dataMalShow?
			log.debug "Using MAL data for #{show.name} from cache"
			show.image = dataMalShow.image
			show.plot = dataMalShow.plot
			show.genres = dataMalShow.genres
			show.malRating = dataMalShow.malRating
			show.rating = dataMalShow.rating
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
							show.image = jq ".ac"
									?.attr("src")
							show.plot = jq "span[itemprop=description]"
									?.first()?.text()?.replace "[Written by MAL Rewrite]", ""
									?.trim()
							show.malRating = jq ".score"
									?.first()?.text()?.replace /\n/g, ''
									?.trim()
							show.rating = jq ".js-scrollfix-bottom span.dark_text"
									?.filter (i, e)->
										jq(e).text() == "Rating:"
									?.parent()?.text()?.replace /\n/g, ''
									?.replace /Rating:/g, ''
									?.trim()
							show.genres = jq ".js-scrollfix-bottom span.dark_text"
									?.filter (i, e)->
										jq(e).text() == "Genres:"
									?.parent()?.text()?.replace /\n/g, ''
									?.replace /Genres:/g, ''
									?.trim()
							# Update stored data
							show._timestamp = Date()
							data.mal[show.name] = show
							common.storeData()
