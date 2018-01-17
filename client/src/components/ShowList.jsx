import React, { Component } from 'react'
import Show from './Show.jsx'

export default class ShowList extends Component {
	constructor(props){
		super(props)
		this.state = {shows: []}
	}
	componentDidMount(){
		this.getShowList()
	}
	async getShowList(){
		const shows = await (await fetch('/shows')).json()
		this.setState({shows: shows})
	}
	render() {
		let showRenders = this.state.shows.map(function(show){
			return (
				<Show {...show} key={show.name} />
			)
		});
		return (
			<div className="flex wrap justify">
				{showRenders}
			</div>
		)
	}
}
