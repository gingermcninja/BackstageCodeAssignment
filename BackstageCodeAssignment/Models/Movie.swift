//
//  Movie.swift
//  BackstageCodingAssignment
//
//  Created by Paul McGrath on 2/16/26.
//

import Foundation

struct Movie: Codable {
    var id: Int
    var title: String
    var genre: String
    var director: String
    var year: Int
}
