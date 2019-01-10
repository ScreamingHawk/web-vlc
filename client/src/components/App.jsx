import React, { Component } from 'react'
import createHistory from 'history/createBrowserHistory'
import ShowList from './ShowList.jsx'
import Streaming from './Streaming.jsx'
import Viewing from './Viewing.jsx'

const history = createHistory()

export default class App extends Component {
	constructor(props){
		super(props)

		this.setVideo = this.setVideo.bind(this)
		this.streamVideo = this.streamVideo.bind(this)

		history.listen((location, action) => {
			if (action == "POP"){
				this.toggleViewing(true)
				return false
			}
		})

		this.state = {
			location: "list",
			video: null,
		}

		fetch('/config/client').then((response)=>{
			return response.json()
		}).then((responseJson)=>{
			this.setState({
				config: responseJson,
			})
		})
	}
	toggleViewing(fromBack){
		if (!fromBack){
			history.push('/')
		}
		this.setState({
			location: this.state.location == "list" ? "viewing" : "list",
		})
	}
	async setVideo(video, justState=false){
		if (!justState){
			await fetch("/play", {
				method: "POST",
				headers: {
					"Content-Type": "application/json"
				},
				body: JSON.stringify({
					path: video.path
				})
			})
		}
		this.setState({
			location: "viewing",
			video: video
		})
	}
	async streamVideo(video){
		this.setState({
			location: "streaming",
			video: video,
		})
	}
	render(){
		const sendProps = {
			currentVideo: this.state.video,
			setVideo: this.setVideo,
			streamVideo: this.streamVideo,
			config: this.state.config,
		}
		let view
		let isViewingText = "View List"
		if (this.state.location == "viewing"){
			view = <Viewing {...sendProps} />
		} else if (this.state.location == "streaming"){
			view = <Streaming {...sendProps} />
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
