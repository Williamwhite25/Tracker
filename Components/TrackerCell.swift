
//  Created by William White on 19.11.2025.
//


import Foundation
import UIKit


// MARK: - TrackerCellDelegate
protocol TrackerCellDelegate: AnyObject {
    func trackerCellDidTapPlus(_ cell: TrackerCell)
}

// MARK: - TrackerCell
final class TrackerCell: UICollectionViewCell {
    static let identifier = "trackerCell"
    weak var delegate: TrackerCellDelegate?

    private let card = UIView()
    private let nameView = UILabel()
    private let emojiView = UILabel()

    private let completionRowView = UIView()
    private let completedLabel = UILabel()
    private let completedButtonView = UIButton()

    private var tracker: Tracker?

    override init(frame: CGRect) {
        super.init(frame: frame)
        completionRowView.addSubview(completedLabel)
        completionRowView.addSubview(completedButtonView)

        card.addSubview(emojiView)
        card.addSubview(nameView)

        contentView.addSubview(card)
        contentView.addSubview(completionRowView)

        setupAppearance()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupAppearance() {
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.masksToBounds = true
        card.layer.cornerRadius = 16

        nameView.translatesAutoresizingMaskIntoConstraints = false
        nameView.font = .systemFont(ofSize: 14)
        nameView.textColor = .white
        nameView.numberOfLines = 0

        emojiView.translatesAutoresizingMaskIntoConstraints = false
        emojiView.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        emojiView.layer.masksToBounds = true
        emojiView.layer.cornerRadius = 15
        emojiView.textAlignment = .center
        emojiView.font = .systemFont(ofSize: 16)
        emojiView.textColor = .white
        emojiView.clipsToBounds = true

        completionRowView.translatesAutoresizingMaskIntoConstraints = false

        completedButtonView.translatesAutoresizingMaskIntoConstraints = false
        completedButtonView.layer.masksToBounds = true
        completedButtonView.layer.cornerRadius = 17
        completedButtonView.setImage(UIImage(systemName: "plus"), for: .normal)
        completedButtonView.tintColor = UIColor(named: "YPWhite")
        completedButtonView.addTarget(self, action: #selector(trackerCompletedButtonTapped(_:)), for: .touchUpInside)

        completedLabel.translatesAutoresizingMaskIntoConstraints = false
        completedLabel.font = .systemFont(ofSize: 14)
        completedLabel.textColor = .label
    }

    func setCompletedButton(isCompleted: Bool) {
        let imageName = isCompleted ? "checkmark" : "plus"
        completedButtonView.setImage(UIImage(systemName: imageName), for: .normal)
    }

    func setupForTracking(tracker: Tracker, currentDate: Date) {
        self.tracker = tracker
        nameView.text = tracker.name
        emojiView.text = tracker.emoji

        let uiColor = tracker.color.uiColor
        card.backgroundColor = uiColor
        completedButtonView.backgroundColor = uiColor

        updateCountLabel()
        setCompletedButton(isCompleted: tracker.isCompleted(on: currentDate))
    }

    @objc private func trackerCompletedButtonTapped(_ sender: UIButton) {
        delegate?.trackerCellDidTapPlus(self)
        UISelectionFeedbackGenerator().selectionChanged()
    }

    func updateCountLabel() {
        let count = tracker?.completedDates.count ?? 0
        completedLabel.text = count.toStringChoice("день", "дня", "дней")
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: contentView.topAnchor),
            card.heightAnchor.constraint(equalToConstant: 100),

            emojiView.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            emojiView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            emojiView.widthAnchor.constraint(equalToConstant: 30),
            emojiView.heightAnchor.constraint(equalToConstant: 30),

            nameView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            nameView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            nameView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            completionRowView.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 8),
            completionRowView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            completionRowView.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            completionRowView.trailingAnchor.constraint(equalTo: card.trailingAnchor),

            completedLabel.leadingAnchor.constraint(equalTo: completionRowView.leadingAnchor, constant: 12),
            completedLabel.trailingAnchor.constraint(equalTo: completedButtonView.leadingAnchor, constant: -12),
            completedLabel.topAnchor.constraint(equalTo: completionRowView.topAnchor),
            completedLabel.bottomAnchor.constraint(equalTo: completionRowView.bottomAnchor, constant: -8),

            completedButtonView.trailingAnchor.constraint(equalTo: completionRowView.trailingAnchor, constant: -12),
            completedButtonView.widthAnchor.constraint(equalToConstant: 34),
            completedButtonView.heightAnchor.constraint(equalToConstant: 34),
            completedButtonView.centerYAnchor.constraint(equalTo: completionRowView.centerYAnchor)
        ])
    }
}







