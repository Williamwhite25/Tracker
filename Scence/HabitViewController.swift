import UIKit

// Экран создания/редактирования привычки
final class HabitViewController: UIViewController {
    
    // MARK: - Properties
    var onSave: ((Tracker, String) -> Void)?
    var mode: Mode = .create
    
    // Перечисление режимов работы контроллера
    enum Mode {
        case create
        case edit(Tracker)
    }
    
    private var selectedDays: [Weekday] = []
    private var selectedEmoji: String?
    private var selectedColor: String?
    private var selectedCategoryTitle: String?
    private let trackerCategoryStore: TrackerCategoryStore
    private let trackerRecordStore: TrackerRecordStore
    
    private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    private let colors = (1...18).map { "selection_\($0)" }
    
    private var completedTrackersCount: Int = 0
    private var emojiCollectionHeightConstraint: NSLayoutConstraint!
    private var colorCollectionHeightConstraint: NSLayoutConstraint!
    private var titleTextFieldTopConstraint: NSLayoutConstraint!
    private var completedTrackersLabelHeightConstraint: NSLayoutConstraint!
    
    // MARK: - UI Elements
    private lazy var completedTrackersLabel: UILabel = {
        let label = UILabel()
        label.text = Localizable.daysCount(0)
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = UIColor(resource: .ypBlack)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Текстовое поле для ввода названия трекера
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Localizable.trackerNamePlaceholder
        textField.backgroundColor = UIColor(resource: .ypBackground)
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.delegate = self
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    // Таблица с опциями (категория и расписание)
    private lazy var optionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = UIColor(white: 0.0, alpha: 0.3)
        tableView.register(OptionTableViewCell.self, forCellReuseIdentifier: "OptionCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // Заголовок секции с эмодзи
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.text = Localizable.emojiSection
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textColor = UIColor(resource: .ypBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Коллекция с эмодзи
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // Заголовок секции с цветами
    private lazy var colorLabel: UILabel = {
        let label = UILabel()
        label.text = Localizable.colorSection
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textColor = UIColor(resource: .ypBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Коллекция с цветами
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(Localizable.cancelButton, for: .normal)
        button.setTitleColor(UIColor(resource: .ypRed), for: .normal)
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(resource: .ypRed).cgColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(Localizable.createButton, for: .normal)
        button.setTitleColor(UIColor(resource: .ypWhite), for: .normal)
        button.backgroundColor = UIColor(resource: .ypGray)
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Lifecycle
    init(trackerCategoryStore: TrackerCategoryStore, trackerRecordStore: TrackerRecordStore) {
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerRecordStore = trackerRecordStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupGestureRecognizer()
        setupForMode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCollectionViewHeightsSafe()
    }
    
    // MARK: - Gesture Recognizer
    private func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Mode Setup
    private func setupForMode() {
        switch mode {
        case .create:
            navigationItem.title = Localizable.newHabitTitle
            createButton.setTitle(Localizable.createButton, for: .normal)
            completedTrackersLabel.isHidden = true
            completedTrackersLabelHeightConstraint.constant = 0
            titleTextFieldTopConstraint.constant = 24
            
        case .edit(let tracker):
            navigationItem.title = Localizable.editHabitTitle
            createButton.setTitle(Localizable.saveButton, for: .normal)
            completedTrackersLabel.isHidden = false
            completedTrackersLabelHeightConstraint.constant = 38
            titleTextFieldTopConstraint.constant = 108
            populateWithTracker(tracker)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // Заполняет поля данными трекера для редактирования
    private func populateWithTracker(_ tracker: Tracker) {
        titleTextField.text = tracker.title
        selectedDays = tracker.schedule
        selectedEmoji = tracker.emoji
        selectedColor = tracker.color
        
        if let category = trackerCategoryStore.getCategory(for: tracker) {
            selectedCategoryTitle = category.title
        }
        
        loadCompletionCount(for: tracker.id)
        updateCreateButtonState()
        optionsTableView.reloadData()
        emojiCollectionView.reloadData()
        colorCollectionView.reloadData()
    }
    // MARK: - Data Loading
    private func loadCompletionCount(for trackerId: UUID) {
        do {
            completedTrackersCount = try trackerRecordStore.completionCount(for: trackerId)
            updateCompletedTrackersLabel()
        } catch {
            print("Error loading completion count: \(error)")
            completedTrackersCount = 0
            updateCompletedTrackersLabel()
        }
    }
    
    private func updateCompletedTrackersLabel() {
        completedTrackersLabel.text = Localizable.daysCount(completedTrackersCount)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(completedTrackersLabel)
        contentView.addSubview(titleTextField)
        contentView.addSubview(optionsTableView)
        contentView.addSubview(emojiLabel)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorLabel)
        contentView.addSubview(colorCollectionView)
        contentView.addSubview(buttonsStackView)
        
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(createButton)
        
        emojiCollectionHeightConstraint = emojiCollectionView.heightAnchor.constraint(equalToConstant: 204)
        colorCollectionHeightConstraint = colorCollectionView.heightAnchor.constraint(equalToConstant: 204)
        
        titleTextFieldTopConstraint = titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24)
        completedTrackersLabelHeightConstraint = completedTrackersLabel.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            completedTrackersLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            completedTrackersLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            completedTrackersLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            completedTrackersLabel.heightAnchor.constraint(equalToConstant: 38),
            
            titleTextFieldTopConstraint,
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 75),
            
            
            optionsTableView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 24),
            optionsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            optionsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            optionsTableView.heightAnchor.constraint(equalToConstant: 150),
            
            emojiLabel.topAnchor.constraint(equalTo: optionsTableView.bottomAnchor, constant: 24),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            emojiLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 24),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiCollectionHeightConstraint,
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            colorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 24),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorCollectionHeightConstraint,
            
            buttonsStackView.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 0),
            buttonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Height Calculation
    private func updateCollectionViewHeightsSafe() {
        guard view.window != nil else {
            DispatchQueue.main.async { [weak self] in
                self?.updateCollectionViewHeightsSafe()
            }
            return
        }
        
        let emojiRows = ceil(CGFloat(emojis.count) / 6.0)
        let emojiHeight = emojiRows * 52 + (emojiRows - 1) * 5 + 24
        
        let colorRows = ceil(CGFloat(colors.count) / 6.0)
        let colorHeight = colorRows * 52 + (colorRows - 1) * 5 + 24
        
        emojiCollectionHeightConstraint.constant = emojiHeight
        colorCollectionHeightConstraint.constant = colorHeight
        
        UIView.animate(withDuration: 0) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.title = Localizable.newHabitTitle
        
        if let navigationBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            appearance.shadowColor = .clear
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactAppearance = appearance
            navigationBar.prefersLargeTitles = false
        }
    }
    
