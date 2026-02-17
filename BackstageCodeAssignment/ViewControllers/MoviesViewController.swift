//
//  MoviesViewController.swift
//  BackstageCodeAssignment
//
//  Created by Paul McGrath on 2/16/26.
//

import UIKit
class MoviesViewController: SearchableTableViewController {

    // MARK: - Configuration

    override func configureViewModel() {
        viewModel = MovieTableViewModel()
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.filteredItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchableCell", for: indexPath)
        guard let movie = viewModel.filteredItems[indexPath.row] as? Movie else { return cell }

        var content = cell.defaultContentConfiguration()
        content.text = movie.title
        content.secondaryText = "\(movie.genre) · \(movie.year) · Dir. \(movie.director)"
        cell.contentConfiguration = content

        return cell
    }
}
