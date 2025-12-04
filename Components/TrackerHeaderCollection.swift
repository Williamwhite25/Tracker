
//  Created by William White on 19.11.2025.
//


import Foundation
import UIKit

// MARK: - TrackerHeaderCollection
final class TrackerHeaderCollection: UICollectionReusableView {
    // MARK: Subviews
    private var titleLabelView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: "YPBlack")
        label.font = .systemFont(ofSize: 19, weight: .bold)
        return label
    }()
    
    // MARK: Constants
    static let identifier = "header"
    
    // MARK: Init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabelView)
        
        NSLayoutConstraint.activate([
            titleLabelView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabelView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            titleLabelView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabelView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: Configuration
    // Установить заголовок секции
    func setTitle(title: String) {
        titleLabelView.text = title
    }
}
