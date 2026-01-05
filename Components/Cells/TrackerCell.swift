import UIKit

final class TrackerCell: UICollectionViewCell {
    static let identifier = "TrackerCell"
    
    // MARK: - UI Elements
    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.backgroundColor = .white.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .ypWhite)
        label.numberOfLines = 2
        return label
    }()
    
    private let quantityView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .ypBlack)
        return label
    }()
    
    private let completeButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.addTarget(nil, action: #selector(completeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    private var trackerId: UUID?
    private var isCompletedToday: Bool = false
    private var completionHandler: ((UUID, Bool) -> Void)?
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        
        if state.isHighlighted {
            contentView.alpha = 0.7
        } else {
            contentView.alpha = 1.0
        }
    }
    
    // MARK: - Configuration
    func configure(with tracker: Tracker, isCompletedToday: Bool, completionCount: Int, completionHandler: @escaping (UUID, Bool) -> Void) {
        self.trackerId = tracker.id
        self.isCompletedToday = isCompletedToday
        self.completionHandler = completionHandler
        cardView.backgroundColor = UIColor(named: tracker.color)
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        
        countLabel.text = "дней"
        updateButtonAppearance()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        contentView.addSubview(cardView)
        cardView.addSubview(emojiLabel)
        cardView.addSubview(titleLabel)
        
        contentView.addSubview(quantityView)
        quantityView.addSubview(countLabel)
        quantityView.addSubview(completeButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        quantityView.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            quantityView.topAnchor.constraint(equalTo: cardView.bottomAnchor),
            quantityView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            quantityView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            quantityView.heightAnchor.constraint(equalToConstant: 58),
            quantityView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            countLabel.leadingAnchor.constraint(equalTo: quantityView.leadingAnchor, constant: 12),
            countLabel.centerYAnchor.constraint(equalTo: quantityView.centerYAnchor),
            
            completeButton.trailingAnchor.constraint(equalTo: quantityView.trailingAnchor, constant: -12),
            completeButton.centerYAnchor.constraint(equalTo: quantityView.centerYAnchor),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    private func updateButtonAppearance() {
        if isCompletedToday {
            completeButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            completeButton.tintColor = UIColor(resource: .ypWhite)
            completeButton.backgroundColor = cardView.backgroundColor?.withAlphaComponent(0.3)
        } else {
            completeButton.setImage(UIImage(systemName: "plus"), for: .normal)
            completeButton.tintColor = UIColor(resource: .ypWhite)
            completeButton.backgroundColor = cardView.backgroundColor
        }
    }
    
    @objc private func completeButtonTapped() {
        guard let trackerId = trackerId else { return }
        completionHandler?(trackerId, !isCompletedToday)
    }
}
