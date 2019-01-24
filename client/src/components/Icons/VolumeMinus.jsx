import React, { Component } from 'react'

export default class VolumeMinus extends Component {

	render(){
		return (
			<svg xmlns="http://www.w3.org/2000/svg" width="50" height="50" viewBox="0 0 100 100">
				<rect
					x="10"
					y="47.5"
					width="10"
					height="5"
					fill="#1a1e49"
					stroke="#1a1e49"
					strokeLinejoin="round"
					strokeWidth="12"
					/>
				<polygon
					points="15,50 50,30 50,70"
					fill="#1a1e49"
					stroke="#1a1e49"
					strokeLinejoin="round"
					strokeWidth="12"
					/>
				<rect
					x="65"
					y="47.5"
					width="30"
					height="1"
					fill="#1a1e49"
					stroke="#1a1e49"
					strokeLinejoin="round"
					strokeWidth="8"
				/>
			</svg>
		)
	}
}
