import React, { Component } from 'react'
import { ToastContainer, toast } from 'react-toastify'
import no_image from '../img/no_image.png'

export default class Viewing extends Component {
	constructor(props){
		super(props)

		this.volume = this.volume.bind(this)
		this.seek = this.seek.bind(this)
		this.pause = this.pause.bind(this)
	}
	handleApiErrors(response){
		if (response.status == 503){
			toast.error("Error contact VLC!", {
				position: toast.POSITION.BOTTOM_CENTER
			})
		}
		return response
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
		}).then(this.handleApiErrors)
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
		}).then(this.handleApiErrors)
	}
	async pause(){
		await fetch("/play/pause", {
			method: "POST"
		}).then(this.handleApiErrors)
	}
	render() {
		let img = (
			<img src={no_image}></img>
		)
		let name = (
			<span><i>No video playing...</i></span>
		)
		if (this.props.show){
			if (this.props.show.image){
				img = (
					<img src={this.props.show.image}></img>
				)
			}
			name = (
				<span>{this.props.show.name} : {this.props.filename}</span>
			)
		}
		return (
			<div className="viewing flex column center">
				{img}
				<div className="controls text-center">
					{name}
				</div>
				<ToastContainer autoClose={3000} />
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
