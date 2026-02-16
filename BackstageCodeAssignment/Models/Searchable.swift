//
//  Searchable.swift
//  BackstageCodeAssignment
//
//  Created by Paul McGrath on 2/16/26.
//

import Foundation

protocol Searchable {
    func filtering(by query: String) -> Searchable?
}
