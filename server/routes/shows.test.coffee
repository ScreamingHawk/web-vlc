path = require 'path'

shows = require './shows'

# Mock data
createMockConfig = ->
	files:
		locations: []
data = {}
common =
	storeData: ->

beforeAll ->
	shows.init createMockConfig(), data, common

testData = [
		testName: 'SwordArt'
		fname: "E:/Videos/Anime/Sword Art Online/Season 3/[HorribleSubs] Sword Art Online - Alicization - 22 [1080p].mkv",
		episode: 22
		season: 3
		show: "Sword Art Online"
	,
		testName: 'Full Metal'
		fname: "F:/Videos/Anime/Fullmetal Alchemist Brotherhood/Season 1/[Reaktor] Fullmetal Alchemist Brotherhood - E32 v2 [1080p][x265][10-bit][Dual-Audio].mkv",
		episode: 32
		season: 1
		show: "Fullmetal Alchemist Brotherhood"
	,
		testName: 'Toy Story 4'
		fname: "F:/Videos/Movies/Toy Story 4/Toy.Story.4.2019.1080p.BluRay.x264-[YTS.LT].mp4",
		show: "Toy Story 4"
	,
		testName: 'Darling in the FranXX'
		fname: "F:/Videos/Anime/Darling in the FranXX/Season 1/[HorribleSubs] Darling in the FranXX - 02 [1080p].mkv",
		episode: 2
		season: 1
		show: "Darling in the FranXX"
	,
		testName: 'Cencoroll'
		fname: "F:/Videos/Anime/Cencoroll/[LoveRoll] Cencoroll [WEB 1080p AAC][EADBB390].mkv",
		show: "Cencoroll"
]

# Tests begin

describe 'getFileMeta', ->
	for d in testData
		do (d)->
			it d.testName, =>
				# Make path match system
				fname = d.fname.replace /\//g, path.sep
				meta = shows.getFileMeta fname, null, null
				expect meta.episode
					.toBe d.episode
				expect meta.season
					.toBe d.season
				expect meta.show
					.toBe d.show
	return
