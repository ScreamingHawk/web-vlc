webpack = require 'webpack'
path = require 'path'

BUILD_DIR = path.resolve __dirname, 'client/build'
SRC_DIR = path.resolve __dirname, 'client/src'

module.exports =
	entry:
		main: path.join SRC_DIR, 'index.js'
	output:
		filename: 'bundle.js'
		path: BUILD_DIR
	module:
			rules: [
					test: /\.(css|scss)$/
					use: [
							loader: "style-loader"
						,
							loader: "css-loader"
						,
							loader: "sass-loader"
					]
				,
					test: /\.(jsx|js)?$/
					use: [
						loader: "babel-loader"
						options:
								cacheDirectory: true
								presets: [
									"react"
									"es2015"
								]
					]
			]
