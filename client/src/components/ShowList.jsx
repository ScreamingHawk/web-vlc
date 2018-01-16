import React, { Component } from 'react';

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
			//TODO Placeholder image
			let imgSrc = null
			if (show.image){
				imgSrc = show.image
			}
			return (
				<div className="box card inverted" key={show.name}>
					<img src={imgSrc}></img>
					<div className="content">
						<h3>{show.name}</h3>
						<p>{show.plot}</p>
						<p>
							<b>IMDB Rating:</b> {show.imdbRating}
						</p>
						<p>
							<b>Seasons on disk:</b> {show.seasons.length > 0 ? show.seasons.join(", ") : "None"}
							<br/>
							<b>Episodes on disk:</b> {show.count}
						</p>
						<button className="primary large">Watch me!</button>
					</div>
				</div>
			)
		});
		return (
			<div className="flex wrap center">
				{showRenders}
			</div>
		)
	}
}
