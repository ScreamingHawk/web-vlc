import React, { Component } from 'react'

export default class Viewing extends Component {
	constructor(props){
		super(props)

		this.showExtraButtons = this.showExtraButtons.bind(this)
		this.unwatchVideo = this.unwatchVideo.bind(this)

		this.state = {
			showExtraButtons: false,
		}
	}
	showExtraButtons(){
		this.setState({
			showExtraButtons: true,
		})
	}
	async unwatchVideo(){
		if (this.props.video != null){
			await fetch(`/shows/unwatch`, {
				method: "POST",
				headers: {
					"Content-Type": "application/json"
				},
				body: JSON.stringify({
					path: this.props.video.path
				}),
			}).then(this.props.handleApiErrors)
				.then(() => {
					console.log("unwatched");
					this.props.makeToast("Video marked as unwatched");
				})
		}
	}
	render() {
		let extraButtons = (
			<button className="info" onClick={this.showExtraButtons}>
				...
			</button>
		)
		if (this.state.showExtraButtons) {
			extraButtons = (
				<button className="warn" onClick={this.unwatchVideo}>
					Unwatch
				</button>
			)
		}
		return (
			<div className="controls">
				{extraButtons}
			</div>
		)
	}
}
