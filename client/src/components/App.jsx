import React, { Component } from 'react'
import ShowList from './ShowList.jsx'

export default class App extends Component {
	render() {
		return (
			<div>
				<h1>Video Viewer</h1>
				<ShowList />
			</div>
		)
	}
}
