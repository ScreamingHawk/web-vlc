import React, { Component } from 'react'
import ShowList from './ShowList.jsx'
import Viewing from './Viewing.jsx'

export default class App extends Component {
	constructor(props){
		super(props)

		this.setVideo = this.setVideo.bind(this)

		this.state = {
			isViewing: false,
			video: null
		}
	}
	toggleViewing(){
		this.setState({
			isViewing: !this.state.isViewing,
			video: this.state.video
		})
	}
	async setVideo(video){
		await fetch("/play", {
			method: "POST",
			headers: {
				"Content-Type": "application/json"
			},
			body: JSON.stringify({
				path: video.path
			})
		})
		this.setState({
			isViewing: true,
			video: video
		})
	}
	render(){
		const sendProps = {
			currentVideo: this.state.video,
			setVideo: this.setVideo
		}
		let view
		let isViewingText
		if (this.state.isViewing){
			view = <Viewing {...sendProps} />
			isViewingText = "View List"
		} else {
			view = <ShowList {...sendProps} />
			isViewingText = "Now Playing"
		}
		return (
			<div>
				<header className="flex row spaced center">
					<h1>Video Viewer</h1>
					<button className="info" onClick={() => this.toggleViewing()}>{isViewingText}</button>
				</header>
				{view}
			</div>
		)
	}
}
