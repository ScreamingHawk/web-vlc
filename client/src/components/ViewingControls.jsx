import React, { Component } from 'react'
import { ToastContainer, toast } from 'react-toastify'

import Pause from '../img/pause.svg'
import Play from '../img/play.svg'
import VolumePlus from '../img/volume_plus.svg'
import VolumeMinus from '../img/volume_minus.svg'
import Rewind30s from '../img/rewind_30s.svg'
import PlayNext from '../img/play_next.svg'

export default class Viewing extends Component {
	constructor(props){
		super(props)

		this.volume = this.volume.bind(this)
		this.seek = this.seek.bind(this)
		this.pause = this.pause.bind(this)
		this.getNextVideo = this.getNextVideo.bind(this)
		this.playNextVideo = this.playNextVideo.bind(this)

		this.state = {
			video: this.props.currentVideo,
			paused: false,
			nextVideo: null
		}
	}
	componentDidMount(){
		if (this.state.video){
			this.getNextVideo()
		}
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
	async getNextVideo(){
		await fetch(`/shows/${this.state.video.show.name}/${this.state.video.filename}/next`)
			.then(this.handleApiErrors)
			.then(response => {
				if (response.status == 200){
					return response.json()
				}
			}).then(video => {
				if (video != null){
					video.show = this.state.video.show
				}
				this.setState({
					video: this.state.video,
					paused: this.state.paused,
					nextVideo: video
				})
			})
	}
	playNextVideo(){
		if (this.state.nextVideo){
			this.props.setVideo(this.state.nextVideo)
			this.setState({
				video: this.state.nextVideo,
				paused: false,
				nextVideo: null
			}, this.getNextVideo)
		}
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
					video: this.state.video,
					paused: !this.state.paused,
					nextVideo: this.state.nextVideo
				})
			}
		})
	}
	render() {
		let pauseIcon = this.state.paused ? (<Play />) : (<Pause />)
		let playNextButton = this.state.nextVideo == null ? null : (
			<button className="info" onClick={() => this.playNextVideo()}>
				<PlayNext />
			</button>
		)
		return (
			<div className="controls">
				<ToastContainer autoClose={3000} />
				<button className="info" onClick={this.pause}>
					{pauseIcon}
				</button>
				<button className="info" onClick={() => this.volume("down")}>
					<VolumeMinus />
				</button>
				<button className="info" onClick={() => this.volume("up")}>
					<VolumePlus />
				</button>
				<button className="info" onClick={() => this.seek("-30s")}>
					<Rewind30s />
				</button>
				{playNextButton}
			</div>
		)
	}
}
