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
        return name.contains(query) || city.contains(query) || priceLevel.contains(query) || String(rating).contains(query)
    }
}

struct Cuisine: Codable, Searchable {
    var name: String
    var restaurants: [Restaurant]
    
    func matchesQuery(query: String) -> Bool {
        return name.contains(query)
    }
}

nonisolated struct CuisineResponse: Codable {
    var cuisines: [Cuisine]
}
