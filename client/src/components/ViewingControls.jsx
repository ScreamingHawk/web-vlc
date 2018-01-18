import React, { Component } from 'react'
import { ToastContainer, toast } from 'react-toastify'

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
		let pauseText = this.state.paused ? "Play" : "Pause"
		return (
			<div className="controls">
				<ToastContainer autoClose={3000} />
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
		)
	}
}
