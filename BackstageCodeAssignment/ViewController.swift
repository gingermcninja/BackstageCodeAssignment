//
//  ViewController.swift
//  BackstageCodeAssignment
//
//  Created by Paul McGrath on 2/16/26.
//
import UIKit

class ViewController: UIViewController {
    var errorMessage: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Task {
            do {
                var movies = try await APIManager.shared.getMovieList()
                var cuisines = try await APIManager.shared.getCuisineList()
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
            }
    }

    }


}
