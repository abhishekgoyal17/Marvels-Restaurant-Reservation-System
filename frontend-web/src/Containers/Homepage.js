import React, { Component } from 'react';

import SearchForm from './SearchForm/SearchForm';
import RestaurantDisplayBulletin from '../Components/Bulletins/RestaurantDisplayBulletin';

import url from '../Config/url';
import { Link } from 'react-router-dom';
import '../Components/Cards/RestaurantCard.css';
import '../App.css'

import Food from '../Images/Food.png';

const defaultVisibleItems = 6;

class Homepage extends Component {
	constructor() {
		super();
		this.state = {
			displayResults: false,
			loading: false,
			restaurants: [],
			filteredResults: [],
			visible: defaultVisibleItems
		}
	}

	loadMore = () => {
		this.setState({
			visible: (this.state.visible) + 3,
		})
	}

	displayResults = (filters) => {
		this.setState({ loading: true })
		fetch(`${url.fetchURL}/search`, {
			method: 'post',
			headers: { 'Content-type': 'application/json' },
			body: JSON.stringify(filters)
		})
			.then(resp => resp.json())
			.then(data => {
				this.setState({
					loading: false,
					displayResults: true,
					filteredResults: data,
					visible: defaultVisibleItems
				})
			});
	}

	render() {
		return (
			<div className="pl7 pr7 pt7">
			 <Link to="/" className="link food no-underline flex items-center pl3">
                    <img src={Food} id='food' alt='logo' />
                </Link>
				<SearchForm triggerDisplay={this.displayResults} />
				{this.state.displayResults &&
					<RestaurantDisplayBulletin
						loading={this.state.loading}
						resDisplay={this.state.filteredResults}
						visibleItemsNum={this.state.visible}
						totalLength={this.state.filteredResults.length}
						loadMore={this.loadMore}
					/>
				}
				
			</div>
			
		);
	}

}

export default Homepage;
