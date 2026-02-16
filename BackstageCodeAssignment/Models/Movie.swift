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
    
    func matchesQuery(_ object: Searchable, query: String) -> Bool {
        guard let movie = object as? Movie else { return false }
        return (movie.title.lowercased().contains(query) ||
            movie.genre.lowercased().contains(query) ||
            movie.director.lowercased().contains(query) ||
            "\(movie.year)".contains(query)
        )
    }
}
