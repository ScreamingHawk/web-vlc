import React, { Component } from 'react'

export default class Video extends Component {
	constructor(props){
		super(props)

		this.watchVideo = this.watchVideo.bind(this)
	}
	watchVideo(){
		this.props.setVideo(this.props)
	}
	render() {
		const classN = this.props.watched ? "warn" : "success"
		let dlButton = null
		if (this.props.config && this.props.config.dlEnabled){
			const downloadUrl = `/download/${this.props.path}`
			dlButton = (
				<a className="btn info" href={downloadUrl} download>⤓</a>
			)
		}
		const downloadUrl = `/download/${this.props.path}`
		return (
			<div className="video flex row spaced center">
				<span>{this.props.filename}</span>
				<div className="flex row spaced-children">
					<button className={classN} onClick={this.watchVideo}>Watch!</button>
					{dlButton}
				</div>
			</div>
		)
	}
}
