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
                showAlert(title: "Error", message: error.localizedDescription)
            }
            tableView.reloadData()
        }
    }
    
    // MARK: - Empty State View
    
    private func updateEmptyState() {
        if viewModel.hasNoResults {
            let label = UILabel()
            label.text = "No results found"
            label.textColor = .secondaryLabel
            label.font = .preferredFont(forTextStyle: .body)
            label.textAlignment = .center
            tableView.backgroundView = label
        } else {
            tableView.backgroundView = nil
        }
    }
    
    // MARK: - Item Selection
    func updateSelectionConfirmationButton() {
        if viewModel.selectionType == .Multiple && !viewModel.selectedIndexPaths.isEmpty {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target:self, action:#selector(selectionConfirmed))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    @objc
    func selectionConfirmed() {
        let message = "\(viewModel.selectedIndexPaths.count) item(s) selected"
        showAlert(title:"Item selected", message:message)
    }
    
    // MARK: - Display Alert
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.selectionType == .Single {
            guard let item = viewModel.itemForIndexPath(indexPath) else { return }
            showAlert(title:"Item selected", message:item.getName())
        } else if viewModel.selectionType == .Multiple {
            viewModel.toggleSelection(at: indexPath)
            tableView.reloadRows(at: [indexPath], with: .none)
            updateSelectionConfirmationButton()
        }
    }
}

// MARK: - UISearchResultsUpdating

extension SearchableTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchQuery = searchController.searchBar.text ?? ""
        updateEmptyState()
        updateSelectionConfirmationButton()
        tableView.reloadData()
    }
}
