async = require 'async'
cheerio = require 'cheerio'
log = require 'winston'
moment = require 'moment'
path = require 'path'
request = require 'request'

exports = module.exports = {}

config = null
data = null
common = null

tokens = null

# Helper info
showStatus =
	Watching: 1
	Completed: 2
	"On-Hold": 3
	Dropped: 4
	"Plan to Watch": 6

exports.init = (c, d, f)->
	config = c
	data = d
	common = f

setValues = (show, apiData)->
	log.debug("Setting MAL values for #{show.name}")
	show["source"] = apiData.source
	show["image"] = apiData.image
	show["plot"] = apiData.plot
	show["genres"] = apiData.genres
	show["score"] = apiData.malRating
	show["rating"] = apiData.rating
	show["api"] = "mal"

exports.checkUseMal = checkUseMal = (show, forceApi=false)->
	return config?.api?.mal?.enabled && (forceApi || show.api == "mal")

# Get the animeId from the source URL
exports.getAnimeId = getAnimeId = (source)->
	if !source
		return null
	s = source.split '/'
	if s.length < 5
		return null
	if s[s.length - 1] == ""
		s.pop()
	# Check the last two fragments
	if isNaN s[s.length - 1]
		s.pop()
		if isNaN s[s.length - 1]
			return null
	Number s[s.length - 1]

findInBody = (body, searchKey, startKey, endKey)->
	s = body.indexOf searchKey
	s = startKey.length + body.indexOf startKey, s
	e = body.indexOf endKey, s
	body.slice s, e

updateCsrfFromPage = (jq)->
	tokens.csrf = jq 'meta[name="csrf_token"]'
			?.attr 'content'

getHeaders = (referer="")->
	# Fake a bunch of headers
	'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:65.0) Gecko/20100101 Firefox/65.0'
	'Host': 'myanimelist.net'
	'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
	'Accept-Encoding': 'gzip, deflate, br'
	'Accept-Language': 'en-US,en;q=0.5'
	'Connection': 'keep-alive'
	'TE': 'Trailers'
	'Referer': "https://myanimelist.net/"

exports.userOrSearchSource = userOrSearchSource = (show, callback)->
	if show.userSource
		log.debug "Using user source for #{show.name}"
		return callback null, show.userSource
	log.debug "Searching for MAL source for #{show.name}"
	url = "https://myanimelist.net/anime.php?q=#{show.name}"
	url = encodeURI url
	log.verbose "Requesting #{url}"
	request url, (err, res)->
		if err?
			log.error "Error contacting MAL: #{err}"
		else if res?.statusCode isnt 200
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
				return callback null, pageUrl
		callback "MAL search failed"

exports.getApiData = getApiData = (pageUrl, show, callback)->
	request pageUrl, (err, res)->
		if err?
			err = "Error contacting MAL: #{err}"
			log.error err
			return callback? err
		else if res?.statusCode isnt 200
			err = "Request failed from MAL with code #{res?.statusCode}"
			log.error err
			return callback? err
		else
			jq = cheerio.load res.body
			apiData = {}
			apiData.source = pageUrl
			apiData.userSource = show.userSource
			apiData.image = jq "img[itemprop='image']"
					?.attr("data-src")
			apiData.plot = jq "[itemprop='description']"
					?.first()?.text()?.replace "[Written by MAL Rewrite]", ""
					?.trim()
			apiData.malRating = jq ".score"
					?.first()?.text()?.replace /\n/g, ''
					?.trim()
			apiData.rating = jq "span:contains('Rating:')"
					?.parent()?.text()
					?.replace /Rating:/g, ''
					?.trim()
			apiData.genres = jq "[itemprop='genre']"
					?.map (i, e)->
						jq(e).text()
					?.get()?.join(', ')
			apiData._timestamp = moment()
			return callback? null, apiData

exports.updateApiData = (show, forceApi=false, callback=null)->
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
				return callback? null, show
			else
				log.debug "MAL data for #{show.name} is too old"

	if checkUseMal show, forceApi
		log.debug "Updating MAL data for #{show.name}"
		userOrSearchSource show, (err, pageUrl)->
			if err?
				callback? err
				return
			getApiData pageUrl, show, (err, apiData)->
				if err?
					callback? err
					return
				setValues show, apiData
				callback? null, show
				# Update stored data
				data.mal[show.name] = apiData
				common.storeData()
				return
	else
		err = "MAL updated not allowed for #{show.name}"
		log.debug err
		callback? err

exports.setWatched = (show, video, watched=true, next=null)->
	if !checkUseMal show, false
		e = "Skipped setting watched"
		log.error e
		return next? e

	if !show.source?
		e = "No show API source"
		log.error e
		return next? e

	if !config.api.mal.token?
		e = "Not logged in to MAL"
		log.error e
		return next? e

	log.debug "Setting #{show.name} as #{if watched then 'watched' else 'unwatched'}"

	reqOptions =
		url: "#{config.api.mal.url}/anime/#{getAnimeId show.source}?fields=num_episodes,my_list_status"
		headers:
			Authorization: "Bearer #{config.api.mal.token}"
			Accept: "application/json"

	log.debug "Requesting show data: " + JSON.stringify reqOptions

	request.get reqOptions, (err, res)->
		if err?
			e = "Unable to get show details: " + err
			log.error e
			return next? e
		showBody = JSON.parse res.body
		log.debug showBody

		# Determine episode un/watched
		watchedCount = 0
		log.verbose "Show is episode #{video.episode}"
		if video.episode?
			watchedCount = video.episode - 1
		else
			watchedCount = showBody.my_list_status?.num_episodes_watched || 0
		# Watched or unwatched
		watchedCount += if watched then 1 else 0

		# Determine status
		statusWord = "watching"
		if watchedCount >= showBody.num_episodes
			statusWord = "complete"
			watchedCount = showBody.num_episodes

		reqOptions =
			url: "#{config.api.mal.url}/anime/#{getAnimeId show.source}/my_list_status"
			headers:
				Authorization: "Bearer #{config.api.mal.token}"
			form:
				num_watched_episodes: watchedCount
				status: statusWord
		log.debug "Updating with " + JSON.stringify reqOptions
		request.patch reqOptions, (err, tokenRes)->
			if err?
				err = "Error contacting MAL: #{err}"
				log.error err
				return next? err
			else if res?.statusCode isnt 200
				err = "Update request failed from MAL with code #{res?.statusCode}"
				log.error err
				return next? err
			log.info "#{show.name} updated to #{statusWord}, episode #{watchedCount}/#{showBody.num_episodes}"
			return next?()
