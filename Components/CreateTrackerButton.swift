
//  Created by William White on 10.11.2025.
//


import Foundation
import UIKit

// MARK: - CreateTrackerButton
final class CreateTrackerButton: UIBarButtonItem {
    private let presenter: UIViewController
    
    
    override var style: Style {
        get { .plain }
        set {}
    }
    
   
    override var image: UIImage? {
        get {
            let config = UIImage.SymbolConfiguration(weight: .semibold)
            let tint = UIColor(named: "YPBlack") ?? .black
            return UIImage(systemName: "plus", withConfiguration: config)?
                .withTintColor(tint, renderingMode: .alwaysOriginal)
        }
        set { super.image = newValue }
    }
    
    // MARK: Init
    init(presenter: UIViewController) {
        self.presenter = presenter
        super.init()
        target = self
        action = #selector(tapAction)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func registerAsLeftButton() {
        presenter.navigationItem.leftBarButtonItem = self
    }
    
    // MARK: - Action
    @objc private func tapAction() {
        let createVC = CreateTrackerViewController()
        if let delegate = presenter as? CreateTrackerDelegate {
            createVC.delegate = delegate
        }
        let nav = UINavigationController(rootViewController: createVC)
        nav.modalPresentationStyle = .automatic
        presenter.present(nav, animated: true)
    }
}
