//
//  MoviesViewController.swift
//  BackstageCodeAssignment
//
//  Created by Paul McGrath on 2/16/26.
//

import UIKit
class MoviesViewController: UITableViewController {

    // MARK: - Properties

    private var movies: [Movie] = [] {
        didSet { applyFilter() }
    }
    private var filteredMovies: [Movie] = []
    private var errorMessage: String?

    private let searchController = UISearchController(searchResultsController: nil)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Movies"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MovieCell")
        setupSearch()
        loadMovies()
    }

    // MARK: - Search Setup

    private func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by title, genre, year or director"
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
            filteredMovies = movies
            tableView.reloadData()
            return
        }
        let query = searchQuery.lowercased()
        filteredMovies = movies.filter { movie in
            movie.matchesQuery(query: query)
        }
        tableView.reloadData()
    }

    // MARK: - Data Loading

    private func loadMovies() {
        Task {
            do {
                movies = try await APIManager.shared.getMovieList()
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
                showError(error.localizedDescription)
            }
        }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredMovies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
        let movie = filteredMovies[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = movie.title
        content.secondaryText = "\(movie.genre) · \(movie.year) · Dir. \(movie.director)"
        cell.contentConfiguration = content

        return cell
    }
}

// MARK: - UISearchResultsUpdating

extension MoviesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        applyFilter()
    }
}
