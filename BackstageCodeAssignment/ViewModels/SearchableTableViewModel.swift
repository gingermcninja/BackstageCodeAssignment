//
//  SearchableTableViewModel.swift
//  BackstageCodeAssignment
//
//  Created by Paul McGrath on 2/16/26.
//

import Foundation
import UIKit

@MainActor
class SearchableTableViewModel {

    // MARK: - Public State
    
    enum SelectionType {
        case Single
        case Multiple
        case None
    }

    var items: [any Searchable] = [] {
        didSet { applyFilter() }
    }

    var filteredItems: [any Searchable] = []

    var searchQuery: String = "" {
        didSet { applyFilter() }
    }

    var title: String = "Table"
    var searchPlaceholder: String = "Search..."
    var selectionType: SelectionType = .Single

    // MARK: - Multi-Select State

    var selectedIndexPaths: Set<IndexPath> = []

    func toggleSelection(at indexPath: IndexPath) {
        if selectedIndexPaths.contains(indexPath) {
            selectedIndexPaths.remove(indexPath)
        } else {
            selectedIndexPaths.insert(indexPath)
        }
    }
    
    func itemForIndexPath(_ indexPath: IndexPath) -> Searchable? {
        guard indexPath.row < filteredItems.count else { return nil }
        return filteredItems[indexPath.row]
    }

    // MARK: - Filtering

    var hasNoResults: Bool {
        let isFiltering = !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty
        return isFiltering && filteredItems.isEmpty
    }

    func applyFilter() {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            filteredItems = items
            return
        }
        let query = trimmed.lowercased()
        filteredItems = items.compactMap { $0.filtering(by: query) }
        // Clear any selections that are now out of bounds after filtering
        selectedIndexPaths = selectedIndexPaths.filter { $0.row < filteredItems.count }
    }

    // MARK: - Data Loading

    func getItems() async throws {
        items = []
    }

    init() {
        self.title = "Table"
        self.searchPlaceholder = "Search..."
    }
}
