//
//  Restaurant.swift
//  BackstageCodingAssignment
//
//  Created by Paul McGrath on 2/16/26.
//

import Foundation

struct Restaurant: Codable, Searchable {
    var id: Int
    var name: String
    var city: String
    var priceLevel: String
    var rating: Double
    
    func filtering(by query: String) -> Searchable? {
        if name.lowercased().contains(query) || city.lowercased().contains(query) || priceLevel.lowercased().contains(query) || String(rating).lowercased().contains(query) {
            return self
        } else {
            return nil
        }
    }
}

struct Cuisine: Codable, Searchable {
    var name: String
    var restaurants: [Restaurant]
    var filteredRestaurants: [Restaurant]?

    /// Returns a copy of this cuisine with `filteredRestaurants` populated,
    /// or `nil` if neither the cuisine name nor any restaurant matches the query.
    func filtering(by query: String) -> Searchable? {
        let cuisineNameMatches = name.lowercased().contains(query)
        var matchingRestaurants: [Restaurant] = []
        if cuisineNameMatches {
            matchingRestaurants = restaurants
        } else {
            if let filteredRestaurants = restaurants.compactMap( {$0.filtering(by: query)} ) as? [Restaurant], !filteredRestaurants.isEmpty {
                matchingRestaurants = filteredRestaurants
            }
        }

        guard cuisineNameMatches || !matchingRestaurants.isEmpty else { return nil }

        var filtered = self
        filtered.filteredRestaurants = matchingRestaurants
        return filtered
    }
}

nonisolated struct CuisineResponse: Codable {
    var cuisines: [Cuisine]
}
