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
    
    func matchesQuery(_ object: any Searchable, query: String) -> Bool {
        guard let resaurant = object as? Restaurant else { return false }
        return resaurant.name.contains(query) || resaurant.city.contains(query) || resaurant.priceLevel.contains(query) || String(resaurant.rating).contains(query)
    }
}

struct Cuisine: Codable, Searchable {
    var name: String
    var restaurants: [Restaurant]
    
    func matchesQuery(_ object: any Searchable, query: String) -> Bool {
        guard let cuisine = object as? Cuisine else { return false }
        return cuisine.name.contains(query)
    }
}

nonisolated struct CuisineResponse: Codable {
    var cuisines: [Cuisine]
}
