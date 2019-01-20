import React, { Component } from 'react'

import VideoList from './VideoList.jsx'

import NoImage from '../img/no_image.svg'
import Mature from '../img/mature.svg'

export default class Show extends Component {
	constructor(props){
		super(props)

		this.unhideRated = this.unhideRated.bind(this)
		this.unshortenPlot = this.unshortenPlot.bind(this)

		const { show } = this.props

		const isCurrentShow = this.props.currentVideo != null && this.props.currentVideo.show.name == show.name
		const ratingHidden = !isCurrentShow && show.rating && (
				show.rating.indexOf("X") > -1 ||
				show.rating.indexOf("R") > -1 ||
				show.rating.indexOf("MA") > -1 ||
				show.rating.indexOf("N/A") > -1 // Assume not rated is lewd
			)
		this.state = {
			videos: [],
			shortenPlot: true,
			shortenPlotTo: 120,
			ratingHidden: ratingHidden,
			isCurrentShow: isCurrentShow
		}
	}
	unhideRated(){
		this.setState({
			ratingHidden: false
		})
	}
	unshortenPlot(e){
		e.preventDefault();
		e.stopPropagation();
		this.setState({
			shortenPlot: false
		})
	}
	render(){
		const { show } = this.props
		// Image
		let img = (
			<NoImage />
		)
		if (show.image && show.image != "N/A"){
			if (this.state.ratingHidden){
				img = (
					<Mature className="clickable" onClick={this.unhideRated} />
				)
			} else {
				img = (
					<img src={show.image}></img>
				)
			}
		}
		// Plot
		let plotP = null
		if (show.plot){
			plotP = (
				<p>{show.plot}</p>
			)
			if (this.state.ratingHidden){
				plotP = (
					<p><i>Plot hidden.</i></p>
				)
			} else if (show.plot.length > this.state.shortenPlotTo - 10 && this.state.shortenPlot){
				plotP = (
					<p>
						{show.plot.substring(0, this.state.shortenPlotTo)}...
						&nbsp;
						<a href="" onClick={this.unshortenPlot}>more</a>
					</p>
				)
			}
		}
		// Other api data
		let apiP = (
			<p>
				<i>Details not found.</i>
			</p>
		)
		if (show.genres || show.malRating || show.imdbRating || show.rating){
			apiP = (
				<p>
					{
						show.genres && [
							<span><b>Genres:</b> {show.genres}</span>,
							<br/>,
						]
					}
					{
						show.malRating && [
							<span><b>MAL Rating:</b> {show.malRating}</span>,
							<br/>,
						]
					}
					{
						show.imdbRating && [
							<span><b>IMDB Rating:</b> {show.imdbRating}</span>,
							<br/>,
						]
					}
					<b>Rated:</b> {show.rating != null ? show.rating : "No Rating"}
				</p>
			)
		}
		let className = "box card"
		if (this.state.isCurrentShow){
			className += " highlight"
		}
		let seasonRenders = null
		const sendProps = {
			show: show,
			setVideo: this.props.setVideo,
			streamVideo: this.props.streamVideo,
			config: this.props.config,
		};
		if (show.seasons){
			seasonRenders = show.seasons.map(function(season){
				return (
					<VideoList {...sendProps} season={season} key={show.name+season} />
				)
			})
		}
		let unseasonedRender = null
		if (show.hasUnseasoned){
			unseasonedRender = (
				<VideoList {...sendProps} key={show.name+"0"} />
			)
		}
		return (
			<div className={className} key={show.name}>
				{img}
				<div className="content">
					<h2>{show.name}</h2>
					{plotP}
					{apiP}
					<p>
						<b>Seasons on disk:</b> {show.seasons.length > 0 ? show.seasons.join(", ") : "None"}
						<br/>
						<b>Episodes on disk:</b> {show.count}
					</p>
					{seasonRenders}
					{unseasonedRender}
				</div>
			</div>
		)
	}
}
