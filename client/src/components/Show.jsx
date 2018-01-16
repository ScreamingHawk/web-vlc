import React, { Component } from 'react'
import VideoList from './VideoList.jsx'

export default class Show extends Component {
	constructor(props){
		super(props)
		this.state = {videos: []}
	}
	render() {
		//TODO Placeholder image
		let imgSrc = null
		if (this.props.image){
			imgSrc = this.props.image
		}
		return (
			<div className="box card inverted" key={this.props.name}>
				<img src={imgSrc}></img>
				<div className="content">
					<h2>{this.props.name}</h2>
					<p>{this.props.plot}</p>
					<p>
						<b>IMDB Rating:</b> {this.props.imdbRating}
					</p>
					<p>
						<b>Seasons on disk:</b> {this.props.seasons.length > 0 ? this.props.seasons.join(", ") : "None"}
						<br/>
						<b>Episodes on disk:</b> {this.props.count}
					</p>
					<VideoList show={this.props.name} />
				</div>
			</div>
		)
	}
}
