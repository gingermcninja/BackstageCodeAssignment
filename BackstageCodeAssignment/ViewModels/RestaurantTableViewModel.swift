//
//  RestaurantTableViewModel.swift
//  BackstageCodeAssignment
//
//  Created by Paul McGrath on 2/16/26.
//

class RestaurantTableViewModel : SearchableTableViewModel {
    override init() {
        super.init()
        self.title = "Restaurants"
        self.searchPlaceholder = "Search by cuisine, name, city, price or rating"
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
}
