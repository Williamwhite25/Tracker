import UIKit

final class ColorCell: UICollectionViewCell {
    static let identifier = "ColorCell"
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let selectionLayer: CALayer = {
        let layer = CALayer()
        layer.borderWidth = 3
        layer.cornerRadius = 11
        layer.isHidden = true
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.layer.addSublayer(selectionLayer)
        contentView.addSubview(colorView)
        colorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectionLayer.frame = contentView.bounds
    }
    
    func configure(with colorName: String, isSelected: Bool) {
        colorView.backgroundColor = UIColor(named: colorName)
        
        if isSelected {
            selectionLayer.isHidden = false
            selectionLayer.borderColor = UIColor(named: colorName)?.withAlphaComponent(0.3).cgColor
        } else {
            selectionLayer.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectionLayer.isHidden = true
        colorView.backgroundColor = nil
    }
}
