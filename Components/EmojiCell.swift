


import UIKit

final class EmojiCell: UICollectionViewCell {
    static let identifier = "EmojiCell"

    private let emojiLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 40)
        l.textAlignment = .center
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(emojiLabel)
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true

        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            emojiLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { super.init(coder: coder) }

    func configure(with emoji: String, selected: Bool) {
        emojiLabel.text = emoji
        contentView.backgroundColor = selected ? UIColor.systemGray4 : .clear
    }
}
