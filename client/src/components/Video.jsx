import React, { Component } from 'react'

export default class Video extends Component {
	constructor(props){
		super(props)

		this.watchVideo = this.watchVideo.bind(this)
	}
	async watchVideo(){
		await fetch("/play", {
			method: "POST",
			headers: {
				"Content-Type": "application/json"
			},
			body: JSON.stringify({
				path: this.props.path
			})
		})
		this.props.setVideo(this.props)
	}
	async volume(){
		await fetch("/play/volume", {
			method: "POST",
			headers: {
				"Content-Type": "application/json"
			},
			body: JSON.stringify({
				volume: "up"
			})
		})
	}
	render() {
		return (
			<div className="video flex row spaced center">
				<span>{this.props.filename}</span>
				<button className="success" onClick={this.watchVideo}>Watch!</button>
			</div>
		)
	}
}
