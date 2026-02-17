//
//  MovieTableViewModel.swift
//  BackstageCodeAssignment
//
//  Created by Paul McGrath on 2/16/26.
//

class MovieTableViewModel : SearchableTableViewModel {
    override init() {
        super.init()
        self.title = "Movies"
        self.searchPlaceholder = "Search by title, genre, year or director"
        self.selectionType = .Single
    }
    
    // MARK: - Data Loading
    
    override func getItems() async throws {
        do {
            let movieItems = try await APIManager.shared.getMovieList()
            items = movieItems
        } catch {
            throw error
        }
    }
}
