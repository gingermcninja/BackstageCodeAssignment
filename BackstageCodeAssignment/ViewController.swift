//
//  ViewController.swift
//  BackstageCodeAssignment
//
//  Created by Paul McGrath on 2/16/26.
//
import UIKit

class ViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [makeMoviesTab(), makeRestaurantsTab()]
    }

    // MARK: - Tab Setup

    private func makeMoviesTab() -> UINavigationController {
        let moviesVC = MoviesViewController()
        let nav = UINavigationController(rootViewController: moviesVC)
        nav.tabBarItem = UITabBarItem(
            title: "Movies",
            image: UIImage(systemName: "film"),
            selectedImage: UIImage(systemName: "film.fill")
        )
        return nav
    }

    private func makeRestaurantsTab() -> UINavigationController {
        let restaurantsVC = RestaurantsViewController()
        let nav = UINavigationController(rootViewController: restaurantsVC)
        nav.tabBarItem = UITabBarItem(
            title: "Restaurants",
            image: UIImage(systemName: "fork.knife"),
            selectedImage: UIImage(systemName: "fork.knife")
        )
        return nav
    }
}
