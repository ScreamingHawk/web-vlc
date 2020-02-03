requireYaml = require 'require-yml'
fs = require 'fs'
path = require 'path'

mal = require './mal'

# Get real config
realConfig = null
configPath = path.join __dirname, '..', 'config.yaml'
if fs.existsSync configPath
	realConfig = requireYaml configPath

# Mock data
createMockConfig = ->
	api:
		mal:
			enabled: true
			url: "https://myanimelist.net/"
data = {}
common =
	storeData: ->
createMockShow = ->
	{
		"name": "Citrus",
		"seasons": [
			1,
			2
		],
		"hasUnseasoned": false,
		"count": 7,
		"videos": [
			{
				"path": "C:\\Users\\MichaelSta\\Videos\\Anime\\Citrus\\Season 1\\epi1.mp4",
				"api": "mal",
				"filename": "epi1.mp4",
				"mime": "video/mp4",
				"season": 1,
				"show": "Citrus",
				"watched": true
			},
			{
				"path": "C:\\Users\\MichaelSta\\Videos\\Anime\\Citrus\\Season 1\\epi2.flv",
				"api": "mal",
				"filename": "epi2.flv",
				"mime": "video/x-flv",
				"season": 1,
				"show": "Citrus",
				"watched": false
			},
			{
				"path": "C:\\Users\\MichaelSta\\Videos\\Anime\\Citrus\\Season 1\\epi3.mkv",
				"api": "mal",
				"filename": "epi3.mkv",
				"mime": "video/x-matroska",
				"season": 1,
				"show": "Citrus",
				"watched": false
			},
			{
				"path": "C:\\Users\\MichaelSta\\Videos\\Anime\\Citrus\\Season 2\\SampleVideo_1280x720_1mb.mp4",
				"api": "mal",
				"filename": "SampleVideo_1280x720_1mb.mp4",
				"mime": "video/mp4",
				"episode": 12,
				"season": 2,
				"show": "Citrus",
				"watched": false
			},
			{
				"path": "C:\\Users\\MichaelSta\\Videos\\Anime\\Citrus\\Season 2\\SampleVideo_1280x720_2mb.flv",
				"api": "mal",
				"filename": "SampleVideo_1280x720_2mb.flv",
				"mime": "video/x-flv",
				"episode": 12,
				"season": 2,
				"show": "Citrus",
				"watched": false
			},
			{
				"path": "C:\\Users\\MichaelSta\\Videos\\Anime\\Citrus\\Season 2\\SampleVideo_1280x720_2mb.mkv",
				"api": "mal",
				"filename": "SampleVideo_1280x720_2mb.mkv",
				"mime": "video/x-matroska",
				"episode": 12,
				"season": 2,
				"show": "Citrus",
				"watched": false
			},
			{
				"path": "C:\\Users\\MichaelSta\\Videos\\Anime\\Citrus\\Season 2\\SampleVideo_1280x720_2mb.mp4",
				"api": "mal",
				"filename": "SampleVideo_1280x720_2mb.mp4",
				"mime": "video/mp4",
				"episode": 12,
				"season": 2,
				"show": "Citrus",
				"watched": false
			}
		],
		"api": "mal",
		"source": "https://myanimelist.net/anime/34382/Citrus",
		"image": "https://myanimelist.cdn-dena.com/images/anime/11/89985.jpg",
		"plot": "During the summer of her freshman year of high school, Yuzu Aihara's mother remarried,
	forcing her to transfer to a new school. To a fashionable socialite like Yuzu, this inconvenient event is just another opportunity to make new friends, fall in love, and finally experience a first kiss. Unfortunately, Yuzu's dreams and style do not conform with her new ultrastrict, all-girls school, filled with obedient shut-ins and overachieving grade-skippers. Her gaudy appearance manages to grab the attention of Mei Aihara, the beautiful and imposing student council president, who immediately proceeds to sensually caress Yuzu's body in an effort to confiscate her cellphone.\n\nThoroughly exhausted from her first day, Yuzu arrives home and discovers a shocking truth—Mei is actually her new step-sister! Though Yuzu initially tries to be friendly with her, Mei's cold shoulder routine forces Yuzu to begin teasing her. But before Yuzu can finish her sentence, Mei forces her to the ground and kisses her, with Yuzu desperately trying to break free. Once done, Mei storms out of the room, leaving Yuzu to ponder the true nature of her first kiss, and the secrets behind the tortured expression in the eyes of her new sister.",
		"genres": "Drama, Romance, School, Shoujo Ai",
		"score": "6.79",
		"rating": "PG-13 - Teens 13 or older"
	}

