//
//  SearchableTableViewModel.swift
//  BackstageCodeAssignment
//
//  Created by Paul McGrath on 2/16/26.
//

import Foundation

@MainActor
//@Observable
class SearchableTableViewModel {

    // MARK: - Public State

    var items: [any Searchable] = [] {
        didSet { applyFilter() }
    }

    var filteredItems: [any Searchable] = []
    var searchQuery: String = "" {
        didSet { applyFilter() }
    }
    
    var title: String = "Table"
    var searchPlaceholder: String = "Search..."
    
    init() {
        self.title = "Table"
        self.searchPlaceholder = "Search..."
    }

    // MARK: - Filtering

    func applyFilter() {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            filteredItems = items
            return
        }
        let query = trimmed.lowercased()
        filteredItems = items.compactMap { $0.filtering(by: query) }
    }
    
    // MARK: - Data Loading
    
    func getItems() async throws {
        items = []
    }
}
