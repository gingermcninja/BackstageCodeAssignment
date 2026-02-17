//
//  RestaurantTableViewModel.swift
//  BackstageCodeAssignment
//
//  Created by Paul McGrath on 2/16/26.
//

import UIKit

class RestaurantTableViewModel : SearchableTableViewModel {
    override init() {
        super.init()
        self.title = "Restaurants"
        self.searchPlaceholder = "Search by cuisine, name, city, price or rating"
        self.selectionType = .Multiple
    }
    
    // MARK: - Data Loading

    override func getItems() async throws {
        do {
            let cuisineItems = try await APIManager.shared.getCuisineList()
            items = cuisineItems
        } catch {
            throw error
        }
    }
    
    override func itemForIndexPath(_ indexPath: IndexPath) -> Searchable? {
        guard let cuisine = filteredItems[indexPath.section] as? Cuisine else { return nil }
        return (cuisine.filteredRestaurants ?? cuisine.restaurants)[indexPath.row]
    }
}
