import React, { Component } from 'react'

import VideoList from './VideoList.jsx'

import NoImage from '../img/no_image.svg'
import Mature from '../img/mature.svg'

export default class Show extends Component {
	constructor(props){
		super(props)

		this.unhideRated = this.unhideRated.bind(this)

		const { show } = this.props

		const isCurrentShow = this.props.currentVideo != null && this.props.currentVideo.show.name == show.name
		const ratingHidden = !isCurrentShow && show.rating && (
				show.rating.indexOf("R") > -1 ||
				show.rating.indexOf("MA") > -1 ||
				show.rating.indexOf("N/A") > -1 // Assume not rated is lewd
			)
		this.state = {
			videos: [],
			ratingHidden: ratingHidden,
			isCurrentShow: isCurrentShow
		}
	}
	unhideRated(){
		this.setState({
			ratingHidden: false
		})
	}
	render(){
		const { show } = this.props
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
		let plotP = (
			<p>{show.plot}</p>
		)
		if (this.state.ratingHidden){
			plotP = (
				<p><i>Plot hidden.</i></p>
			)
		}
		let apiP = (
			<p>
				<i>Details not found.</i>
			</p>
		)
		if (show.imdbRating){
			apiP = (
				<p>
					<b>IMDB Rating:</b> {show.imdbRating}
					<br/>
					<b>Rated:</b> {show.rating != null ? show.rating : "No Rating"}
				</p>
			)
		}
		let className = "box card"
		if (this.state.isCurrentShow){
			className += " highlight"
		}
		let seasonRenders = null
		const setVideo = this.props.setVideo
		const config = this.props.config
		if (show.seasons){
			seasonRenders = show.seasons.map(function(season){
				return (
					<VideoList config={config} show={show} season={season} setVideo={setVideo} key={season} />
				)
			})
		}
		let unseasonedRender = null
		if (show.hasUnseasoned){
			unseasonedRender = (
				<VideoList config={config} show={show} setVideo={setVideo} />
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
