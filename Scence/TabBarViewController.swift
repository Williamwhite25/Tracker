
//  Created by William White on 03.11.2025.
//


import Foundation
import UIKit

// MARK: - TrackerTabsController
class TrackerTabsController: UITabBarController {
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        createNavigation([
            TrackerViewController(),
            StatisticViewController()
        ])

        configureNavigationBar()
    }

    // MARK: - Setup navigation controllers and tabs
    private func createNavigation(_ navigationControllers: [UIViewController]) {
        var tabs: [UINavigationController] = []

        navigationControllers.forEach { navigation in
            let navigationController = UINavigationController(rootViewController: navigation)
            
            if navigation.tabBarItem.title != nil && navigation.tabBarItem.image != nil {
                navigationController.tabBarItem = navigation.tabBarItem
                tabs.append(navigationController)
            }
        }

        viewControllers = tabs
    }

    // MARK: - Configure appearance of tab bar and navigation
    private func configureNavigationBar() {
        // Фоновый цвет экрана
        view.backgroundColor = UIColor(named: "YPWhite")
        // Цвет для выбранного таба
        tabBar.tintColor = UIColor(named: "YPBlue")
        // Цвет для невыбранных табов
        tabBar.unselectedItemTintColor = UIColor(named: "YPGray")

        // Шрифт заголовков табов
        UITabBarItem.appearance().setTitleTextAttributes(
            [.font: UIFont.systemFont(ofSize: 12)],
            for: .normal
        )

        // Добавить тонкую линию над TabBar
        addTopSeparator()
    }

    private func addTopSeparator() {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        // Можно использовать системный separator цвет или кастомный
        separator.backgroundColor = UIColor.separator.withAlphaComponent(0.6)

        tabBar.addSubview(separator)
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            separator.topAnchor.constraint(equalTo: tabBar.topAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}




//import Foundation
//import UIKit
//
//// MARK: - TrackerTabsController
//class TrackerTabsController: UITabBarController {
//    // MARK: Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        createNavigation([
//            TrackerViewController(),
//            StatisticViewController()
//        ])
//
//        configureNavigationBar()
//    }
//
//    // MARK: - Setup navigation controllers and tabs
//    private func createNavigation(_ navigationControllers: [UIViewController]) {
//        var tabs: [UINavigationController] = []
//
//        navigationControllers.forEach { navigation in
//            let navigationController = UINavigationController(rootViewController: navigation)
//            
//            if navigation.tabBarItem.title != nil && navigation.tabBarItem.image != nil {
//                navigationController.tabBarItem = navigation.tabBarItem
//                tabs.append(navigationController)
//            }
//        }
//
//        viewControllers = tabs
//    }
//
//    // MARK: - Configure appearance of tab bar and navigation
//    private func configureNavigationBar() {
//        // Фоновый цвет экрана
//        view.backgroundColor = UIColor(named: "YPWhite")
//        // Цвет для выбранного таба
//        tabBar.tintColor = UIColor(named: "YPBlue")
//        // Цвет для невыбранных табов
//        tabBar.unselectedItemTintColor = UIColor(named: "YPGray")
//
//        // Шрифт заголовков табов
//        UITabBarItem.appearance().setTitleTextAttributes(
//            [.font: UIFont.systemFont(ofSize: 12)],
//            for: .normal
//        )
//    }
//}
