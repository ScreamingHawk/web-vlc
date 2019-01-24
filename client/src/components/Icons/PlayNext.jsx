import React, { Component } from 'react'

export default class PlayNext extends Component {

	render(){
		return (
			<svg xmlns="http://www.w3.org/2000/svg" width="50" height="50" viewBox="0 0 100 100">
				<polygon
					points="10,35 10,65 35,50"
					fill="#1a1e49"
					stroke="#1a1e49"
					strokeLinejoin="round"
					strokeWidth="14"
					/>
				<polygon
					points="45,35 45,65 70,50"
					fill="#1a1e49"
					stroke="#1a1e49"
					strokeLinejoin="round"
					strokeWidth="14"
					/>
				<rect
					x="80"
					y="30"
					width="5"
					height="40"
					fill="#1a1e49"
					stroke="#1a1e49"
					strokeLinejoin="round"
					strokeWidth="14"
				/>
			</svg>
		)
	}
}
