




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

    // MARK: Emoji selection
    private let emojiTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Emoji"
        lbl.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        lbl.textColor = .label
        return lbl
    }()

    private lazy var emojiCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 6
        layout.minimumLineSpacing = 3
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
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
        lbl.font = UIFont.systemFont(ofSize: 19, weight: .bold) // SF Pro Bold
        lbl.textColor = .label
        return lbl
    }()

    private lazy var colorCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 6
        layout.minimumLineSpacing = 3
        layout.sectionInset = UIEdgeInsets(top: 4, left: 18, bottom: 4, right: 18)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        cv.showsVerticalScrollIndicator = false
        return cv
    }()

    private let colorOptions: [UIColor] = Colors.allCases.map { $0.uiColor }
    private var selectedColorIndex: Int?

    // MARK: Buttons
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

        // Добавление вьюшек
        view.addSubview(nameField)
        view.addSubview(nameWarningLabel)

        // Emoji
        view.addSubview(emojiTitleLabel)
        view.addSubview(emojiCollection)
        emojiCollection.dataSource = self
        emojiCollection.delegate = self
        emojiCollection.reloadData()

        // Color
        view.addSubview(colorTitleLabel)
        view.addSubview(colorCollection)
        colorCollection.dataSource = self
        colorCollection.delegate = self
        // selectedColorIndex set after view loads to map defaultColor
        selectedColorIndex = Colors.allCases.firstIndex(of: defaultColor)
        colorCollection.reloadData()

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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        
        if let layout = emojiCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            let columns: CGFloat = 6
            let itemHeight: CGFloat = 52
            let rows = ceil(CGFloat(emojis.count) / columns)
            let totalHeight = rows * itemHeight
                + max(0, rows - 1) * layout.minimumLineSpacing
                + layout.sectionInset.top + layout.sectionInset.bottom
            emojiCollectionHeightConstraint?.constant = totalHeight
        }

        // Color collection: учитываем contentInset
        if let layout = colorCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            let columns: CGFloat = 6
            let totalInteritemSpacing = layout.minimumInteritemSpacing * (columns - 1)
            let horizontalInsets = layout.sectionInset.left + layout.sectionInset.right
            let contentInsets = colorCollection.contentInset.left + colorCollection.contentInset.right
            let availableWidth = colorCollection.bounds.width - totalInteritemSpacing - horizontalInsets - contentInsets
            let calculatedSide = floor(availableWidth / columns)
            let itemSide = min(calculatedSide, 52)

            let rows: CGFloat = 3
            let totalHeight = rows * itemSide
                + max(0, rows - 1) * layout.minimumLineSpacing
                + layout.sectionInset.top + layout.sectionInset.bottom
            colorCollectionHeightConstraint?.constant = totalHeight
        }
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

            // Emoji title
            emojiTitleLabel.topAnchor.constraint(equalTo: categoryScheduleContainer.bottomAnchor, constant: 16),
            emojiTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            emojiTitleLabel.heightAnchor.constraint(equalToConstant: 18),

            emojiCollection.topAnchor.constraint(equalTo: emojiTitleLabel.bottomAnchor, constant: 4), // Было 8
            emojiCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            emojiCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),

            // Color title
            colorTitleLabel.topAnchor.constraint(equalTo: emojiCollection.bottomAnchor, constant: 4),
            colorTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            colorTitleLabel.heightAnchor.constraint(equalToConstant: 18),

            // Color collection
            colorCollection.topAnchor.constraint(equalTo: colorTitleLabel.bottomAnchor, constant: 4),
            colorCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            colorCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),

            // Buttons
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
        
        emojiCollectionHeightConstraint = emojiCollection.heightAnchor.constraint(equalToConstant: 124)
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
        if collectionView == emojiCollection {
            guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
                return CGSize(width: 40, height: 40)
            }
            let columns: CGFloat = 6
            let totalInteritemSpacing = layout.minimumInteritemSpacing * (columns - 1)
            let horizontalInsets = layout.sectionInset.left + layout.sectionInset.right
            let contentInsets = collectionView.contentInset.left + collectionView.contentInset.right
            let availableWidth = collectionView.bounds.width - totalInteritemSpacing - horizontalInsets - contentInsets
            let w = floor(availableWidth / columns)
            return CGSize(width: w, height: 40)
        } else {
            guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
                return CGSize(width: 52, height: 52)
            }
            let columns: CGFloat = 6
            let totalInteritemSpacing = layout.minimumInteritemSpacing * (columns - 1)
            let horizontalInsets = layout.sectionInset.left + layout.sectionInset.right
            let contentInsets = collectionView.contentInset.left + collectionView.contentInset.right
            let availableWidth = collectionView.bounds.width - totalInteritemSpacing - horizontalInsets - contentInsets
            let calculatedSide = floor(availableWidth / columns)

           
            let maxSide: CGFloat = 52
            let itemSide = min(calculatedSide, maxSide)
            return CGSize(width: itemSide, height: itemSide)
        }
    }
}



