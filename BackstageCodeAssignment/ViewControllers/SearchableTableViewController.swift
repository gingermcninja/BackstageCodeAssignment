//
//  SearchableViewController.swift
//  BackstageCodeAssignment
//
//  Created by Paul McGrath on 2/16/26.
//

import UIKit

class SearchableTableViewController: UITableViewController {

    // MARK: - View Model

    var viewModel = SearchableTableViewModel()

    // MARK: - Configuration

    let searchController = UISearchController(searchResultsController: nil)
    
    func configureViewModel() {
        viewModel = SearchableTableViewModel()
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewModel()
        title = viewModel.title
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SearchableCell")
        setupSearch()
        loadItems()
    }

    // MARK: - Search Setup

    func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = viewModel.searchPlaceholder
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    // MARK: - Data Loading

    /// Override in subclasses to populate `viewModel.items`.
    func loadItems() {
        Task {
            do {
                try await viewModel.getItems()
            } catch {
                showError(error.localizedDescription)
            }
            tableView.reloadData()
        }
    }

    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.filteredItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchableCell", for: indexPath)
        return cell
    }
}

// MARK: - UISearchResultsUpdating

extension SearchableTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchQuery = searchController.searchBar.text ?? ""
        tableView.reloadData()
    }
}
