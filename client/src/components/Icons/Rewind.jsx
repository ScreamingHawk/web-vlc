import React, { Component } from 'react'

export default class Rewind extends Component {

	render(){
		return (
			<svg xmlns="http://www.w3.org/2000/svg" width="50" height="50" viewBox="0 0 100 100">
				<path d="
					M 15 50
					A 35 35 0 1 1 50 85"
					fill="none"
					stroke="#1a1e49"
					strokeLinejoin="round"
					strokeWidth="8"
					transform="rotate(15, 50, 50)"
					/>
				<polygon
					points="5,45 25,45 15,60"
					fill="#1a1e49"
					stroke="none"
					transform="rotate(15, 50, 50)"
					/>
				<text
					x="50%"
					y="50%"
					alignmentBaseline="central"
					dominantBaseline="central"
					textAnchor="middle"
					fontWeight="400"
					fontSize="25"
					fontFamily="sans-serif"
					letterSpacing="0"
					wordSpacing="0"
					fill="#1a1e49">
					-20s
				</text>
			</svg>
		)
	}
}
