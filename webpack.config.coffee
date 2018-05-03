webpack = require 'webpack'
path = require 'path'
CopyWebpackPlugin = require 'copy-webpack-plugin'

SRC_DIR = path.resolve __dirname, 'client/src'
BUILD_DIR = path.resolve __dirname, 'client/build'

IMG_SRC_DIR = path.resolve __dirname, 'client/src/img'
IMG_BUILD_DIR = path.resolve __dirname, 'client/build/img'

module.exports =
	entry:
		main: path.join SRC_DIR, 'index.js'
	output:
		filename: 'bundle.js'
		path: BUILD_DIR
	plugins: [
		CopyWebpackPlugin [
			test: /([^/]+)\/(.+)\.png$/
			from: IMG_SRC_DIR
			to: IMG_BUILD_DIR
		]
	]
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
				,
					test: /\.(png|jpg)$/
					use: [
						loader: "url-loader"
						options:
								limit: 8000
								name: "img/[name].[ext]"
					]
				,
					test: /\.svg$/
					use: [
						"babel-loader"
							loader: "react-svg-loader"
							options:
								jsx: false
					]
			]