//import Foundation
//import UIKit
//
//// MARK: - TrackerCellDelegate
//protocol TrackerCellDelegate: AnyObject {
//    func trackerCellDidTapPlus(_ cell: TrackerCell)
//}
//
//// MARK: - TrackerCell
//final class TrackerCell: UICollectionViewCell {
//    // MARK: Constants
//    static let identifier = "trackerCell"
//    weak var delegate: TrackerCellDelegate?
//    
//    // MARK: Subviews
//    private let card = UIView()
//    private let nameView = UILabel()
//    private let emojiView = UILabel()
//    
//    private let completionRowView = UIView()
//    private let completedLabel = UILabel()
//    private let completedButtonView = UIButton()
//    
//    // MARK: State
//    private var tracker: Tracker?
//    
//    // MARK: Init
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        completionRowView.addSubview(completedLabel)
//        completionRowView.addSubview(completedButtonView)
//        
//        card.addSubview(emojiView)
//        card.addSubview(nameView)
//        
//        contentView.addSubview(card)
//        contentView.addSubview(completionRowView)
//        
//        setupAppearance()
//        configureConstraints()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//    }
//    
//    // MARK: Appearance
//    private func setupAppearance() {
//        // card configure
//        card.translatesAutoresizingMaskIntoConstraints = false
//        card.layer.masksToBounds = true
//        card.layer.cornerRadius = 16
//        
//        // name label configure
//        nameView.translatesAutoresizingMaskIntoConstraints = false
//        nameView.font = .systemFont(ofSize: 14)
//        nameView.textColor = .white
//        nameView.numberOfLines = 0
//        
//        // emoji label configure
//        emojiView.translatesAutoresizingMaskIntoConstraints = false
//        emojiView.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
//        emojiView.layer.masksToBounds = true
//        emojiView.layer.cornerRadius = 15
//        emojiView.textAlignment = .center
//        emojiView.font = .systemFont(ofSize: 16)
//        emojiView.textColor = .white
//        emojiView.clipsToBounds = true
//        
//        // completions row configure
//        completionRowView.translatesAutoresizingMaskIntoConstraints = false
//        
//        // completion button configure
//        completedButtonView.translatesAutoresizingMaskIntoConstraints = false
//        completedButtonView.layer.masksToBounds = true
//        completedButtonView.layer.cornerRadius = 17
//        completedButtonView.setImage(UIImage(systemName: "plus"), for: .normal)
//        completedButtonView.tintColor = UIColor(named: "YPWhite")
//        completedButtonView.addTarget(self, action: #selector(trackerCompletedButtonTapped(_:)), for: .touchUpInside)
//        
//        completedLabel.translatesAutoresizingMaskIntoConstraints = false
//        completedLabel.font = .systemFont(ofSize: 14)
//        completedLabel.textColor = .label
//    }
//    
//    // MARK: Configuration
//    func setCompletedButton(isCompleted: Bool) {
//        let imageName = isCompleted ? "checkmark" : "plus"
//        completedButtonView.setImage(UIImage(systemName: imageName), for: .normal)
//    }
//    
//    func setupForTracking(tracker: Tracker, currentDate: Date) {
//        self.tracker = tracker
//        nameView.text = tracker.name
//        emojiView.text = tracker.emoji
//        
//      
//        let uiColor = tracker.color.uiColor
//        card.backgroundColor = uiColor
//        completedButtonView.backgroundColor = uiColor
//        
//        updateCountLabel()
//        setCompletedButton(isCompleted: tracker.isCompleted(on: currentDate))
//    }
//    
//    // MARK: Actions
//    @objc private func trackerCompletedButtonTapped(_ sender: UIButton) {
//        delegate?.trackerCellDidTapPlus(self)
//        UISelectionFeedbackGenerator().selectionChanged()
//    }
//    
//    // MARK: Helpers
//    func updateCountLabel() {
//        let count = tracker?.completedDates.count ?? 0
//        completedLabel.text = count.toStringChoice("день", "дня", "дней")
//    }
//    
//    // MARK: Layout
//    private func configureConstraints() {
//        NSLayoutConstraint.activate([
//            
//            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            card.topAnchor.constraint(equalTo: contentView.topAnchor),
//            card.heightAnchor.constraint(equalToConstant: 100),
//            
//           
//            emojiView.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
//            emojiView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
//            emojiView.widthAnchor.constraint(equalToConstant: 30),
//            emojiView.heightAnchor.constraint(equalToConstant: 30),
//            
//            
//            nameView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
//            nameView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
//            nameView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
//            
//            
//            completionRowView.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 8),
//            completionRowView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//            completionRowView.leadingAnchor.constraint(equalTo: card.leadingAnchor),
//            completionRowView.trailingAnchor.constraint(equalTo: card.trailingAnchor),
//            
//         
//            completedLabel.leadingAnchor.constraint(equalTo: completionRowView.leadingAnchor, constant: 12),
//            completedLabel.trailingAnchor.constraint(equalTo: completedButtonView.leadingAnchor, constant: -12),
//            completedLabel.topAnchor.constraint(equalTo: completionRowView.topAnchor),
//            completedLabel.bottomAnchor.constraint(equalTo: completionRowView.bottomAnchor, constant: -8),
//            
//            
//            completedButtonView.trailingAnchor.constraint(equalTo: completionRowView.trailingAnchor, constant: -12),
//            completedButtonView.widthAnchor.constraint(equalToConstant: 34),
//            completedButtonView.heightAnchor.constraint(equalToConstant: 34),
//            completedButtonView.centerYAnchor.constraint(equalTo: completionRowView.centerYAnchor)
//        ])
//    }
//}
//












