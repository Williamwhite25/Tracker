

import UIKit

// MARK: - CreateTrackerDelegate
protocol CreateTrackerDelegate: AnyObject {
    func createTrackerDidCreate(_ tracker: Tracker)
}

// MARK: - CreateTrackerViewController
final class CreateTrackerViewController: UIViewController {
    // MARK: Properties
    weak var delegate: CreateTrackerDelegate?
    
    private var selectedScheduleDays: [WeekDay] = []
    
    private let nameField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.8)
        tf.layer.cornerRadius = 16
        tf.layer.masksToBounds = true
        tf.placeholder = "Введите название трекера"
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = .label
        tf.clearButtonMode = .whileEditing
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let nameWarningLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Ограничение 38 символов"
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.textColor = .systemRed
        lbl.textAlignment = .center
        lbl.isHidden = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let categoryScheduleContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.8)
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let separatorView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemGray3
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let categoryButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Категория"
        config.baseForegroundColor = .label
        config.titleAlignment = .leading
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        
        
        let chevron = UIImage(named: "Chevron")?.withRenderingMode(.alwaysOriginal)
        config.image = chevron
        config.imagePlacement = .trailing
        config.imagePadding = 8
        
        let b = UIButton(type: .system)
        b.configuration = config
        b.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        b.backgroundColor = .clear
        b.contentHorizontalAlignment = .fill
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let scheduleButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Расписание"
        config.baseForegroundColor = .label
        config.titleAlignment = .leading
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        
        let chevron = UIImage(named: "Chevron")?.withRenderingMode(.alwaysOriginal)
        config.image = chevron
        config.imagePlacement = .trailing
        config.imagePadding = 8
        
        let b = UIButton(type: .system)
        b.configuration = config
        b.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        b.backgroundColor = .clear
        b.contentHorizontalAlignment = .fill
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    
    private let scheduleSummaryLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.textColor = .secondaryLabel
        lbl.textAlignment = .left
        lbl.numberOfLines = 1
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.isHidden = true
        return lbl
    }()
    
    // MARK: Buttons
    
    private let cancelButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Отменить"
        config.baseForegroundColor = UIColor(named: "YPRed") ?? .systemRed
        config.contentInsets = NSDirectionalEdgeInsets(top: 19, leading: 32, bottom: 19, trailing: 32)
        
        var bg = UIButton.Configuration.plain().background
        config.background = .clear()
        let b = UIButton(type: .system)
        b.configuration = config
        b.layer.cornerRadius = 16
        b.layer.borderWidth = 1
        b.layer.borderColor = (UIColor(named: "YPRed") ?? .systemRed).cgColor
        b.backgroundColor = .white
        b.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let createButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Создать"
        config.baseForegroundColor = .white
        config.baseBackgroundColor = UIColor(named: "YPGray") ?? UIColor.systemGray
        config.contentInsets = NSDirectionalEdgeInsets(top: 19, leading: 32, bottom: 19, trailing: 32)
        config.cornerStyle = .medium
        let b = UIButton(type: .system)
        b.configuration = config
        b.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    // MARK: Defaults
    var defaultCategoryUuid: UUID = UUID()
    var defaultColor: Colors = .pinkEnergy
    private let maxNameLength = 38
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Добавление вьюшек
        view.addSubview(nameField)
        view.addSubview(nameWarningLabel)
        
        view.addSubview(categoryScheduleContainer)
        categoryScheduleContainer.addSubview(categoryButton)
        categoryScheduleContainer.addSubview(separatorView)
        categoryScheduleContainer.addSubview(scheduleButton)
        view.addSubview(scheduleSummaryLabel)
        
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        
        title = "Новая привычка"
        
        // Настройка таргетов
        categoryButton.addTarget(self, action: #selector(categoryTapped), for: .touchUpInside)
        scheduleButton.addTarget(self, action: #selector(scheduleTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        
        nameField.addTarget(self, action: #selector(nameFieldChanged(_:)), for: .editingChanged)
        nameField.delegate = self
        
        setupConstraints()
        
      
        view.bringSubviewToFront(nameWarningLabel)
    }
    
    // MARK: Layout
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameField.heightAnchor.constraint(equalToConstant: 75),
            
            nameWarningLabel.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 8),
            nameWarningLabel.centerXAnchor.constraint(equalTo: nameField.centerXAnchor),
            nameWarningLabel.widthAnchor.constraint(equalTo: nameField.widthAnchor, multiplier: 1, constant: -24),
            
            
            categoryScheduleContainer.topAnchor.constraint(equalTo: nameWarningLabel.bottomAnchor, constant: 8),
            categoryScheduleContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryScheduleContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryScheduleContainer.heightAnchor.constraint(equalToConstant: 150),
            
            
            categoryButton.leadingAnchor.constraint(equalTo: categoryScheduleContainer.leadingAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: categoryScheduleContainer.trailingAnchor),
            categoryButton.topAnchor.constraint(equalTo: categoryScheduleContainer.topAnchor),
            categoryButton.bottomAnchor.constraint(equalTo: separatorView.topAnchor),
            
            
            separatorView.leadingAnchor.constraint(equalTo: categoryScheduleContainer.leadingAnchor, constant: 8),
            separatorView.trailingAnchor.constraint(equalTo: categoryScheduleContainer.trailingAnchor, constant: -8),
            separatorView.centerYAnchor.constraint(equalTo: categoryScheduleContainer.centerYAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
           
            scheduleButton.leadingAnchor.constraint(equalTo: categoryScheduleContainer.leadingAnchor),
            scheduleButton.trailingAnchor.constraint(equalTo: categoryScheduleContainer.trailingAnchor),
            scheduleButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            scheduleButton.bottomAnchor.constraint(equalTo: categoryScheduleContainer.bottomAnchor),
            
            
            scheduleSummaryLabel.leadingAnchor.constraint(equalTo: categoryScheduleContainer.leadingAnchor, constant: 16),
            scheduleSummaryLabel.trailingAnchor.constraint(equalTo: categoryScheduleContainer.trailingAnchor, constant: -16),
            scheduleSummaryLabel.topAnchor.constraint(equalTo: scheduleButton.bottomAnchor, constant: -20),
            scheduleSummaryLabel.bottomAnchor.constraint(lessThanOrEqualTo: categoryScheduleContainer.bottomAnchor, constant: -8),
            
            
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -34),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalToConstant: 161),
            
            cancelButton.centerYAnchor.constraint(equalTo: createButton.centerYAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8)
        ])
    }
    
    // MARK: Actions
    @objc private func categoryTapped() {
        // TODO: реализовать выбор категории
    }
    
    @objc private func scheduleTapped() {
        // Показ контроллера расписания и получение выбранных дней через делегат
        let vc = ScheduleViewController(initialSelectedDays: selectedScheduleDays)
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .automatic
        present(nav, animated: true)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createTapped() {
        guard let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            return
        }
        
        let tracker = Tracker(
            id: UUID(),
            name: name,
            categoryId: defaultCategoryUuid,
            schedule: selectedScheduleDays.isEmpty ? nil : selectedScheduleDays,
            emoji: "⭐",
            color: defaultColor,
            completedDates: Set<Date>()
        )
        
        delegate?.createTrackerDidCreate(tracker)
        dismiss(animated: true)
    }
    
    @objc private func nameFieldChanged(_ textField: UITextField) {
        let text = textField.text ?? ""
        nameWarningLabel.isHidden = text.count <= maxNameLength
    }
}

// MARK: - ScheduleViewControllerDelegate
extension CreateTrackerViewController: ScheduleViewControllerDelegate {
    func scheduleViewController(_ vc: ScheduleViewController, didSelectDays selectedDays: [WeekDay]) {
        selectedScheduleDays = selectedDays
        
        if selectedDays.isEmpty {
            scheduleSummaryLabel.isHidden = true
            scheduleSummaryLabel.text = nil
        } else {
            scheduleSummaryLabel.isHidden = false
            scheduleSummaryLabel.text = selectedDays.map { $0.shortName }.joined(separator: ", ")
        }
    }
}

// MARK: - UITextFieldDelegate (validation)
extension CreateTrackerViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Получаем будущий текст после изменения
        let current = textField.text ?? ""
        guard let stringRange = Range(range, in: current) else { return false }
        let updated = current.replacingCharacters(in: stringRange, with: string)
        
        // Запрещаем ввод при превышении лимита
        if updated.count > maxNameLength {
            nameWarningLabel.isHidden = false
            return false
        }
        
        nameWarningLabel.isHidden = updated.count <= maxNameLength
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        nameWarningLabel.isHidden = true
        return true
    }
}















