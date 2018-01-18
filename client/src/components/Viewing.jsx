import React, { Component } from 'react'
import { ToastContainer, toast } from 'react-toastify'

import NoImage from '../img/no_image.svg'
import VolumePlus from '../img/volume_plus.svg'
import VolumeMinus from '../img/volume_minus.svg'
import Rewind30s from '../img/rewind_30s.svg'

export default class Viewing extends Component {
	constructor(props){
		super(props)

		this.state = {
			paused: false
		}

		this.volume = this.volume.bind(this)
		this.seek = this.seek.bind(this)
		this.pause = this.pause.bind(this)
	}
	handleApiErrors(response){
		if (response.status == 503){
			toast.error("Error contact VLC!", {
				position: toast.POSITION.BOTTOM_CENTER
			})
			return null
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
		.then((response) => {
			if (response){
				this.setState({
					paused: !this.state.paused
				})
			}
		})
	}
	render() {
		let img = (
			<NoImage />
		)
		let name = (
			<span><i>No video playing...</i></span>
		)
		if (this.props.show){
		if (this.props.image && this.props.image != "N/A"){
				img = (
					<img src={this.props.show.image}></img>
				)
			}
			name = (
				<span>{this.props.show.name} : {this.props.filename}</span>
			)
		}
		console.log(this.state.paused)
		let pauseText = this.state.paused ? "Play" : "Pause"
		return (
			<div className="viewing flex column center">
				{img}
				<div className="controls text-center">
					{name}
				</div>
				<ToastContainer autoClose={3000} />
				<div className="controls">
					<button className="info" onClick={this.pause}>{pauseText}</button>
					<button className="info" onClick={() => this.volume("down")}>
						<VolumeMinus />
					</button>
					<button className="info" onClick={() => this.volume("up")}>
						<VolumePlus />
					</button>
					<button className="info" onClick={() => this.seek("-30s")}>
						<Rewind30s />
					</button>
				</div>
			</div>
		)
	}
}
