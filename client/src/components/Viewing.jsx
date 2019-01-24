import React, { Component } from 'react'
import ViewingControls from './ViewingControls.jsx'

import { NoImage } from './Icons'

export default class Viewing extends Component {
	constructor(props){
		super(props)
	}
	render() {
		let img = (
			<NoImage />
		)
		let name = (
			<span><i>No video playing...</i></span>
		)
		const { currentVideo } = this.props
		if (currentVideo && currentVideo.show){
			if (currentVideo.show.image && currentVideo.show.image != "N/A"){
				img = (
					<img src={currentVideo.show.image}></img>
				)
			}
			name = (
				<span>{currentVideo.show.name} : {currentVideo.filename}</span>
			)
		}
		return (
			<div className="viewing flex column center">
				{img}
				<div className="controls text-center">
					{name}
				</div>
				<ViewingControls {...this.props} />
			</div>
		)
	}
}
