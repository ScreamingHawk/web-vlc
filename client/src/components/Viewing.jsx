import React, { Component } from 'react'
import { ToastContainer, toast } from 'react-toastify'
import ViewingControls from './ViewingControls.jsx'

import NoImage from '../img/no_image.svg'

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
		if (this.props.show){
			if (this.props.show.image && this.props.show.image != "N/A"){
				img = (
					<img src={this.props.show.image}></img>
				)
			}
			name = (
				<span>{this.props.show.name} : {this.props.filename}</span>
			)
		}
		return (
			<div className="viewing flex column center">
				{img}
				<div className="controls text-center">
					{name}
				</div>
				<ViewingControls video={this.props} setVideo={this.props.setVideo} />
			</div>
		)
	}
}
