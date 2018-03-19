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
		const s = this.props.season || "none"
		const videos = await (await fetch(`/shows/${this.props.show.name}/seasons/${s}`)).json()
		this.setState({videos: videos})
	}
	resetVideoList(){
		this.setState({videos: []})
	}
	render() {
		let titleText = "Videos"
		let loadText = "Load videos"
		let hideText = "Hide videos"
		if (this.props.season){
			titleText = `Season ${this.props.season}`
			loadText = `Load season ${this.props.season}`
			hideText = `Hide season ${this.props.season}`
		}
		if (!this.state.videos.length){
			return (
				<button className="primary large tiny-vertical-margin block" onClick={this.getVideoList}>{loadText}</button>
			)
		}
		const setVideo = this.props.setVideo
		const show = this.props.show
		let videoRenders = this.state.videos.map(function(video){
			return (
				<Video {...video} key={video.filename} setVideo={setVideo} show={show} />
			)
		})
		return (
			<div className="tiny-vertical-margin">
				<div className="flex row spaced center">
					<h3>{titleText}</h3>
					<button className="primary" onClick={this.resetVideoList}>{hideText}</button>
				</div>
				{videoRenders}
			</div>
		)
	}
}
