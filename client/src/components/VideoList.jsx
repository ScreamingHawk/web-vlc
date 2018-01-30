import React, { Component } from 'react'
import Video from './Video.jsx'

export default class VideoList extends Component {
	constructor(props){
		super(props)
		this.state = {videos: []}

		this.getVideoList = this.getVideoList.bind(this)
		this.resetVideoList = this.resetVideoList.bind(this)
	}
	async getVideoList(){
		const videos = await (await fetch(`/shows/${this.props.show.name}`)).json()
		this.setState({videos: videos})
	}
	resetVideoList(){
		this.setState({videos: []})
	}
	render() {
		if (!this.state.videos.length){
			return (
				<button className="primary large" onClick={this.getVideoList}>Load episodes</button>
			)
		}
		const setVideo = this.props.setVideo
		const show = this.props.show
		let videoRenders = this.state.videos.map(function(video){
			return (
				<Video {...video} key={video.filename} setVideo={setVideo} show={show} />
			)
		});
		return (
			<div>
				<div className="flex row spaced center">
					<h3>Episodes</h3>
					<button className="primary" onClick={this.resetVideoList}>Hide episodes</button>
				</div>
				{videoRenders}
			</div>
		)
	}
}
