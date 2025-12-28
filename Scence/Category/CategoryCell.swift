import UIKit

final class CategoryCell: UITableViewCell {
    static let identifier = "CategoryCell"

    func configure(with category: TrackerCategory) {
        textLabel?.text = category.name
        accessoryType = .disclosureIndicator
    }
}
