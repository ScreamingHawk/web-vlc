import React, { Component } from 'react'
import no_image from '../img/no_image.png'
import VideoList from './VideoList.jsx'

export default class Show extends Component {
	constructor(props){
		super(props)
		this.state = {videos: []}
	}
	render(){
		let img
		if (this.props.image){
			img = (
				<img src={this.props.image}></img>
			)
		} else {
			img = (
				<img src={no_image}></img>
			)
		}
		let apiP
		if (this.props.imdbRating){
			apiP = (
				<p>
					<b>IMDB Rating:</b> {this.props.imdbRating}
				</p>
			)
		} else {
			apiP = (
				<p>
					<i>Details not found.</i>
				</p>
			)
		}
		return (
			<div className="box card" key={this.props.name}>
				{img}
				<div className="content">
					<h2>{this.props.name}</h2>
					<p>{this.props.plot}</p>
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
