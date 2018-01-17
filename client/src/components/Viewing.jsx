import React, { Component } from 'react'
import no_image from '../img/no_image.png'

export default class Viewing extends Component {
	constructor(props){
		super(props)
	}
	async volume(val){
		await fetch("/play/volume", {
			method: "POST",
			headers: {
				"Content-Type": "application/json"
			},
			body: JSON.stringify({
				volume: val
			})
		})
	}
	async seek(val){
		await fetch("/play/seek", {
			method: "POST",
			headers: {
				"Content-Type": "application/json"
			},
			body: JSON.stringify({
				seek: val
			})
		})
	}
	async pause(){
		await fetch("/play/pause", {
			method: "POST"
		})
	}
	render() {
		let img
		if (this.props.image){
			img = (
				<img src={this.props.image}></img>
			)
		} else {
			img = (
				<img src={no_image}></img>
			)
		}
		return (
			<div className="viewing flex column center">
				{img}
				<div className="controls">
					<button className="info" onClick={this.pause}>Pause</button>
					<button className="info" onClick={() => this.volume("down")}>Vol down</button>
					<button className="info" onClick={() => this.volume("up")}>Vol up</button>
					<button className="info" onClick={() => this.seek("-30s")}>Rewind 30s</button>
				</div>
			</div>
		)
	}
}
