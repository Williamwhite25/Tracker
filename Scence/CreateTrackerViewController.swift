import UIKit

// MARK: - CreateTrackerDelegate
protocol CreateTrackerDelegate: AnyObject {
    func createTrackerDidCreate(_ tracker: Tracker)
}

// MARK: - CreateTrackerViewController
final class CreateTrackerViewController: UIViewController {
    weak var delegate: CreateTrackerDelegate?
    
    private var emojiCollectionHeightConstraint: NSLayoutConstraint?
    private var colorCollectionHeightConstraint: NSLayoutConstraint?
    
    private var selectedScheduleDays: [WeekDay] = []
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let nameField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.backgroundColor = UIColor(red: 0.902, green: 0.910, blue: 0.922, alpha: 0.3)
        tf.layer.cornerRadius = 16
        tf.layer.masksToBounds = true
        tf.placeholder = "Введите название трекера"
        tf.font = UIFont(name: "SFPro-Regular", size: 17)
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
        v.backgroundColor = UIColor(red: 0.902, green: 0.910, blue: 0.922, alpha: 0.3)
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
    
    private lazy var categoryButton: UIButton = {
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
        b.addTarget(self, action: #selector(categoryTapped), for: .touchUpInside)
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
    
    // MARK: Emoji selection
    private let emojiTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Emoji"
        lbl.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        lbl.textColor = .label
        return lbl
    }()
    
    private let columns: CGFloat = 6
    private let spacing: CGFloat = 5
    private let sideInset: CGFloat = 18
    
    private lazy var emojiCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        cv.showsVerticalScrollIndicator = false
        return cv
    }()
    
    
    
    private let emojis: [String] = [
        "😀","😃","😅","😍","😎","🤩","🤓","😴","🤔","😇","😬","😭","😡","👍","👎","👏","🎯","🌟"
    ]
    
    private var selectedEmojiIndex: Int? = nil
    
