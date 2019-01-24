import React, { Component } from 'react'

export default class Mature extends Component {

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
				<text
					id="matureRating"
					ref="matty"
					x="50%"
					y="50%"
					alignmentBaseline="central"
					dominantBaseline="central"
					textAnchor="middle"
					fontWeight="400"
					fontSize="130"
					fontFamily="sans-serif"
					letterSpacing="0"
					wordSpacing="0"
					fill="#7d7d7d"
					style="line-height: 1.25;">
					!
				</text>
				<circle
					cx="50%"
					cy="50%"
					r="120"
					fill="none"
					stroke="#7d7d7d"
					strokeWidth="25"
				/>
			</svg>
		)
	}
}
