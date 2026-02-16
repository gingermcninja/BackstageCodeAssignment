//
//  Restaurant.swift
//  BackstageCodingAssignment
//
//  Created by Paul McGrath on 2/16/26.
//

import Foundation

struct Restaurant: Codable {
    var id: Int
    var name: String
    var city: String
    var priceLevel: String
    var rating: Double
}

struct Cuisine: Codable {
    var name: String
    var restaurants: [Restaurant]
}

struct CuisineResponse: Codable {
    var cuisines: [Cuisine]
}
