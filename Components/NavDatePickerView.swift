
//  Created by William White on 09.11.2025.
//


import Foundation
import UIKit

// MARK: - Default initialize

final class DatePickerController: NSObject {
    public let picker = UIDatePicker()
    private let presenter: UIViewController

    init(presenter: UIViewController) {
        self.presenter = presenter
        super.init()
    }

    func register() -> Self {
        presenter.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: picker)

        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact

        NSLayoutConstraint.activate([
            picker.widthAnchor.constraint(equalToConstant: 100)
        ])

        addStyle(view: picker)

        return self
    }

    private func addStyle(view: UIView) {
        for view in view.subviews {
            if let label = view as? UILabel {
                label.font = UIFont.systemFont(ofSize: 17)
                break
            } else {
                addStyle(view: view)
            }
        }
    }
}



