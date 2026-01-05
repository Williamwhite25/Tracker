import UIKit

final class StatisticCell: UICollectionViewCell {
    static let identifier = "StatisticCell"
    
    // MARK: - UI Elements
    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.clear.cgColor
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(resource: .ypBlack)
        label.textAlignment = .left
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .ypBlack)
        label.textAlignment = .left
        return label
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(resource: .ypRed).cgColor,
            UIColor(resource: .ypGreen).cgColor,
            UIColor(resource: .ypBlue).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = 16
        return gradient
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cardView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
    }
    
    // MARK: - Configuration
    func configure(with statisticItem: StatisticItem) {
        valueLabel.text = "\(statisticItem.value)"
        titleLabel.text = statisticItem.title
        
        addGradientBorder()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        contentView.addSubview(cardView)
        cardView.addSubview(valueLabel)
        cardView.addSubview(titleLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            valueLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -12)
        ])
    }
    
    private func addGradientBorder() {
        let gradientMask = CAShapeLayer()
        gradientMask.lineWidth = 2
        gradientMask.path = UIBezierPath(roundedRect: bounds, cornerRadius: 16).cgPath
        gradientMask.strokeColor = UIColor.black.cgColor
        gradientMask.fillColor = UIColor.clear.cgColor
        gradientLayer.mask = gradientMask
        
        cardView.layer.addSublayer(gradientLayer)
    }
}
