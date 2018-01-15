import React, { Component } from 'react';

export default class ShowList extends Component {
	constructor(props){
		super(props);
		this.state = {shows: []}
	}
	componentDidMount(){
		this.getShowList();
	}
	getShowList(){
		$.getJSON('/shows').then(({results}) => this.setState({shows: results}));
	}
	render() {
		let out = this.state.shows
		return <h1>{out}</h1>;
	}
}
