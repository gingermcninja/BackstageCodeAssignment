//
//  RestaurantsViewController.swift
//  BackstageCodeAssignment
//
//  Created by Paul McGrath on 2/16/26.
//

import UIKit

class RestaurantsViewController: UITableViewController {

    private var cuisines: [Cuisine] = [] {
        didSet { applyFilter() }
    }
    private var filteredCuisines: [Cuisine] = []
    private var filteredRestaurants: [Restaurant] = []
    private var errorMessage: String?
    
    private let searchController = UISearchController(searchResultsController: nil)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Restaurants"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RestaurantCell")
        setupSearch()
        loadRestaurants()
    }
    
    // MARK: - Search Setup

    private func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by cuisine, name, city, price or rating"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    // MARK: - Filtering

    private var searchQuery: String {
        searchController.searchBar.text?.trimmingCharacters(in: .whitespaces) ?? ""
    }

    private var isFiltering: Bool {
        searchController.isActive && !searchQuery.isEmpty
    }

    private func applyFilter() {
        guard isFiltering else {
            filteredCuisines = cuisines
            tableView.reloadData()
            return
        }
        let query = searchQuery.lowercased()
        if let filterCuisines = cuisines.compactMap({ $0.filtering(by: query) }) as? [Cuisine] {
            filteredCuisines = filterCuisines
        }
        tableView.reloadData()
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
        filteredCuisines.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        filteredCuisines[section].name
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cuisine = filteredCuisines[section]
        return (cuisine.filteredRestaurants ?? cuisine.restaurants).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell", for: indexPath)
        let cuisine = filteredCuisines[indexPath.section]
        let restaurant = (cuisine.filteredRestaurants ?? cuisine.restaurants)[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = restaurant.name
        content.secondaryText = "\(restaurant.city) · \(restaurant.priceLevel) · ⭐️ \(restaurant.rating)"
        cell.contentConfiguration = content

        return cell
    }
}

// MARK: - UISearchResultsUpdating

extension RestaurantsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        applyFilter()
    }
}
