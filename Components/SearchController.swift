
//  Created by William White on 10.11.2025.
//


import Foundation
import UIKit

// MARK: - Default initialize

final class SearchController: NSObject {
    public let controller: UISearchController = UISearchController()
    private let presenter: UIViewController

    init(presenter: UIViewController) {
        self.presenter = presenter

        super.init()
        controller.delegate = presenter as? UISearchControllerDelegate
        controller.searchBar.delegate = presenter as? UISearchBarDelegate

        controller.hidesNavigationBarDuringPresentation = false
        controller.searchBar.placeholder = "Поиск"
    }

    func register() {
        presenter.navigationItem.searchController = controller
    }
}
