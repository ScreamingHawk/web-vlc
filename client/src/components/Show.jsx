import React, { Component } from 'react'

import ShowDetails from './ShowDetails.jsx';
import VideoList from './VideoList.jsx'

import {
	NoImage,
	Mature,
} from './Icons'

export default class Show extends Component {
	constructor(props){
		super(props)

		this.unhideRated = this.unhideRated.bind(this)

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
		let seasonsOnDisk = "None"
		if (show.seasons.length > 0){
			seasonsOnDisk = show.seasons.map(s => `S${s}`).join(", ")
		}
		return (
			<div className={className} key={show.name}>
				{img}
				<div className="content">
					<h2>{show.name}</h2>
					<ShowDetails
						show={this.props.show}
						ratingHidden={this.state.ratingHidden}
					/>
					<p>
						<b>Seasons on disk:</b> {seasonsOnDisk}
						<br/>
						<b>No. episodes on disk:</b> {show.count}
					</p>
					{seasonRenders}
					{unseasonedRender}
				</div>
			</div>
		)
	}
}
