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
		fname: "E:\\Videos\\Anime\\Sword Art Online\\Season 3\\[HorribleSubs] Sword Art Online - Alicization - 22 [1080p].mkv",
		episode: 22
		season: 3
		show: "Sword Art Online"
	,
		testName: 'Full Metal'
		fname: "F:\\Videos\\Anime\\Fullmetal Alchemist Brotherhood\\Season 1\\[Reaktor] Fullmetal Alchemist Brotherhood - E32 v2 [1080p][x265][10-bit][Dual-Audio].mkv",
		episode: 32
		season: 1
		show: "Fullmetal Alchemist Brotherhood"
]

# Tests begin

describe 'getFileMeta', ->
	for d in testData
		test d.testName, ->
			meta = shows.getFileMeta d.fname, null, null
			expect meta.episode
				.toBe d.episode
			expect meta.season
				.toBe d.season
			expect meta.show
				.toBe d.show

