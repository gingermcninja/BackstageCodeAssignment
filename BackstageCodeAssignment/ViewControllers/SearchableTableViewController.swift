//
//  SearchableViewController.swift
//  BackstageCodeAssignment
//
//  Created by Paul McGrath on 2/16/26.
//

import UIKit

class SearchableTableViewController: UITableViewController {
    
    var items: [Searchable] = [] {
        didSet { applyFilter() }
    }
    var filteredItems: [Searchable] = []
    var errorMessage: String?
    var tableTitle: String = ""
    var searchText: String = "Search"
    
    let searchController = UISearchController(searchResultsController: nil)

    // MARK: - Lifecycle
    
    init(style: UITableView.Style, title: String, searchText: String) {
        super.init(style: style)
        self.tableTitle = title
        self.searchText = searchText
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = self.tableTitle
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SearchableCell")
        setupSearch()
        loadItems()
    }
    
    
    // MARK: - Search Setup

    func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        //searchController.searchBar.placeholder = "Search by cuisine, name, city, price or rating"
        searchController.searchBar.placeholder = searchText
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    // MARK: - Filtering

    var searchQuery: String {
        searchController.searchBar.text?.trimmingCharacters(in: .whitespaces) ?? ""
    }

    var isFiltering: Bool {
        searchController.isActive && !searchQuery.isEmpty
    }

    func applyFilter() {
        guard isFiltering else {
            filteredItems = items
            tableView.reloadData()
            return
        }
        let query = searchQuery.lowercased()
        filteredItems = items.compactMap( { $0.filtering(by: query) })
        tableView.reloadData()
    }

    // MARK: - Data Loading

    func loadItems() {
            items = []
            errorMessage = nil
            tableView.reloadData()
        
    }

    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchableCell", for: indexPath)
        //let item = filteredItems[indexPath.row]
        return cell
    }
}

// MARK: - UISearchResultsUpdating

extension SearchableTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        applyFilter()
    }
}
