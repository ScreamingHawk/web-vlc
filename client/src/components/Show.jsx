import React, { Component } from 'react'

import VideoList from './VideoList.jsx'

import NoImage from '../img/no_image.svg'
import Mature from '../img/mature.svg'

export default class Show extends Component {
	constructor(props){
		super(props)

		this.unhideRated = this.unhideRated.bind(this)

		let ratingHidden = this.props.rating && (
				this.props.rating.indexOf("R") > -1 ||
				this.props.rating.indexOf("MA") > -1 ||
				this.props.rating.indexOf("N/A") > -1 // Assume not rated is lewd
			)
		this.state = {
			videos: [],
			ratingHidden: ratingHidden
		}
	}
	unhideRated(){
		this.setState({
			videos: this.state.videos,
			ratingHidden: false
		})
	}
	render(){
		let img = (
			<NoImage />
		)
		if (this.props.image && this.props.image != "N/A"){
			if (this.state.ratingHidden){
				img = (
					<Mature className="clickable" onClick={this.unhideRated} />
				)
			} else {
				img = (
					<img src={this.props.image}></img>
				)
			}
		}
		let plotP = (
			<p>{this.props.plot}</p>
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
		if (this.props.imdbRating){
			apiP = (
				<p>
					<b>IMDB Rating:</b> {this.props.imdbRating}
					<br/>
					<b>Rated:</b> {this.props.rating != null ? this.props.rating : "No Rating"}
				</p>
			)
		}
		return (
			<div className="box card" key={this.props.name}>
				{img}
				<div className="content">
					<h2>{this.props.name}</h2>
					{plotP}
					{apiP}
					<p>
						<b>Seasons on disk:</b> {this.props.seasons.length > 0 ? this.props.seasons.join(", ") : "None"}
						<br/>
						<b>Episodes on disk:</b> {this.props.count}
					</p>
					<VideoList show={this.props} setVideo={this.props.setVideo} />
				</div>
			</div>
		)
	}
}