    // MARK: - Button State
    private func updateCreateButtonState() {
        let isTitleValid = !(titleTextField.text?.isEmpty ?? true)
        let isScheduleSelected = !selectedDays.isEmpty
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil
        let isCategorySelected = selectedCategoryTitle != nil
        
        createButton.isEnabled = isTitleValid && isScheduleSelected && isEmojiSelected && isColorSelected && isCategorySelected
        createButton.backgroundColor = createButton.isEnabled ? UIColor(resource: .ypBlack) : UIColor(resource: .ypGray)
    }
    
    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let title = titleTextField.text, !title.isEmpty,
              let emoji = selectedEmoji,
              let color = selectedColor,
              let categoryTitle = selectedCategoryTitle else { return }
        
        switch mode {
        case .create:
            let newTracker = Tracker(
                title: title,
                color: color,
                emoji: emoji,
                schedule: selectedDays,
                isHabit: true
            )
            print("Creating new tracker: '\(title)'")
            onSave?(newTracker, categoryTitle)
            
        case .edit(let originalTracker):
            let updatedTracker = Tracker(
                id: originalTracker.id,
                title: title,
                color: color,
                emoji: emoji,
                schedule: selectedDays,
                isHabit: originalTracker.isHabit
            )
            print("Updating tracker: '\(title)' with ID: \(originalTracker.id)")
            onSave?(updatedTracker, categoryTitle)
        }
        
        dismiss(animated: true)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, text.count > 38 {
            textField.text = String(text.prefix(38))
        }
        updateCreateButtonState()
    }
}

extension HabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath) as? OptionTableViewCell else {
            return UITableViewCell()
        }
        
        switch indexPath.row {
        case 0:
            cell.configure(title: Localizable.categoryTitle, subtitle: selectedCategoryTitle)
        case 1:
            let daysText: String?
            if selectedDays.isEmpty {
                daysText = nil
            } else if selectedDays.count == 7 {
                daysText = Localizable.everyDay
            } else {
                daysText = selectedDays.map { $0.shortName }.joined(separator: ", ")
            }
            cell.configure(title: Localizable.scheduleTitle, subtitle: daysText)
        default:
            break
        }
        
        return cell
    }
}

extension HabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case tableView.numberOfRows(inSection: indexPath.section) - 1:
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
        default:
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            let categoriesVC = CategoriesViewController(
                trackerCategoryStore: trackerCategoryStore,
                selectedCategoryTitle: selectedCategoryTitle,
                onCategorySelect: { [weak self] categoryTitle in
                    self?.selectedCategoryTitle = categoryTitle
                    DispatchQueue.main.async {
                        self?.optionsTableView.reloadData()
                        self?.updateCreateButtonState()
                    }
                }
            )
            navigationController?.pushViewController(categoriesVC, animated: true)
            
        case 1:
            let scheduleVC = ScheduleViewController()
            scheduleVC.selectedDays = selectedDays
            scheduleVC.onDaysSelected = { [weak self] days in
                self?.selectedDays = days
                DispatchQueue.main.async {
                    self?.optionsTableView.reloadData()
                    self?.updateCreateButtonState()
                }
            }
            navigationController?.pushViewController(scheduleVC, animated: true)
            
        default:
            break
        }
    }
}

// MARK: - UICollectionViewDataSource
extension HabitViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case emojiCollectionView:
            return emojis.count
        case colorCollectionView:
            return colors.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case emojiCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as? EmojiCell else {
                return UICollectionViewCell()
            }
            let emoji = emojis[indexPath.item]
            cell.configure(with: emoji, selected: emoji == selectedEmoji)
            return cell
            
        case colorCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as? ColorCell else {
                return UICollectionViewCell()
            }
            let colorName = colors[indexPath.item]
            cell.configure(with: colorName, isSelected: colorName == selectedColor)
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HabitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let totalWidth = collectionView.bounds.width
        let itemsPerRow: CGFloat = 6
        let totalSpacing = totalWidth - (itemsPerRow * 52)
        return totalSpacing / (itemsPerRow - 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case emojiCollectionView:
            selectedEmoji = emojis[indexPath.item]
        case colorCollectionView:
            selectedColor = colors[indexPath.item]
        default:
            break
        }
        collectionView.reloadData()
        updateCreateButtonState()
    }
}

// MARK: - UITextFieldDelegate
extension HabitViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateCreateButtonState()
    }
}
