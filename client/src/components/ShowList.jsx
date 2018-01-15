import React, { Component } from 'react';

export default class ShowList extends Component {
	constructor(props){
		super(props);
		this.state = {shows: []};
	}
	componentDidMount(){
		this.getShowList();
	}
	getShowList(){
		fetch('/shows')
			.then(results => {
				return results.json();
			}).then(data => {
				this.setState({shows: data});
			});
	}
	render() {
		let showRenders = this.state.shows.map(function(show){
			return (
				<div>
					<h3>{show.name}</h3>
					<p>Seasons: {show.seasons}</p>
					<p>Episodes: {show.count}</p>
				</div>
			)
		});
		return (
			<div>
				{showRenders}
			</div>
		)
	}
}
