
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
    }
}
