
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
    // MARK: Constants
    static let identifier = "trackerCell"
    weak var delegate: TrackerCellDelegate?

    // MARK: Subviews
    private let card = UIView()
    private let nameView = UILabel()
    private let emojiView = UILabel()

    private let completionRowView = UIView()
    private let completedLabel = UILabel()
    private let completedButtonView = UIButton()

    // MARK: State
    private var tracker: Tracker?

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Добавляем дочерние вьюшки
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

    // MARK: Appearance
    private func setupAppearance() {
        // card configure
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.masksToBounds = true
        card.layer.cornerRadius = 16
        card.backgroundColor = UIColor(red: 51/255.0, green: 207/255.0, blue: 105/255.0, alpha: 1.0)

        // name label configure
        nameView.translatesAutoresizingMaskIntoConstraints = false
        nameView.font = .systemFont(ofSize: 14)
        nameView.textColor = .white
        nameView.numberOfLines = 0

        // emoji label configure
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        emojiView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        emojiView.layer.masksToBounds = true
        emojiView.layer.cornerRadius = 15
        emojiView.textAlignment = .center

        // completions row configure
        completionRowView.translatesAutoresizingMaskIntoConstraints = false

        // completion button configure
        completedButtonView.translatesAutoresizingMaskIntoConstraints = false
        completedButtonView.layer.masksToBounds = true
        completedButtonView.layer.cornerRadius = 17
        completedButtonView.backgroundColor = UIColor(red: 51/255.0, green: 207/255.0, blue: 105/255.0, alpha: 1.0)
        completedButtonView.setImage(UIImage(systemName: "plus"), for: .normal)
        completedButtonView.tintColor = UIColor(named: "YPWhite")
        completedButtonView.addTarget(self, action: #selector(trackerCompletedButtonTapped(_:)), for: .touchUpInside)

        completedLabel.translatesAutoresizingMaskIntoConstraints = false
        completedLabel.font = .systemFont(ofSize: 14)
        completedLabel.textColor = .label
    }

    // MARK: Configuration
    func setCompletedButton(isCompleted: Bool) {
        // Устанавливаем иконку в кнопке в зависимости от состояния
        let imageName = isCompleted ? "checkmark" : "plus"
        completedButtonView.setImage(UIImage(systemName: imageName), for: .normal)
    }

    func setupForTracking(tracker: Tracker, selectedDate: Date) {
        // Конфигурируем ячейку под переданный трекер
        self.tracker = tracker
        nameView.text = tracker.name
        emojiView.text = tracker.emoji
        updateCountLabel()
        setCompletedButton(isCompleted: tracker.isCompleted(on: selectedDate))
    }

    // MARK: Actions
    @objc private func trackerCompletedButtonTapped(_ sender: UIButton) {
        // Нотификация делегата о нажатии 
        delegate?.trackerCellDidTapPlus(self)
        UISelectionFeedbackGenerator().selectionChanged()
    }

    // MARK: Helpers
    func updateCountLabel() {
        completedLabel.text = (tracker?.completeAt.count ?? 0).toStringChoice("день", "дня", "дней")
    }

    // MARK: Layout
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            // card constraints
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            card.topAnchor.constraint(equalTo: contentView.topAnchor),
            card.heightAnchor.constraint(equalToConstant: 100),

            // emoji constraints
            emojiView.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            emojiView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            emojiView.widthAnchor.constraint(equalToConstant: 30),
            emojiView.heightAnchor.constraint(equalToConstant: 30),

            // name constraints
            nameView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            nameView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            nameView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            // completion row constraints
            completionRowView.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 8),
            completionRowView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            completionRowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            completionRowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            // completed label constraints
            completedLabel.leadingAnchor.constraint(equalTo: completionRowView.leadingAnchor, constant: 12),
            completedLabel.trailingAnchor.constraint(equalTo: completedButtonView.leadingAnchor, constant: -12),
            completedLabel.topAnchor.constraint(equalTo: completionRowView.topAnchor),
            completedLabel.bottomAnchor.constraint(equalTo: completionRowView.bottomAnchor, constant: -8),

            // completed button constraints
            completedButtonView.trailingAnchor.constraint(equalTo: completionRowView.trailingAnchor, constant: -12),
            completedButtonView.widthAnchor.constraint(equalToConstant: 34),
            completedButtonView.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
}



