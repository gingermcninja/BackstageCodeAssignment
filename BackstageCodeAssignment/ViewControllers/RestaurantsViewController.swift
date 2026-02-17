//
//  RestaurantsViewController.swift
//  BackstageCodeAssignment
//
//  Created by Paul McGrath on 2/16/26.
//

import UIKit

class RestaurantsViewController: SearchableTableViewController {

    // MARK: - Configuration
    
    override func configureViewModel() {
        viewModel = RestaurantTableViewModel()
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.filteredItems.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let cuisine = viewModel.filteredItems[section] as? Cuisine else { return nil }
        return cuisine.name
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let cuisine = viewModel.filteredItems[section] as? Cuisine else { return 0 }
        return (cuisine.filteredRestaurants ?? cuisine.restaurants).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchableCell", for: indexPath)
        guard let cuisine = viewModel.filteredItems[indexPath.section] as? Cuisine else { return cell }
        let restaurant = (cuisine.filteredRestaurants ?? cuisine.restaurants)[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = restaurant.name
        content.secondaryText = "\(restaurant.city) · \(restaurant.priceLevel) · ⭐️ \(restaurant.rating)"
        cell.contentConfiguration = content

        return cell
    }
}
