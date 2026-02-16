//
//  APIManager.swift
//  BackstageCodingAssignment
//
//  Created by Paul McGrath on 2/16/26.
//

import Foundation

extension JSONDecoder {
    static var swapi: JSONDecoder {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .iso8601
        return d
    }
}

enum BackstageAPIError: Error {
    case badResponse
}

actor APIManager {
    static let shared = APIManager()
    private let base = URL(string: "https://slackbot.backstage.com/ios-test/")!

    func getMovieList(from movieURL: URL? = nil) async throws -> [Movie] {
        let url = movieURL ?? base.appendingPathComponent("movies")
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw BackstageAPIError.badResponse }
        return try await JSONDecoder.swapi.decode([Movie].self, from: data)
    }
    
    func getCuisineList(from restaurantURL: URL? = nil) async throws -> [Cuisine] {
        let url = restaurantURL ?? base.appendingPathComponent("restaurants")
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw BackstageAPIError.badResponse }
        let cuisineResponse = try await JSONDecoder.swapi.decode(CuisineResponse.self, from: data)
        return cuisineResponse.cuisines
    }
}
