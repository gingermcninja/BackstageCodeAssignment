//
//  MoviesViewController.swift
//  BackstageCodeAssignment
//
//  Created by Paul McGrath on 2/16/26.
//

import UIKit

class MoviesViewController: UITableViewController {

    private var movies: [Movie] = []
    private var errorMessage: String?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Movies"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MovieCell")
        loadMovies()
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
            tableView.reloadData()
        }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
        let movie = movies[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = movie.title
        content.secondaryText = "\(movie.genre) · \(movie.year) · Dir. \(movie.director)"
        cell.contentConfiguration = content

        return cell
    }
}
