import React, { Component } from 'react'

export default class Video extends Component {
	constructor(props){
		super(props)
	}
	async watchVideo(path){
		await fetch("/play", {
			method: "POST",
			headers: {
				"Content-Type": "application/json"
			},
			body: JSON.stringify({
				path: path
			})
		})
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
			<div className="video flex row spaced">
				<span>{this.props.filename}</span>
				<button className="success" onClick={() => this.watchVideo(this.props.path)}>Watch!</button>
				<button className="danger" onClick={() => this.volume()}>Vol!</button>
			</div>
		)
	}
}