// на всякий случай 

//// MARK: - CreateTrackerDelegate
//protocol CreateTrackerDelegate: AnyObject {
//    func createTrackerDidCreate(_ tracker: Tracker)
//}
//
//// MARK: - CreateTrackerViewController
//final class CreateTrackerViewController: UIViewController {
//    // MARK: Properties
//    weak var delegate: CreateTrackerDelegate?
//
//    private var selectedScheduleDays: [WeekDay] = []
//
//    private let nameField: UITextField = {
//        let tf = UITextField()
//        tf.borderStyle = .none
//        tf.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.8)
//        tf.layer.cornerRadius = 16
//        tf.layer.masksToBounds = true
//        tf.placeholder = "Введите название трекера"
//        tf.font = UIFont.systemFont(ofSize: 16)
//        tf.textColor = .label
//        tf.clearButtonMode = .whileEditing
//
//        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
//        tf.leftView = paddingView
//        tf.leftViewMode = .always
//        tf.translatesAutoresizingMaskIntoConstraints = false
//        return tf
//    }()
//
//    private let nameWarningLabel: UILabel = {
//        let lbl = UILabel()
//        lbl.text = "Ограничение 38 символов"
//        lbl.font = UIFont.systemFont(ofSize: 13)
//        lbl.textColor = .systemRed
//        lbl.textAlignment = .center
//        lbl.isHidden = true
//        lbl.translatesAutoresizingMaskIntoConstraints = false
//        return lbl
//    }()
//
//    private let categoryScheduleContainer: UIView = {
//        let v = UIView()
//        v.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.8)
//        v.layer.cornerRadius = 16
//        v.layer.masksToBounds = true
//        v.translatesAutoresizingMaskIntoConstraints = false
//        return v
//    }()
//
//    private let separatorView: UIView = {
//        let v = UIView()
//        v.backgroundColor = UIColor.systemGray3
//        v.translatesAutoresizingMaskIntoConstraints = false
//        return v
//    }()
//
//    private let categoryButton: UIButton = {
//        var config = UIButton.Configuration.plain()
//        config.title = "Категория"
//        config.baseForegroundColor = .label
//        config.titleAlignment = .leading
//        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
//
//        let chevron = UIImage(named: "Chevron")?.withRenderingMode(.alwaysOriginal)
//        config.image = chevron
//        config.imagePlacement = .trailing
//        config.imagePadding = 8
//
//        let b = UIButton(type: .system)
//        b.configuration = config
//        b.titleLabel?.font = UIFont.systemFont(ofSize: 16)
//        b.backgroundColor = .clear
//        b.contentHorizontalAlignment = .fill
//        b.translatesAutoresizingMaskIntoConstraints = false
//        return b
//    }()
//
//    private let scheduleButton: UIButton = {
//        var config = UIButton.Configuration.plain()
//        config.title = "Расписание"
//        config.baseForegroundColor = .label
//        config.titleAlignment = .leading
//        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
//
//        let chevron = UIImage(named: "Chevron")?.withRenderingMode(.alwaysOriginal)
//        config.image = chevron
//        config.imagePlacement = .trailing
//        config.imagePadding = 8
//
//        let b = UIButton(type: .system)
//        b.configuration = config
//        b.titleLabel?.font = UIFont.systemFont(ofSize: 16)
//        b.backgroundColor = .clear
//        b.contentHorizontalAlignment = .fill
//        b.translatesAutoresizingMaskIntoConstraints = false
//        return b
//    }()
//
//    private let scheduleSummaryLabel: UILabel = {
//        let lbl = UILabel()
//        lbl.font = UIFont.systemFont(ofSize: 13)
//        lbl.textColor = .secondaryLabel
//        lbl.textAlignment = .left
//        lbl.numberOfLines = 1
//        lbl.translatesAutoresizingMaskIntoConstraints = false
//        lbl.isHidden = true
//        return lbl
//    }()
//
//    // MARK: Emoji selection
//    private let emojiTitleLabel: UILabel = {
//        let lbl = UILabel()
//        lbl.translatesAutoresizingMaskIntoConstraints = false
//        lbl.text = "Emoji"
//        lbl.font = UIFont.systemFont(ofSize: 19, weight: .bold)
//        lbl.textColor = .label
//        return lbl
//    }()
//
//    private lazy var emojiCollection: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        layout.minimumInteritemSpacing = 8
//        layout.minimumLineSpacing = 12
//        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        cv.translatesAutoresizingMaskIntoConstraints = false
//        cv.backgroundColor = .clear
//        cv.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
//        cv.showsVerticalScrollIndicator = false
//        return cv
//    }()
//
//    private let emojis: [String] = [
//        "😀","😃","😅","😍","😎","🤩","🤓","😴","🤔","😇","😬","😭","😡","👍","👎","👏","🎯","🌟"
//    ]
//
//    private var selectedEmojiIndex: Int? = nil
//
//    // MARK: Buttons
//    private let cancelButton: UIButton = {
//        var config = UIButton.Configuration.plain()
//        config.title = "Отменить"
//        config.baseForegroundColor = UIColor(named: "YPRed") ?? .systemRed
//        config.contentInsets = NSDirectionalEdgeInsets(top: 19, leading: 32, bottom: 19, trailing: 32)
//        config.background = .clear()
//        let b = UIButton(type: .system)
//        b.configuration = config
//        b.layer.cornerRadius = 16
//        b.layer.borderWidth = 1
//        b.layer.borderColor = (UIColor(named: "YPRed") ?? .systemRed).cgColor
//        b.backgroundColor = .white
//        b.titleLabel?.font = UIFont.systemFont(ofSize: 16)
//        b.translatesAutoresizingMaskIntoConstraints = false
//        return b
//    }()
//
//    private let createButton: UIButton = {
//        var config = UIButton.Configuration.filled()
//        config.title = "Создать"
//        config.baseForegroundColor = .white
//        config.baseBackgroundColor = UIColor(named: "YPGray") ?? UIColor.systemGray
//        config.contentInsets = NSDirectionalEdgeInsets(top: 19, leading: 32, bottom: 19, trailing: 32)
//        config.cornerStyle = .medium
//        let b = UIButton(type: .system)
//        b.configuration = config
//        b.titleLabel?.font = UIFont.systemFont(ofSize: 16)
//        b.translatesAutoresizingMaskIntoConstraints = false
//        return b
//    }()
//
//    // MARK: Defaults
//    var defaultCategoryUuid: UUID = UUID()
//    var defaultColor: Colors = .pinkEnergy
//    private let maxNameLength = 38
//
//    // MARK: Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//
//        // Добавление вьюшек
//        view.addSubview(nameField)
//        view.addSubview(nameWarningLabel)
//
//        // Emoji
//        view.addSubview(emojiTitleLabel)
//        view.addSubview(emojiCollection)
//        emojiCollection.dataSource = self
//        emojiCollection.delegate = self
//        emojiCollection.reloadData()
//
//        view.addSubview(categoryScheduleContainer)
//        categoryScheduleContainer.addSubview(categoryButton)
//        categoryScheduleContainer.addSubview(separatorView)
//        categoryScheduleContainer.addSubview(scheduleButton)
//        view.addSubview(scheduleSummaryLabel)
//
//        view.addSubview(cancelButton)
//        view.addSubview(createButton)
//
//        title = "Новая привычка"
//
//        // Настройка таргетов
//        categoryButton.addTarget(self, action: #selector(categoryTapped), for: .touchUpInside)
//        scheduleButton.addTarget(self, action: #selector(scheduleTapped), for: .touchUpInside)
//        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
//        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
//
//        nameField.addTarget(self, action: #selector(nameFieldChanged(_:)), for: .editingChanged)
//        nameField.delegate = self
//
//        setupConstraints()
//
//        view.bringSubviewToFront(nameWarningLabel)
//    }
//
//    // MARK: Layout
//    private func setupConstraints() {
//        NSLayoutConstraint.activate([
//            nameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            nameField.heightAnchor.constraint(equalToConstant: 75),
//            
//            nameWarningLabel.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 8),
//            nameWarningLabel.centerXAnchor.constraint(equalTo: nameField.centerXAnchor),
//            nameWarningLabel.widthAnchor.constraint(equalTo: nameField.widthAnchor, multiplier: 1, constant: -24),
//            
//            
//            categoryScheduleContainer.topAnchor.constraint(equalTo: nameWarningLabel.bottomAnchor, constant: 8),
//            categoryScheduleContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            categoryScheduleContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            categoryScheduleContainer.heightAnchor.constraint(equalToConstant: 150),
//            
//            
//            categoryButton.leadingAnchor.constraint(equalTo: categoryScheduleContainer.leadingAnchor),
//            categoryButton.trailingAnchor.constraint(equalTo: categoryScheduleContainer.trailingAnchor),
//            categoryButton.topAnchor.constraint(equalTo: categoryScheduleContainer.topAnchor),
//            categoryButton.bottomAnchor.constraint(equalTo: separatorView.topAnchor),
//            
//            
//            separatorView.leadingAnchor.constraint(equalTo: categoryScheduleContainer.leadingAnchor, constant: 8),
//            separatorView.trailingAnchor.constraint(equalTo: categoryScheduleContainer.trailingAnchor, constant: -8),
//            separatorView.centerYAnchor.constraint(equalTo: categoryScheduleContainer.centerYAnchor),
//            separatorView.heightAnchor.constraint(equalToConstant: 1),
//            
//           
//            scheduleButton.leadingAnchor.constraint(equalTo: categoryScheduleContainer.leadingAnchor),
//            scheduleButton.trailingAnchor.constraint(equalTo: categoryScheduleContainer.trailingAnchor),
//            scheduleButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
//            scheduleButton.bottomAnchor.constraint(equalTo: categoryScheduleContainer.bottomAnchor),
//            
//            
//            scheduleSummaryLabel.leadingAnchor.constraint(equalTo: categoryScheduleContainer.leadingAnchor, constant: 16),
//            scheduleSummaryLabel.trailingAnchor.constraint(equalTo: categoryScheduleContainer.trailingAnchor, constant: -16),
//            scheduleSummaryLabel.topAnchor.constraint(equalTo: scheduleButton.bottomAnchor, constant: -20),
//            scheduleSummaryLabel.bottomAnchor.constraint(lessThanOrEqualTo: categoryScheduleContainer.bottomAnchor, constant: -8),
//            
//            // Emoji title
//            emojiTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 356),
//            emojiTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
//            emojiTitleLabel.widthAnchor.constraint(equalToConstant: 52),
//            emojiTitleLabel.heightAnchor.constraint(equalToConstant: 18),
//            
//            // Emoji collection (Figma)
//            emojiCollection.topAnchor.constraint(equalTo: view.topAnchor, constant: 380),
//            emojiCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 1),
//            emojiCollection.widthAnchor.constraint(equalToConstant: 374),
//            emojiCollection.heightAnchor.constraint(equalToConstant: 204),
//            
//            
//            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -34),
//            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            createButton.heightAnchor.constraint(equalToConstant: 60),
//            createButton.widthAnchor.constraint(equalToConstant: 161),
//            
//            cancelButton.centerYAnchor.constraint(equalTo: createButton.centerYAnchor),
//            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            cancelButton.heightAnchor.constraint(equalToConstant: 60),
//            cancelButton.widthAnchor.constraint(equalToConstant: 166),
//            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8)
//        ])
//    }
//
//    // MARK: Actions
//    @objc private func categoryTapped() {
//        // TODO: реализовать выбор категории
//    }
//
//    @objc private func scheduleTapped() {
//        let vc = ScheduleViewController(initialSelectedDays: selectedScheduleDays)
//        vc.delegate = self
//        let nav = UINavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .automatic
//        present(nav, animated: true)
//    }
//
//    @objc private func cancelTapped() {
//        dismiss(animated: true)
//    }
//
//    @objc private func createTapped() {
//        guard let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
//            return
//        }
//
//        let chosenEmoji = (selectedEmojiIndex != nil) ? emojis[selectedEmojiIndex!] : "⭐"
//        let tracker = Tracker(
//            id: UUID(),
//            name: name,
//            categoryId: defaultCategoryUuid,
//            schedule: selectedScheduleDays.isEmpty ? nil : selectedScheduleDays,
//            emoji: chosenEmoji,
//            color: defaultColor,
//            completedDates: Set<Date>()
//        )
//
//        delegate?.createTrackerDidCreate(tracker)
//        dismiss(animated: true)
//    }
//
//    @objc private func nameFieldChanged(_ textField: UITextField) {
//        let text = textField.text ?? ""
//        nameWarningLabel.isHidden = text.count <= maxNameLength
//    }
//}
//
//// MARK: - ScheduleViewControllerDelegate
//extension CreateTrackerViewController: ScheduleViewControllerDelegate {
//    func scheduleViewController(_ vc: ScheduleViewController, didSelectDays selectedDays: [WeekDay]) {
//        selectedScheduleDays = selectedDays
//
//        if selectedDays.isEmpty {
//            scheduleSummaryLabel.isHidden = true
//            scheduleSummaryLabel.text = nil
//        } else {
//            scheduleSummaryLabel.isHidden = false
//            scheduleSummaryLabel.text = selectedDays.map { $0.shortName }.joined(separator: ", ")
//        }
//    }
//}
//
//// MARK: - UITextFieldDelegate (validation)
//extension CreateTrackerViewController: UITextFieldDelegate {
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let current = textField.text ?? ""
//        guard let stringRange = Range(range, in: current) else { return false }
//        let updated = current.replacingCharacters(in: stringRange, with: string)
//
//        if updated.count > maxNameLength {
//            nameWarningLabel.isHidden = false
//            return false
//        }
//
//        nameWarningLabel.isHidden = updated.count <= maxNameLength
//        return true
//    }
//
//    func textFieldShouldClear(_ textField: UITextField) -> Bool {
//        nameWarningLabel.isHidden = true
//        return true
//    }
//}
//
//// MARK: - Emoji Collection
//extension CreateTrackerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        emojis.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.identifier, for: indexPath) as? EmojiCell else {
//            return UICollectionViewCell()
//        }
//        let isSelected = indexPath.item == selectedEmojiIndex
//        cell.configure(with: emojis[indexPath.item], selected: isSelected)
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let previous = selectedEmojiIndex
//        selectedEmojiIndex = indexPath.item
//        var reload: [IndexPath] = [indexPath]
//        if let p = previous, p != indexPath.item { reload.append(IndexPath(item: p, section: 0)) }
//        collectionView.reloadItems(at: reload)
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let columns: CGFloat = 6
//        let spacing: CGFloat = 8 * (columns - 1)
//        let available = collectionView.frame.width - spacing
//        let w = floor(available / columns)
//        return CGSize(width: w, height: 40)
//    }
//}


















