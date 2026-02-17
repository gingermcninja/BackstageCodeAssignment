//
//  RestaurantsViewController.swift
//  BackstageCodeAssignment
//
//  Created by Paul McGrath on 2/16/26.
//

import UIKit

class RestaurantsViewController: SearchableTableViewController {

    // MARK: - Lifecycle

    init() {
        super.init(style: .plain, title: "Restaurants", searchText: "Search by cuisine, name, city, price or rating")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Data Loading

    override func loadItems() {
        Task {
            do {
                items = try await APIManager.shared.getCuisineList()
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
                showError(error.localizedDescription)
            }
            tableView.reloadData()
        }
    }


    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        filteredItems.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let cuisine = filteredItems[section] as? Cuisine else { return nil }
        return cuisine.name
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let cuisine = filteredItems[section] as? Cuisine else { return 0 }
        return (cuisine.filteredRestaurants ?? cuisine.restaurants).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchableCell", for: indexPath)
        guard let cuisine = filteredItems[indexPath.section] as? Cuisine else { return cell }
        let restaurant = (cuisine.filteredRestaurants ?? cuisine.restaurants)[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = restaurant.name
        content.secondaryText = "\(restaurant.city) · \(restaurant.priceLevel) · ⭐️ \(restaurant.rating)"
        cell.contentConfiguration = content

        return cell
    }
}
