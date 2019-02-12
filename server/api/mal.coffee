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
	show["source"] = apiData.source
	show["image"] = apiData.image
	show["plot"] = apiData.plot
	show["genres"] = apiData.genres
	show["score"] = apiData.malRating
	show["rating"] = apiData.rating

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
	'Referer': "#{config.api.mal.url}"

exports.getTokens = getTokens = (callback)->
	if !config.api.mal.username || !config.api.mal.password
		err = "Unable to login to MAL, please set your credentials"
		log.error err
		return callback err

	log.debug "Getting MAL tokens"
	tokens =
		jar: request.jar()
	reqOptions =
		url: "#{config.api.mal.url}login.php"
		jar: tokens.jar
	request reqOptions, (err, res)->
		if err?
			err = "Error contacting MAL: #{err}"
			log.error err
			return callback err
		else if res?.statusCode isnt 200
			err = "Request failed from MAL with code #{res?.statusCode}"
			log.error err
			return callback err
		else
			jq = cheerio.load res.body
			updateCsrfFromPage jq
			reqBody =
				user_name: config.api.mal.username
				password: config.api.mal.password
				cookie: 1
				sublogin: 'Login'
				submit: 1
				csrf_token: tokens.csrf
			reqOptions =
				url: "#{config.api.mal.url}login.php"
				form: reqBody
				headers: getHeaders "login.php"
				jar: tokens.jar
			log.verbose "Sending: #{JSON.stringify(reqOptions, null, 2)}"
			request.post reqOptions, (err, res)->
				if err?
					err = "Error contacting MAL: #{err}"
					log.error err
					return callback err
				else if res?.statusCode isnt 302
					# 302 is a successful login
					err = "Login request failed from MAL with code #{res?.statusCode}"
					log.error err
					if res?.statusCode is 200
						err = "Please check your MAL login credentials are correct"
						log.error err
					return callback err
				log.debug "Login to MAL successful"
				return callback()

exports.updateApiData = (show, forceApi=false)->
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

	if checkUseMal show, forceApi
		log.debug "Updating MAL data for #{show.name}"
		url = "#{config.api.mal.url}anime.php?q=#{show.name}"
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
					request pageUrl, (err, res)->
						if err?
							log.error "Error contacting MAL: #{err}"
						else if res?.statusCode isnt 200
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

exports.setWatched = (show, video, watched=true, next=null)->
	if !checkUseMal show, false
		return next? "Skipped setting watched"

	if !show.source?
		return next? "No show API source"

	log.debug "Setting #{show.name} as #{if watched then 'watched' else 'unwatched'}"

	async.series [
		(callback)->
			if !tokens
				getTokens callback
			else
				callback()
		, (callback)->
			# Load the page to get tokens
			reqOptions =
				url: encodeURI show.source
				jar: tokens.jar
			request reqOptions, (err, res, body)->
				if err?
					err = "Error contacting MAL: #{err}"
					log.error err
					return callback err
				else if res?.statusCode isnt 200
					err = "Request failed from MAL with code #{res?.statusCode}"
					log.error err
					return callback err
				jq = cheerio.load body
				updateCsrfFromPage jq
				# Set score from page
				score = Number findInBody body, "myinfo_score", 'selected" value="', '"'
				if isNaN score
					score = ""
				# Set watched count
				totalEpis = Number findInBody body, 'id="curEps"', '>', '</span>'
				if isNaN totalEpis
					totalEpis = null
				watchedCount = 0
				log.verbose "Show is episode #{video.episode}"
				if video.episode?
					# Watched/unwatched math later
					watchedCount = video.episode - 1
				else
					watchedCount = findInBody(body, "myinfo_watchedeps", 'value="', '"')
					if isNaN watchedCount
						watchedCount = 1
					else
						watchedCount = Number watchedCount
				# Add or subtract episode counter
				watchedCount += if watched then 1 else -1
				# Determine status
				statusWord = "Watching"
				if watchedCount == 0
					statusWord = "Plan to Watch"
				else if totalEpis? && watchedCount >= totalEpis
					statusWord = "Completed"
					watchedCount = totalEpis
				reqBody =
					anime_id: getAnimeId show.source
					status: showStatus[statusWord]
					score: score
					num_watched_episodes: watchedCount
					csrf_token: tokens.csrf
				reqOptions =
					url: "#{config.api.mal.url}ownlist/anime/edit.json"
					json: reqBody
					headers: getHeaders()
					jar: tokens.jar
				log.verbose "Sending: #{JSON.stringify(reqOptions, null, 2)}"
				request.post reqOptions, (err, res, body)->
					if err?
						err = "Error contacting MAL: #{err}"
						log.error err
						return callback err
					else if res?.statusCode isnt 200
						err = "Update request failed from MAL with code #{res?.statusCode}"
						log.error err
						return callback err
					log.info "#{show.name} updated to #{statusWord}, episode #{reqBody.num_watched_episodes}/#{totalEpis}, score #{score}"
					return callback()
	], (err)->
		next? err