    // MARK: Color selection
    private let colorTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Цвет"
        lbl.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        lbl.textColor = .label
        return lbl
    }()
    
    private lazy var colorCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        cv.showsVerticalScrollIndicator = false
        return cv
    }()
    
    private let colorOptions: [UIColor] = Colors.allCases.map { $0.uiColor }
    private var selectedColorIndex: Int?
    
    // MARK: Buttons
    private lazy var stackButtons: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.isLayoutMarginsRelativeArrangement = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    private let cancelButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Отменить"
        config.baseForegroundColor = UIColor(named: "YPRed") ?? .systemRed
        config.contentInsets = NSDirectionalEdgeInsets(top: 19, leading: 32, bottom: 19, trailing: 32)
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
        
        setupSubviews()
        
        emojiCollection.reloadData()
        
        // selectedColorIndex set after view loads to map defaultColor
        selectedColorIndex = Colors.allCases.firstIndex(of: defaultColor)
        colorCollection.reloadData()
        
        
        title = "Новая привычка"
        
        // Настройка таргетов
        scheduleButton.addTarget(self, action: #selector(scheduleTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        
        nameField.addTarget(self, action: #selector(nameFieldChanged(_:)), for: .editingChanged)
        nameField.delegate = self
        
        setupConstraints()
        
        view.bringSubviewToFront(nameWarningLabel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: Layout
    private func setupSubviews() {
        
        view.addSubview(scrollView)
        
        // Добавление вьюшек
        scrollView.addSubview(nameField)
        scrollView.addSubview(nameWarningLabel)
        
        // Emoji
        scrollView.addSubview(emojiTitleLabel)
        scrollView.addSubview(emojiCollection)
        
        // Color
        scrollView.addSubview(colorTitleLabel)
        scrollView.addSubview(colorCollection)
        
        
        scrollView.addSubview(categoryScheduleContainer)
        categoryScheduleContainer.addSubview(categoryButton)
        categoryScheduleContainer.addSubview(separatorView)
        categoryScheduleContainer.addSubview(scheduleButton)
        scrollView.addSubview(scheduleSummaryLabel)
        
        scrollView.addSubview(stackButtons)
        
        [cancelButton,
         createButton
        ].forEach {
            stackButtons.addArrangedSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            // SCROLL VIEW: заполняет весь экран
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // NAME FIELD
            nameField.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameField.heightAnchor.constraint(equalToConstant: 75),
            
            // WARNING LABEL
            nameWarningLabel.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 8),
            nameWarningLabel.centerXAnchor.constraint(equalTo: nameField.centerXAnchor),
            nameWarningLabel.widthAnchor.constraint(equalTo: nameField.widthAnchor, multiplier: 1, constant: -24),
            
            // CATEGORY SCHEDULE CONTAINER
            categoryScheduleContainer.topAnchor.constraint(equalTo: nameWarningLabel.bottomAnchor, constant: 8),
            categoryScheduleContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryScheduleContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryScheduleContainer.heightAnchor.constraint(equalToConstant: 150),
            
            // CATEGORY BUTTON
            categoryButton.leadingAnchor.constraint(equalTo: categoryScheduleContainer.leadingAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: categoryScheduleContainer.trailingAnchor),
            categoryButton.topAnchor.constraint(equalTo: categoryScheduleContainer.topAnchor),
            categoryButton.bottomAnchor.constraint(equalTo: separatorView.topAnchor),
            
            // SEPARATOR
            separatorView.leadingAnchor.constraint(equalTo: categoryScheduleContainer.leadingAnchor, constant: 8),
            separatorView.trailingAnchor.constraint(equalTo: categoryScheduleContainer.trailingAnchor, constant: -8),
            separatorView.centerYAnchor.constraint(equalTo: categoryScheduleContainer.centerYAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            // SCHEDULE BUTTON
            scheduleButton.leadingAnchor.constraint(equalTo: categoryScheduleContainer.leadingAnchor),
            scheduleButton.trailingAnchor.constraint(equalTo: categoryScheduleContainer.trailingAnchor),
            scheduleButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            scheduleButton.bottomAnchor.constraint(equalTo: categoryScheduleContainer.bottomAnchor),
            
            // SCHEDULE SUMMARY LABEL
            scheduleSummaryLabel.leadingAnchor.constraint(equalTo: categoryScheduleContainer.leadingAnchor, constant: 16),
            scheduleSummaryLabel.trailingAnchor.constraint(equalTo: categoryScheduleContainer.trailingAnchor, constant: -16),
            scheduleSummaryLabel.topAnchor.constraint(equalTo: scheduleButton.bottomAnchor, constant: -20),
            scheduleSummaryLabel.bottomAnchor.constraint(lessThanOrEqualTo: categoryScheduleContainer.bottomAnchor, constant: -8),
            
            // EMOJI TITLE
            emojiTitleLabel.topAnchor.constraint(equalTo: categoryScheduleContainer.bottomAnchor, constant: 32),
            emojiTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            emojiTitleLabel.heightAnchor.constraint(equalToConstant: 18),
            
            // EMOJI COLLECTION
            emojiCollection.topAnchor.constraint(equalTo: emojiTitleLabel.bottomAnchor, constant: 24),
            emojiCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            emojiCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            // Высота будет обновляться в viewDidLayoutSubviews
            
            // COLOR TITLE
            colorTitleLabel.topAnchor.constraint(equalTo: emojiCollection.bottomAnchor, constant: 14),
            colorTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            colorTitleLabel.heightAnchor.constraint(equalToConstant: 18),
            
            // COLOR COLLECTION
            colorCollection.topAnchor.constraint(equalTo: colorTitleLabel.bottomAnchor, constant: 34),
            colorCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            colorCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            // Высота будет обновляться в viewDidLayoutSubviews
            
            stackButtons.topAnchor.constraint(equalTo: colorCollection.bottomAnchor, constant: 16),
            stackButtons.heightAnchor.constraint(equalToConstant: 60),
            stackButtons.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -34),
            stackButtons.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackButtons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Убедимся, что констрейнты высоты коллекций активны
        emojiCollectionHeightConstraint = emojiCollection.heightAnchor.constraint(equalToConstant: 174)
        emojiCollectionHeightConstraint?.isActive = true
        
        colorCollectionHeightConstraint = colorCollection.heightAnchor.constraint(equalToConstant: 204)
        colorCollectionHeightConstraint?.isActive = true
    }
    
    // MARK: Actions
    @objc private func categoryTapped() {
        // TODO: реализовать выбор категории
    }
    
    @objc private func scheduleTapped() {
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
        
        let chosenEmoji = (selectedEmojiIndex != nil) ? emojis[selectedEmojiIndex!] : "⭐"
        let tracker = Tracker(
            id: UUID(),
            name: name,
            categoryId: defaultCategoryUuid,
            schedule: selectedScheduleDays.isEmpty ? nil : selectedScheduleDays,
            emoji: chosenEmoji,
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
        let current = textField.text ?? ""
        guard let stringRange = Range(range, in: current) else { return false }
        let updated = current.replacingCharacters(in: stringRange, with: string)
        
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

// MARK: - Emoji & Color Collections
extension CreateTrackerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollection { return emojis.count }
        return colorOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollection {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.identifier, for: indexPath) as? EmojiCell else {
                return UICollectionViewCell()
            }
            let isSelected = indexPath.item == selectedEmojiIndex
            cell.configure(with: emojis[indexPath.item], selected: isSelected)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier, for: indexPath) as? ColorCell else {
                return UICollectionViewCell()
            }
            let isSelected = indexPath.item == selectedColorIndex
            cell.configure(with: colorOptions[indexPath.item], selected: isSelected)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollection {
            let previous = selectedEmojiIndex
            selectedEmojiIndex = indexPath.item
            var reload: [IndexPath] = [indexPath]
            if let p = previous, p != indexPath.item { reload.append(IndexPath(item: p, section: 0)) }
            collectionView.reloadItems(at: reload)
            return
        }
        
        // color collection selected
        let previous = selectedColorIndex
        selectedColorIndex = indexPath.item
        var reload: [IndexPath] = [indexPath]
        if let p = previous, p != indexPath.item { reload.append(IndexPath(item: p, section: 0)) }
        collectionView.reloadItems(at: reload)
        
        // сохранить выбранный цвет в defaultColor (по индексу)
        if indexPath.item < Colors.allCases.count {
            defaultColor = Colors.allCases[indexPath.item]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let totalSpacing = spacing * (columns - 1) + sideInset * 2
        let available = collectionView.bounds.width - totalSpacing
        let side = floor(available / columns) // квадрат
        
        return CGSize(width: side, height: side)
    }
}


















