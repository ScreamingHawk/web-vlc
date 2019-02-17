import React, { Component } from 'react'

export default class ShowDetails extends Component {
	constructor(props){
		super(props)

		this.unshortenPlot = this.unshortenPlot.bind(this)
		this.toggleUpdateApiSource = this.toggleUpdateApiSource.bind(this)
		this.updateNewSource = this.updateNewSource.bind(this)
		this.updateApiSource = this.updateApiSource.bind(this)

		this.state = {
			shortenPlot: true,
			shortenPlotTo: 120,
			showUpdateApiSource: false,
			newSource: "",
		}
	}
	unshortenPlot(e){
		e.preventDefault();
		e.stopPropagation();
		this.setState({
			shortenPlot: false
		})
	}
	toggleUpdateApiSource(e){
		if (e){
			e.preventDefault();
			e.stopPropagation();
		}
		this.setState({
			showUpdateApiSource: !this.state.showUpdateApiSource,
		})
	}
	updateNewSource(e){
		this.setState({
			newSource: e.target.value,
		})
	}
	async updateApiSource(){
		if (!this.state.newSource){
			// Ignore updating, close edit
			this.toggleUpdateApiSource();
			return false;
		}
		await fetch(`/shows/${this.props.show.name}`, {
				method: "PUT",
				headers: {
					"Content-Type": "application/json"
				},
				body: JSON.stringify({
					source: this.state.newSource
				})
			})
			.then(this.handleApiErrors)
			.then(() => {
				// Blank and close the edit box
				this.updateNewSource({
					target: {
						value: ""
					}
				});
				this.toggleUpdateApiSource();
				// Refresh the show list
				this.props.getShowList();
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
		let sourceP = null;
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
			const apiContent = [];
			let key = "";
			if (show.genres){
				apiContent.push(
					<span key={show.name+"genre"}><b>Genres:</b> {show.genres}</span>
				);
			}
			if (show.score){
				apiContent.push(
					<span key={show.name+"score"}><b>{ratingLabel}:</b> {show.score}</span>
				);
			}
			apiContent.push(
				<span key={show.name+"rating"}><b>Rated:</b> {show.rating != null ? show.rating : "No Rating"}</span>
			);
			apiP = (
				<p className="blockspans">
					{
						apiContent.map(e => e)
					}
				</p>
			)
			// Source
			if (show.source){
				if (this.state.showUpdateApiSource){
					sourceP = (
						<p className="flex spaced blockspans">
							<input className="grow tiny-margin-right" placeholder={show.source} value={this.state.newSource} onChange={this.updateNewSource}></input>
							<button className="success" onClick={this.updateApiSource}>Update</button>
						</p>
					);
				} else {
					let pencil = null;
					if (show.api == "mal" && this.props.config &&
							this.props.config.editApiSource){
						pencil = (
							<button className="icon" onClick={this.toggleUpdateApiSource}>🖉</button>
						);
					}
					sourceP = (
						<p className="blockspans">
							<span>
								<a href={show.source}>{sourceLabel}</a>
								&nbsp;
								{pencil}
							</span>
						</p>
					);
				}
			}
		}
		return (
			<div>
				{plotP}
				{apiP}
				{sourceP}
			</div>
		)
	}
}
