import React, { Component } from 'react'
import Show from './Show.jsx'

export default class ShowList extends Component {
	constructor(props){
		super(props)
		this.state = {
			shows: [],
			filteredShows: [],
			search: ""
		}

		this.filterShows = this.filterShows.bind(this)
	}
	componentDidMount(){
		this.getShowList()
	}
	async getShowList(){
		const shows = await (await fetch('/shows')).json()
		this.setState({
			shows: shows,
			filteredShows: shows,
			search: ""
		})
	}
	filterShows(event){
		let search = event.target.value
		let shows = this.state.shows
		let filteredShows = shows.filter(show => show.name.toLowerCase().indexOf(search.toLowerCase()) > -1)

		this.setState({
			shows: shows,
			filteredShows: filteredShows,
			search: search
		})
	}
	render() {
		const setVideo = this.props.setVideo
		let showRenders = this.state.filteredShows.map(function(show){
			return (
				<Show {...show} key={show.name} setVideo={setVideo} />
			)
		});
		return (
			<div>
				<div className="flex">
					<input placeholder="Search..." value={this.state.search} onChange={this.filterShows}></input>
				</div>
				<div className="flex wrap justify">
					{showRenders}
				</div>
			</div>
		)
	}
}
