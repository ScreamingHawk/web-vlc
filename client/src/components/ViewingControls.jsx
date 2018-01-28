import React, { Component } from 'react'
import { ToastContainer, toast } from 'react-toastify'

import Slider from 'rc-slider'
import 'rc-slider/assets/index.css';

import Pause from '../img/pause.svg'
import Play from '../img/play.svg'
import VolumePlus from '../img/volume_plus.svg'
import VolumeMinus from '../img/volume_minus.svg'
import Rewind30s from '../img/rewind_30s.svg'
import PlayNext from '../img/play_next.svg'

export default class Viewing extends Component {
	constructor(props){
		super(props)

		this.handleApiErrors = this.handleApiErrors.bind(this)
		this.getVideoStatus = this.getVideoStatus.bind(this)
		this.tick = this.tick.bind(this)
		this.volume = this.volume.bind(this)
		this.seek = this.seek.bind(this)
		this.pause = this.pause.bind(this)
		this.getNextVideo = this.getNextVideo.bind(this)
		this.playNextVideo = this.playNextVideo.bind(this)

		this.state = {
			video: this.props.currentVideo,
			paused: false,
			videoLength: 0,
			videoTime: 0,
			nextVideo: null,
			vlcApiError: false,
		}
	}
	componentDidMount(){
		if (this.state.video){
			this.getVideoStatus()
			this.getNextVideo()
			// Tick every second
			setInterval(this.tick, 1000)
			// Call status every 2.5 seconds for variance
			setInterval(this.getVideoStatus, 2500)
		}
	}
	handleApiErrors(response){
		if (response.status == 503){
			if (!this.state.vlcApiError){
				this.setState({
					vlcApiError: true
				})
				toast.error("Error contact VLC!", {
					position: toast.POSITION.BOTTOM_CENTER
				})
			}
			return null
		}
		this.setState({
			vlcApiError: false
		})
		return response
	}
	apiJson(response){
		if (response != null && response.status == 200){
			return response.json()
		}
	}
	tick(){
		if (!this.state.paused){
			if (this.state.videoTime >= this.state.videoLength){
				this.setState({
					videoTime: this.state.videoLength,
					paused: true,
				})
			} else {
				this.setState({
					videoTime: this.state.videoTime + 1,
				})
			}
		}
	}
	async getVideoStatus(){
		await fetch(`/play/status`)
			.then(this.handleApiErrors)
			.then(this.apiJson)
			.then(status => {
				this.setState({
					videoLength: Number(status.length[0]),
					videoTime: Number(status.time[0]),
					paused: status.state[0] != "playing",
				})
			})
	}
	async getNextVideo(){
		await fetch(`/shows/${this.state.video.show.name}/${this.state.video.filename}/next`)
			.then(this.handleApiErrors)
			.then(this.apiJson)
			.then(video => {
				if (video != null){
					video.show = this.state.video.show
				}
				this.setState({
					nextVideo: video,
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
		if (!isNaN(val)){
			// Seeking to position, set time immediately
			this.setState({
				videoTime: val
			})
		}
		await fetch("/play/seek", {
				method: "POST",
				headers: {
					"Content-Type": "application/json"
				},
				body: JSON.stringify({
					seek: val
				})
			})
			.then(this.handleApiErrors)
			.then(response => {
				if (isNaN(val)){
					this.getVideoStatus()
				}
			})
	}
	async pause(){
		await fetch("/play/pause", {
			method: "POST"
		}).then(this.handleApiErrors)
		.then(response => {
			if (response){
				if (this.state.paused){
					// Unpause, update time
					this.getVideoStatus()
				}
				this.setState({
					paused: !this.state.paused,
				})
			}
		})
	}
	render() {
		const pauseIcon = this.state.paused ? (<Play />) : (<Pause />)
		const playNextButton = this.state.nextVideo == null ? null : (
			<button className="info" onClick={() => this.playNextVideo()}>
				<PlayNext />
			</button>
		)
		const formatTime = (seconds) => {
			if (seconds == null || seconds == 0){
				return "0:00"
			}
			let d = new Date(null)
			d.setSeconds(seconds)
			let time = d.toISOString().substr(11, 8)
			let c = time.charAt(0)
			while ((c == "0" || c == ":") && time.length > 4) {
				time = time.substr(1)
				c = time.charAt(0)
			}
			return time
		}
		const videoTimeTime = formatTime(this.state.videoTime)
		const videoLengthTime = formatTime(this.state.videoLength)
		return (
			<div>
				<ToastContainer autoClose={5000} />
				<div className="controls">
					<span>{videoTimeTime}</span>
					<Slider min={0} max={this.state.videoLength} value={this.state.videoTime} tipFormatter={formatTime} onChange={this.seek} />
					<span>{videoLengthTime}</span>
				</div>
				<div className="controls">
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
			</div>
		)
	}
}
