import React, { Component } from 'react'
import { ToastContainer, toast } from 'react-toastify'

import Slider from 'rc-slider'
import 'rc-slider/assets/index.css';

import ViewingControlsExtras from './ViewingControlsExtras.jsx';

import {
	VolumePlus,
	VolumeMinus,
	Rewind,
	FastForward,
	PlayNext,
	Pause,
	Play,
} from './Icons'

export default class Viewing extends Component {
	constructor(props){
		super(props)

		this.handleApiErrors = this.handleApiErrors.bind(this)
		this.getVlcFilename = this.getVlcFilename.bind(this)
		this.getVlcFilenameFromStatus = this.getVlcFilenameFromStatus.bind(this)
		this.updateVideoUsingFilename = this.updateVideoUsingFilename.bind(this)
		this.updatePlayingVideo = this.updatePlayingVideo.bind(this)
		this.getVideoStatus = this.getVideoStatus.bind(this)
		this.tick = this.tick.bind(this)
		this.volume = this.volume.bind(this)
		this.seek = this.seek.bind(this)
		this.pause = this.pause.bind(this)
		this.getNextVideo = this.getNextVideo.bind(this)
		this.playNextVideo = this.playNextVideo.bind(this)
		this.makeToast = this.makeToast.bind(this)

		this.state = {
			video: this.props.currentVideo,
			vlcFilename: null, // Sometimes this is different because VLC...
			paused: true, // Start paused. The status check will unpause
			videoLength: 0,
			videoTime: 0,
			volume: 0,
			volumeToastId: null,
			testVolume: false,
			nextVideo: null,
			vlcErrorToastId: null,
			intervals: [],
		}
	}
	componentDidMount(){
		if (this.state.video){
			this.getVideoStatus()
			this.getNextVideo()
			let intervals = []
			// Tick every second
			intervals.push(setInterval(this.tick, 1000))
			// Call status every 2.5 seconds for variance
			intervals.push(setInterval(this.getVideoStatus, 2500))
			this.getVlcFilename()
			this.setState({
				intervals: intervals,
			})
		} else {
			this.updatePlayingVideo()
		}
	}
	componentWillUnmount(){
		for (let interval of this.state.intervals){
			clearInterval(interval)
		}
	}
	handleApiErrors(response){
		let vlcErrorToastId = this.state.vlcErrorToastId
		if (response.status == 503){
			if (!toast.isActive(vlcErrorToastId)){
				// Clear all toasts
				toast.dismiss()
				vlcErrorToastId = this.makeToast("Error contacting VLC!", "error", false);
				this.setState({
					vlcErrorToastId: vlcErrorToastId,
				})
			}
			return null
		}
		if (vlcErrorToastId){
			toast.dismiss(vlcErrorToastId)
		}
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
	updatePlayingVideo(){
		fetch(`/play/nowplaying`)
			.then(this.handleApiErrors)
			.then(this.apiJson)
			.then(response => {
				if ((response != null && response.filename != null) &&
						(this.state.video == null || this.state.video.filename == null)){
					this.updateVideoUsingFilename(response.filename)
				}
			})
	}
	getVlcFilename(callback){
		fetch(`/play/status`)
			.then(this.handleApiErrors)
			.then(this.apiJson)
			.then(status => {
				if (this.state.video == null || this.state.video.filename == null){
					const filename = this.getVlcFilenameFromStatus(status)
					this.setState({
						vlcFilename: filename
					}, ()=>{
						if (callback != null){
							callback()
						}
					})
				}
			})
	}
	getVlcFilenameFromStatus(status){
		if (status != null){
			try {
				for (let i of status.information[0].category[0].info){
					if (i["$"].name == "filename"){
						return i["_"]
					}
				}
			} catch (e){
				if (e instanceof TypeError){
					// Some unexpected status type
					console.log("TypeError reading status response", e)
				} else {
					throw e
				}
			}
		}
	}
	updateVideoUsingFilename(filename){
		// Got a playing video. Try to find it
		fetch(`/shows/search`, {
			method: "POST",
			headers: {
				"Content-Type": "application/json"
			},
			body: JSON.stringify({
				filename: filename || this.state.vlcFilename
			})
		})
		.then(this.handleApiErrors)
		.then(this.apiJson)
		.then(video => {
			if (video != null){
				this.props.setVideo(video, true)
				this.setState({
					video: video
				}, () => {
					// Try the mounting stuff again
					this.componentWillUnmount()
					this.componentDidMount()
				})
			} else {
				this.makeToast("Error getting playing video!", "error");
			}
		})
	}
	async getVideoStatus(){
		await fetch(`/play/status`)
			.then(this.handleApiErrors)
			.then(this.apiJson)
			.then(status => {
				if (status != null){
					if (this.state.vlcFilename != null){
						let vlcFilename = this.getVlcFilenameFromStatus(status)
						if (vlcFilename != this.state.vlcFilename){
							this.setState({
								vlcFilename: vlcFilename
							}, this.updateVideoUsingFilename)
							return
						}
					}
					let statusVolume = Number(status.volume[0])
					let volumeToastId = this.state.volumeToastId
					if (statusVolume >= 300){
						// Max is 320 but give some buffer
						if (!toast.isActive(volumeToastId) && this.state.testVolume){
							volumeToastId = this.makeToast("Volume at max");
						}
					} else if (volumeToastId) {
						toast.dismiss(volumeToastId)
					}
					this.setState({
						videoLength: Number(status.length[0]),
						videoTime: Number(status.time[0]),
						paused: status.state[0] != "playing",
						volume: statusVolume,
						volumeToastId: volumeToastId,
						testVolume: false,
					})
				}
			})
	}
	async getNextVideo(){
		if (this.state.video != null){
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
		if (!isNaN(val)){
			// Setting volume directly, update immediately
			this.setState({
				volume: val,
			})
		}
		await fetch("/play/volume", {
				method: "POST",
				headers: {
					"Content-Type": "application/json"
				},
				body: JSON.stringify({
					volume: val
				})
			})
			.then(this.handleApiErrors)
			.then(response => {
				if (isNaN(val)){
					this.setState({
						testVolume: true,
					}, this.getVideoStatus);
				}
			})
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
			.then(() => {
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
	makeToast(msg, type="info", autoClose=true){
		const args = {
			position: toast.POSITION.BOTTOM_CENTER,
			autoClose: autoClose,
		};
		if (type == "info"){
			return toast.info(msg, args);
		} else if (type == "error") {
			return toast.error(msg, args);
		}
	}
	render() {
		const skipSeconds = this.props.config.skipSeconds || 20;
		const pauseIcon = this.state.paused ? (<Play />) : (<Pause />)
		const playNextButton = this.state.nextVideo == null ? null : (
			<button className="info" onClick={() => this.playNextVideo()}>
				<PlayNext />
			</button>
		)
		const formatTime = (time) => {
			if (time == null || time == 0){
				return "0:00"
			}
			let seconds = time % 60
			let minutes = Math.floor(time / 60) % 60
			let hours = Math.floor(time / 3600)
			let formatted = ""
			if (hours > 0){
				formatted = hours + ":"
			}
			if (hours > 0){
				formatted += String(minutes).padStart(2, "0") + ":"
			} else {
				formatted = minutes + ":"
			}
			formatted += String(seconds).padStart(2, "0")
			return formatted
		}
		// Source link
		let sourceLink = null
		if (this.state.video && this.state.video.show && this.state.video.show.api && this.state.video.show.source){
			const { show } = this.state.video
			let sourceLabel = "Source"
			if (show.api == "mal"){
				sourceLabel = "MyAnimeList Source"
			} else if (show.api == "omdb"){
				sourceLabel = "IMDB Source"
			}
			sourceLink = (
				<p className="text-center">
					<span><a href={show.source}>{sourceLabel}</a></span>
				</p>
			)
		}
		const sendProps = {
			handleApiErrors: this.handleApiErrors,
			makeToast: this.makeToast,
			video: this.state.video,
		};
		return (
			<div>
				<ToastContainer autoClose={5000} />
				<div className="slider-box">
					<span>{formatTime(this.state.videoTime)}</span>
					<Slider min={0} max={this.state.videoLength} value={this.state.videoTime} tipFormatter={formatTime} onChange={this.seek} />
					<span>{formatTime(this.state.videoLength)}</span>
				</div>
				<div className="controls">
					<button className="info" onClick={this.pause}>
						{pauseIcon}
					</button>
					<button className="info" onClick={() => this.seek(`-${skipSeconds}s`)}>
						<Rewind seconds={skipSeconds} />
					</button>
					<button className="info" onClick={() => this.seek(`+${skipSeconds}s`)}>
						<FastForward seconds={skipSeconds} />
					</button>
					<button className="info" onClick={() => this.volume("down")}>
						<VolumeMinus />
					</button>
					<button className="info" onClick={() => this.volume("up")}>
						<VolumePlus />
					</button>
					{playNextButton}
				</div>
				<ViewingControlsExtras {...this.props} {...sendProps} />
				{ sourceLink }
			</div>
		)
	}
}
