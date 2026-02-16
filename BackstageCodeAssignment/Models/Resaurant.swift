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
    
    func matchesQuery(query: String) -> Bool {
        return name.lowercased().contains(query) || city.lowercased().contains(query) || priceLevel.lowercased().contains(query) || String(rating).lowercased().contains(query)
    }
}

struct Cuisine: Codable, Searchable {
    var name: String
    var restaurants: [Restaurant]
    var filteredRestaurants: [Restaurant]?
    
    func matchesQuery(query: String) -> Bool {
        let filteredRestaurants = restaurants.filter { restaurant in
            restaurant.matchesQuery(query: query)
        }
        return name.lowercased().contains(query) || !filteredRestaurants.isEmpty
    }
}

nonisolated struct CuisineResponse: Codable {
    var cuisines: [Cuisine]
}
