import React, { Component } from 'react'

import DownloadIcon from '../img/download.svg'
import StreamIcon from '../img/stream.svg'

export default class Video extends Component {
	constructor(props){
		super(props)

		this.watchVideo = this.watchVideo.bind(this)
		this.streamVideo = this.streamVideo.bind(this)
	}
	watchVideo(){
		this.props.setVideo(this.props)
	}
	streamVideo(){
		this.props.streamVideo(this.props)
	}
	render() {
		const classN = this.props.watched ? "warn" : "success"
		let dlButton = null
		let streamButton = null
		if (this.props.config){
			if (this.props.config.downloadEnabled){
				const downloadUrl = `/download/${this.props.path}`
				dlButton = (
					<a className="btn info" href={downloadUrl} download>
						<DownloadIcon />
					</a>
				)
			}
			if (this.props.config.streamEnabled){
				streamButton = (
					<button className="info" onClick={this.streamVideo}>
						<StreamIcon />
					</button>
				)
			}
		}
		return (
			<div className="video flex row spaced center">
				<span>{this.props.filename}</span>
				<div className="flex row spaced-children">
					<button className={classN} onClick={this.watchVideo}>Watch!</button>
					{dlButton}
					{streamButton}
				</div>
			</div>
		)
	}
}
