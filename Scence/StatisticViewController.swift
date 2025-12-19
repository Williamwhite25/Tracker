//
//  StatisticViewController.swift
//  Tracker
//
//  Created by William White on 04.11.2025.
//

import Foundation
import UIKit


// MARK: - StatisticViewController
class StatisticViewController: UIViewController {
    // MARK: Tab bar item
    override var tabBarItem: UITabBarItem! {
        get {
            UITabBarItem(
                title: "Статистика",
                image: UIImage(systemName: "hare.fill"),
                tag: 0
            )
        }
        set { super.tabBarItem = newValue }
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Установка фонового цвета для экрана статистики
        view.backgroundColor = .systemBackground
    }
}
