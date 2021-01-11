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
		const { config, location, video } = this.state
		const sendProps = {
			currentVideo: video,
			setVideo: this.setVideo,
			streamVideo: this.streamVideo,
			config,
		}
		let view
		let isViewingText = "View List"
		if (location == "viewing"){
			view = <Viewing {...sendProps} />
		} else if (location == "streaming"){
			view = <Streaming {...sendProps} />
		} else {
			view = <ShowList {...sendProps} />
			isViewingText = "Now Playing"
		}
		// Generate MAL oAuth link
		let malFrag = null
		if (config && config.malLoggedIn){
			malFrag = <span>Logged in to MAL</span>
		} else if (config && config.malClientId){
			const malAuthUrl = `https://myanimelist.net/v1/oauth2/authorize?response_type=code&client_id=${config.malClientId}&redirect_uri=${window.location}verify&code_challenge=${config.challenge}&code_challenge_method=plain`
			malFrag = <a className="btn success" href={malAuthUrl}>Login to MAL</a>
		}
		return (
			<div>
				<header className="flex row spaced center">
					<h1>Video Viewer</h1>
					<div className="flex row end spaced-children center">
						<button className="info" onClick={() => this.toggleViewing()}>{isViewingText}</button>
						{ malFrag }
					</div>
				</header>
				{view}
			</div>
		)
	}
}
