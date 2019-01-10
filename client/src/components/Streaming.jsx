import React, { Component } from 'react'

export default class Streaming extends Component {
	constructor(props){
		super(props)
	}
	render() {
		const { currentVideo } = this.props
		const src = `/stream/${currentVideo.path}`
		return (
			<div className="viewing flex column center">
				<video controls>
					<source src={src} />
				</video>
			</div>
		)
	}
}
