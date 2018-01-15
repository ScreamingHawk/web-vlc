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

		const apiData = await (await fetch('/config/api/omdb')).json()
		for (let i in shows){
			const details = await (await fetch(`${apiData.url}?apikey=${apiData.key}&t=${shows[i].name}`)).json()
			if (details.Response == "True"){
				const newShows = this.state.shows.slice()
				let show = newShows[i]
				show.image = details.Poster
				show.plot = details.Plot
				show.imdbRating = details.imdbRating
				this.setState({shows: newShows})
			}
		}
	}
	render() {
		let showRenders = this.state.shows.map(function(show){
			//TODO Placeholder image
			let imgSrc = null
			if (show.image){
				imgSrc = show.image
			}
			return (
				<div className="box card center" key={show.name}>
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
					</div>
				</div>
			)
		});
		return (
			<div className="flex">
				{showRenders}
			</div>
		)
	}
}
