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
		return (
			<div className="video flex row spaced center">
				<span>{this.props.filename}</span>
				<button className={classN} onClick={this.watchVideo}>Watch!</button>
			</div>
		)
	}
}
