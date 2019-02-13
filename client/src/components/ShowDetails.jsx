import React, { Component } from 'react'

export default class ShowDetails extends Component {
	constructor(props){
		super(props)

		this.unshortenPlot = this.unshortenPlot.bind(this)

		this.state = {
			shortenPlot: true,
			shortenPlotTo: 120,
		}
	}
	unshortenPlot(e){
		e.preventDefault();
		e.stopPropagation();
		this.setState({
			shortenPlot: false
		})
	}
	render(){
		const { show } = this.props
		// Plot
		let plotP = null
		if (show.plot){
			plotP = (
				<p>{show.plot}</p>
			)
			if (this.props.ratingHidden){
				plotP = (
					<p><i>Plot hidden.</i></p>
				)
			} else if (show.plot.length > this.state.shortenPlotTo - 10 && this.state.shortenPlot){
				plotP = (
					<p>
						{show.plot.substring(0, this.state.shortenPlotTo)}...
						&nbsp;
						<a href="" onClick={this.unshortenPlot}>more</a>
					</p>
				)
			}
		}
		// Other api data
		let apiP = (
			<p>
				<i>Details not found.</i>
			</p>
		)
		if (show.api){
			let sourceLabel = "Source"
			let ratingLabel = "Score"
			if (show.api == "mal"){
				sourceLabel = "MyAnimeList Source"
				ratingLabel = "MAL Score"
			} else if (show.api == "omdb"){
				sourceLabel = "IMDB Source"
				ratingLabel = "IMDB Score"
			}
			apiP = (
				<p>
					{
						show.genres && [
							<span><b>Genres:</b> {show.genres}</span>,
							<br/>,
						]
					}
					{
						show.score && [
							<span><b>{ratingLabel}:</b> {show.score}</span>,
							<br/>,
						]
					}
					<b>Rated:</b> {show.rating != null ? show.rating : "No Rating"}
					{
						show.source && [
							<br/>,
							<span><a href={show.source}>{sourceLabel}</a></span>,
						]
					}
				</p>
			)
		}
		return (
			<div>
				{plotP}
				{apiP}
			</div>
		)
	}
}
