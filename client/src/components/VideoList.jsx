import React, { Component } from 'react'
import Video from './Video.jsx'

export default class VideoList extends Component {
	constructor(props){
		super(props)
		this.state = {videos: []}
	}
	async getVideoList(show){
		const videos = await (await fetch(`/shows/${show}`)).json()
		this.setState({videos: videos})
	}
	render() {
		if (!this.state.videos.length){
			return (
				<button className="primary large" onClick={() => this.getVideoList(this.props.show)}>Load episodes</button>
			)
		}
		let videoRenders = this.state.videos.map(function(video){
			return (
				<Video {...video} key={video.filename} />
			)
		});
		return (
			<div>
				<h3>Episodes</h3>
				{videoRenders}
			</div>
		)
	}
}
