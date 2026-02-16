//
//  RestaurantsViewController.swift
//  BackstageCodeAssignment
//
//  Created by Paul McGrath on 2/16/26.
//

import UIKit

class RestaurantsViewController: UITableViewController {

    private var cuisines: [Cuisine] = []
    private var errorMessage: String?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Restaurants"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RestaurantCell")
        loadRestaurants()
    }

    // MARK: - Data Loading

    private func loadRestaurants() {
        Task {
            do {
                cuisines = try await APIManager.shared.getCuisineList()
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
                showError(error.localizedDescription)
            }
            tableView.reloadData()
        }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        cuisines.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        cuisines[section].name
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cuisines[section].restaurants.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell", for: indexPath)
        let restaurant = cuisines[indexPath.section].restaurants[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = restaurant.name
        content.secondaryText = "\(restaurant.city) · \(restaurant.priceLevel) · ⭐️ \(restaurant.rating)"
        cell.contentConfiguration = content

        return cell
    }
}
