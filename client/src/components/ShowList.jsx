import React, { Component } from 'react'
import Show from './Show.jsx'

export default class ShowList extends Component {
	constructor(props){
		super(props)

		this.filterShows = this.filterShows.bind(this)
		this.getShowList = this.getShowList.bind(this)

		this.state = {
			shows: [],
			filteredShows: [],
			search: ""
		}
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
		const sendProps = {
			getShowList: this.getShowList,
		}
		const props = this.props;
		let showRenders = this.state.filteredShows.map(function(show){
			return (
					<Show {...sendProps} {...props} show={show} key={show.name} />
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
				<div className="flex row end spaced-children">
					<a className="btn primary" href="/?refresh">Refresh List</a>
					<a className="btn danger" href="/quit">Quit</a>
				</div>
			</div>
		)
	}
}
