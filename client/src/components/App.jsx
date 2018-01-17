import React, { Component } from 'react'
import ShowList from './ShowList.jsx'
import Viewing from './Viewing.jsx'

export default class App extends Component {
	constructor(props){
		super(props)
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
	setVideo(video){
		this.setState({
			isViewing: true,
			video: video
		})
	}
	render(){
		let view
		let isViewingText
		if (this.state.isViewing){
			view = <Viewing />
			isViewingText = "View List"
		} else {
			view = <ShowList />
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
