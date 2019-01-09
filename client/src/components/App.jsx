import React, { Component } from 'react'
import createHistory from 'history/createBrowserHistory'
import ShowList from './ShowList.jsx'
import Viewing from './Viewing.jsx'

const history = createHistory()

export default class App extends Component {
	constructor(props){
		super(props)

		this.setVideo = this.setVideo.bind(this)

		history.listen((location, action) => {
			if (action == "POP"){
				this.toggleViewing(true)
				return false
			}
		})

		this.state = {
			isViewing: false,
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
			isViewing: !this.state.isViewing,
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
			isViewing: true,
			video: video
		})
	}
	render(){
		const sendProps = {
			currentVideo: this.state.video,
			setVideo: this.setVideo,
			config: this.state.config,
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
