express = require 'express'
request = require 'supertest'
route = require './client'

app = express()
route.init()
app.use route

describe 'Root path', ->
	test 'Returns 200', ->
		request app
			.get '/'
			.expect 200

describe 'bundle.js', ->
	test 'Returns 200', ->
		request app
			.get '/bundle.js'
			.expect 200

describe 'manifest.json', ->
	test 'Returns 200', ->
		request app
			.get '/manifest.json'
			.expect 200

describe 'offline.html', ->
	test 'Returns 200', ->
		request app
			.get '/offline.html'
			.expect 200

describe 'serviceWorker.js', ->
	test 'Returns 200', ->
		request app
			.get '/serviceWorker.js'
			.expect 200

describe 'favicon', ->
	test 'Returns ico', ->
		request app
			.get '/favicon.ico'
			.expect 200
	test 'Returns png', ->
		request app
			.get '/favicon.png'
			.expect 200
	test 'Returns svg', ->
		request app
			.get '/favicon.svg'
			.expect 200

describe 'img directory', ->
	test 'Returns 200', ->
		request app
			.get '/img/icon/favicon.ico'
			.expect 200
