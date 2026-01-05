import UIKit

final class ScheduleCell: UITableViewCell {
    
    // MARK: - UI Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.onTintColor = UIColor(resource: .ypBlue)
        switchControl.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    // MARK: - Properties
    var onSwitchChanged: ((Bool) -> Void)?
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(switchControl)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        contentView.heightAnchor.constraint(equalToConstant: 75).isActive = true
    }
    
    // MARK: - Configuration
    func configure(with title: String, isOn: Bool) {
        titleLabel.text = title
        switchControl.isOn = isOn
    }
    
    // MARK: - Actions
    @objc private func switchChanged(_ sender: UISwitch) {
        onSwitchChanged?(sender.isOn)
    }
}
