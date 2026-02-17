//
//  MoviesViewController.swift
//  BackstageCodeAssignment
//
//  Created by Paul McGrath on 2/16/26.
//

import UIKit
class MoviesViewController: SearchableTableViewController {

    // MARK: - Lifecycle

    init() {
        super.init(style: .plain, title: "Movies", searchText: "Search by title, genre, year or director")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Data Loading

    override func loadItems() {
        Task {
            do {
                items = try await APIManager.shared.getMovieList()
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
                showError(error.localizedDescription)
            }
            tableView.reloadData()
        }
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchableCell", for: indexPath)
        guard let movie = filteredItems[indexPath.row] as? Movie else { return cell }

        var content = cell.defaultContentConfiguration()
        content.text = movie.title
        content.secondaryText = "\(movie.genre) · \(movie.year) · Dir. \(movie.director)"
        cell.contentConfiguration = content

        return cell
    }
}
