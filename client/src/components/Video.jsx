import React, { Component } from 'react'

export default class Video extends Component {
	constructor(props){
		super(props)
	}
	render() {
		return (
			<div className="video flex row spaced">
				<span>{this.props.filename}</span>
				<button className="success">Watch!</button>
			</div>
		)
	}
}
