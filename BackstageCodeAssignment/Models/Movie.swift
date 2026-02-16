//
//  Movie.swift
//  BackstageCodingAssignment
//
//  Created by Paul McGrath on 2/16/26.
//

import Foundation

struct Movie: Codable, Searchable {
    var id: Int
    var title: String
    var genre: String
    var director: String
    var year: Int
    
    func matchesQuery(query: String) -> Bool {
        return (title.lowercased().contains(query) ||
            genre.lowercased().contains(query) ||
            director.lowercased().contains(query) ||
            "\(year)".contains(query)
        )
    }
}
