import React, { Component } from 'react'

export default class NoImage extends Component {

	render(){
		return (
			<svg xmlns="http://www.w3.org/2000/svg" width="300" height="450">
				<rect
					x="0"
					y="0"
					width="300"
					height="450"
					fill="#d0d0d0"
				/>
				<rect
					x="50"
					y="125"
					width="200"
					height="200"
					stroke="#7d7d7d"
					strokeLinejoin="round"
					strokeWidth="30"
					fill="none"
				/>
				<path
					d="
						M 200 125
						L 125 235
						L 175 215
						L 100 325"
					fill="none"
					stroke="#7d7d7d"
					strokeWidth="14"
				/>
			</svg>
		)
	}
}