beforeAll ->
	mal.init createMockConfig(), data, common

# Tests begin

describe 'checkUseMal', ->
	test 'enabled', ->
		# Data
		conf = createMockConfig()
		show = createMockShow()
		mal.init conf, data, common
		# Test
		expect mal.checkUseMal show
			.toBe true

	test 'wrong api', ->
		# Data
		conf = createMockConfig()
		show = createMockShow()
		show.api = "wrong"
		mal.init conf, data, common
		# Test
		expect mal.checkUseMal show
			.toBe false

	test 'config disabled', ->
		# Data
		conf = createMockConfig()
		conf.api.mal.enabled = false
		show = createMockShow()
		mal.init conf, data, common
		# Test
		expect mal.checkUseMal show
			.toBe false

	test 'config disabled and api wrong', ->
		# Data
		conf = createMockConfig()
		conf.api.mal.enabled = false
		show = createMockShow()
		show.api = "wrong"
		mal.init conf, data, common
		# Test
		expect mal.checkUseMal show
			.toBe false

	test 'forced', ->
		# Data
		conf = createMockConfig()
		show = createMockShow()
		mal.init conf, data, common
		# Test
		expect mal.checkUseMal show, true
			.toBe true

	test 'wrong api and forced', ->
		# Data
		conf = createMockConfig()
		show = createMockShow()
		show.api = "wrong"
		mal.init conf, data, common
		# Test
		expect mal.checkUseMal show, true
			.toBe true

	test 'config disabled and forced', ->
		# Data
		conf = createMockConfig()
		conf.api.mal.enabled = false
		show = createMockShow()
		mal.init conf, data, common
		# Test
		expect mal.checkUseMal show, true
			.toBe false

	return

describe 'getTokens', ->
	test 'callback err on no creds', (done)->
		mal.getTokens (err)->
			expect err
				.toBe "Unable to login to MAL, please set your credentials"
			done()
	return

describe 'getShowPage', ->
	test 'gets Madoka', (done)->
		show =
			name: 'Mahou Shoujo Madoka'
		mal.userOrSearchSource show, (err, url)->
			expect url
				.toBe "https://myanimelist.net/anime/9756/Mahou_Shoujo_Madoka%E2%98%85Magica"
			done()
	return

describe 'getAnimeId', ->
	test 'gets Id', ->
		expect mal.getAnimeId "https://myanimelist.net/anime/9756/Mahou_Shoujo_Madoka%E2%98%85Magica"
			.toBe 9756
		expect mal.getAnimeId "https://myanimelist.net/anime/1234/asdf"
			.toBe 1234

	test 'gets Id with trailing slash', ->
		expect mal.getAnimeId "https://myanimelist.net/anime/9756/Mahou_Shoujo_Madoka%E2%98%85Magica/"
			.toBe 9756
		expect mal.getAnimeId "https://myanimelist.net/anime/1234/asdf/"
			.toBe 1234

	test 'gets Id without name', ->
		expect mal.getAnimeId "https://myanimelist.net/anime/9756/"
			.toBe 9756
		expect mal.getAnimeId "https://myanimelist.net/anime/1234"
			.toBe 1234

	test 'handles errors', ->
		expect mal.getAnimeId "https://myanimelist.net/anime/"
			.toBeNull()
		expect mal.getAnimeId()
			.toBeNull()

	return
