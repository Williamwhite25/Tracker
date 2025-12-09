




import Foundation
import UIKit


// MARK: - ColorCell
final class ColorCell: UICollectionViewCell {
    static let identifier = "ColorCell"

    private let colorView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 8        
        v.layer.masksToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(colorView)
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        // Оставляем слой ячейки без скругления, чтобы например можно было добавить тень
        layer.masksToBounds = false
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with color: UIColor, selected: Bool) {
        colorView.backgroundColor = color
        colorView.layer.borderWidth = selected ? 1 : 0
        colorView.layer.borderColor = selected ? UIColor.label.withAlphaComponent(0.9).cgColor : nil
    }
}
