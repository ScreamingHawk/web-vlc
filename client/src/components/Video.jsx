import React, { Component } from 'react'

export default class Video extends Component {
	constructor(props){
		super(props)
	}
	async watchVideo(path){
		const videos = await (await fetch("/play", {
			method: "POST",
			body: JSON.stringify({
				path: path
			})
		})).json()
	}
	render() {
		return (
			<div className="video flex row spaced">
				<span>{this.props.filename}</span>
				<button className="success" onClick={() => this.watchVideo(this.props.path)}>Watch!</button>
			</div>
		)
	}
}
