import UIKit
import AppMetricaCore

final class TrackersViewController: UIViewController {
    
    // MARK: - Properties
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var filteredCategories: [TrackerCategory] = []
    private var hasTrackersForSelectedDate: Bool = false
    private var searchText: String = ""
    private var searchController: UISearchController!
    private var trackerStore: TrackerStore!
    private var trackerCategoryStore: TrackerCategoryStore!
    private var trackerRecordStore: TrackerRecordStore!
    private var currentFilter: TrackerFilter = .all {
        didSet {
            UserDefaults.standard.set(currentFilter.rawValue, forKey: "SelectedFilter")
        }
    }
    
    private let analyticsService = AnalyticsService()
    
    // MARK: - UI Elements
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 16
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var placeholderStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var placeholderView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "dizzy")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = Localizable.noTrackersPlaceholder
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .ypBlack)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        let currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        if currentLanguage == "ru" {
            picker.locale = Locale(identifier: "ru_RU")
        } else {
            picker.locale = Locale(identifier: "en_US")
        }
        picker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return picker
    }()
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Localizable.filtersButton, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(UIColor(resource: .ypWhite), for: .normal)
        button.backgroundColor = UIColor(resource: .ypBlue)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.1
        
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedFilterRawValue = UserDefaults.standard.string(forKey: "SelectedFilter"),
           let savedFilter = TrackerFilter(rawValue: savedFilterRawValue) {
            currentFilter = savedFilter
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        
        trackerStore = appDelegate.trackerStore
        trackerCategoryStore = appDelegate.trackerCategoryStore
        trackerRecordStore = appDelegate.trackerRecordStore
        
        setupStoreObservers()
        
        loadData()
        setupUI()
        updateUI()
        setupGestureRecognizer()
        removeNavigationBarSeparator()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.report(.open(screen: .main))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        analyticsService.report(.close(screen: .main))
    }
    
    // MARK: - Store Observers
    private func setupStoreObservers() {
        trackerCategoryStore.onCategoriesDidChange = { [weak self] categories in
            self?.categories = categories
            self?.updateUI()
        }
        
        trackerRecordStore.onRecordsDidChange = { [weak self] records in
            self?.completedTrackers = records
            self?.updateUI()
        }
    }
    
    // MARK: - Data Loading
    private func loadData() {
        do {
            categories = try trackerCategoryStore.fetchAllCategories()
            completedTrackers = try trackerRecordStore.fetchAllRecords()
            print("DEBUG: Loaded \(categories.count) categories, \(categories.flatMap { $0.trackers }.count) trackers, \(completedTrackers.count) records")
        } catch {
            print("Error loading data: \(error)")
        }
    }
    
    // MARK: - Tracker Completion Methods
    private func completeTracker(with id: UUID) {
        let selectedDate = datePicker.date
        let today = Date()
        
        if selectedDate > today {
            print(Localizable.futureDateError)
            return
        }
        
        let record = TrackerRecord(id: id, date: selectedDate)
        
        do {
            try trackerRecordStore.addRecord(record)
            completedTrackers.append(record)
            updateUI()
        } catch {
            print("Error completing tracker: \(error)")
        }
    }
    
    private func uncompleteTracker(with id: UUID) {
        let selectedDate = datePicker.date
        
        do {
            try trackerRecordStore.removeRecord(with: id, date: selectedDate)
            completedTrackers.removeAll {
                $0.id == id && Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
            }
            updateUI()
        } catch {
            print("Error uncompleting tracker: \(error)")
        }
    }
    
    private func isTrackerCompletedToday(_ id: UUID) -> Bool {
        let selectedDate = datePicker.date
        return completedTrackers.contains {
            $0.id == id && Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
    }
    
    private func getCompletionCount(for trackerId: UUID) -> Int {
        do {
            return try trackerRecordStore.completionCount(for: trackerId)
        } catch {
            print("Error getting completion count: \(error)")
            return 0
        }
    }
    
    // MARK: - Add Tracker
    private func addTracker(_ tracker: Tracker, toCategory categoryTitle: String) {
        do {
            try trackerStore.addTracker(tracker, to: categoryTitle)
            print("DEBUG: Tracker added successfully")
            loadData()
            updateUI()
        } catch {
            print("Error adding tracker: \(error)")
        }
    }
    
    // MARK: - Navigation Bar Separator
    private func removeNavigationBarSeparator() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    // MARK: - Gesture Recognizer
    private func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
        searchController.searchBar.resignFirstResponder()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupCollectionView()
        setupPlaceholder()
        setupFiltersButton()
    }
    
    private func setupNavigationBar() {
        title = Localizable.trackersTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ]
        appearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        let addButton = UIBarButtonItem(
            image: UIImage(resource: .plus),
            style: .plain,
            target: self,
            action: #selector(addButtonTapped)
        )
        addButton.tintColor = UIColor(resource: .ypBlack)
        navigationItem.leftBarButtonItem = addButton
        
        let datePickerContainer = UIView()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePickerContainer.addSubview(datePicker)
        let datePickerWidth: CGFloat = 120
        
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: datePickerContainer.topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: datePickerContainer.bottomAnchor),
            datePicker.leadingAnchor.constraint(equalTo: datePickerContainer.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: datePickerContainer.trailingAnchor),
            datePickerContainer.widthAnchor.constraint(equalToConstant: datePickerWidth)
        ])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePickerContainer)
        
        setupSearchController()
    }
    
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = Localizable.searchPlaceholder
        searchController.searchBar.searchTextField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        searchController.searchBar.searchTextField.textColor = .gray
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        collectionView.alwaysBounceVertical = true
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupPlaceholder() {
        placeholderStackView.addArrangedSubview(placeholderView)
        placeholderStackView.addArrangedSubview(placeholderLabel)
        view.addSubview(placeholderStackView)
        
        NSLayoutConstraint.activate([
            placeholderView.widthAnchor.constraint(equalToConstant: 80),
            placeholderView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderStackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            placeholderStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupFiltersButton() {
        view.addSubview(filtersButton)
        
        NSLayoutConstraint.activate([
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        updateFiltersButtonVisibility()
    }
    
    // MARK: - UI Update
    private func updateUI() {
        filterTrackers()
        
        let hasData = filteredCategories.contains { !$0.trackers.isEmpty }
        placeholderStackView.isHidden = hasData
        collectionView.isHidden = !hasData
        
        if !hasData && (!searchText.isEmpty || currentFilter != .all) {
            placeholderView.image = UIImage(named: "empty_search")
            placeholderLabel.text = Localizable.nothingFound
        } else {
            placeholderView.image = UIImage(named: "Star")
            placeholderLabel.text = Localizable.noTrackersPlaceholder
        }
        
        collectionView.reloadData()
        updateFiltersButtonVisibility()
    }
    
    // MARK: - Filter Methods
    private func updateFiltersButtonVisibility() {
        let shouldShow = hasTrackersForSelectedDate

        if shouldShow {
            filtersButton.isHidden = false
            UIView.animate(withDuration: 0.25) {
                self.filtersButton.alpha = 1.0
            }
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.filtersButton.alpha = 0.0
            }) { _ in
                self.filtersButton.isHidden = true
            }
        }
    }
    
    @objc private func filtersButtonTapped() {
        analyticsService.report(.click(screen: .main, item: .filter))
        let filtersVC = FiltersViewController(selectedFilter: currentFilter) { [weak self] selectedFilter in
            self?.applyFilter(selectedFilter)
        }
        
        let navController = UINavigationController(rootViewController: filtersVC)
        present(navController, animated: true)
    }
    
    private func applyFilter(_ filter: TrackerFilter) {
        currentFilter = filter
        
        switch filter {
        case .today:
            datePicker.date = Date()
            fallthrough
        case .all:
            break
        case .completed, .uncompleted:
            break
        }
        
        updateUI()
    }
    
    private func filterTrackers() {
        let selectedDate = datePicker.date
        let weekday = Calendar.current.component(.weekday, from: selectedDate)

        var dateFilteredCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.schedule.contains { $0.rawValue == weekday }
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }

    
        hasTrackersForSelectedDate = dateFilteredCategories.contains { !$0.trackers.isEmpty }

        switch currentFilter {
        case .all, .today:
            break

        case .completed:
            dateFilteredCategories = dateFilteredCategories.map { category in
                let filtered = category.trackers.filter { isTrackerCompletedToday($0.id) }
                return TrackerCategory(title: category.title, trackers: filtered)
            }

        case .uncompleted:
            dateFilteredCategories = dateFilteredCategories.map { category in
                let filtered = category.trackers.filter { !isTrackerCompletedToday($0.id) }
                return TrackerCategory(title: category.title, trackers: filtered)
            }
        }

        if !searchText.isEmpty {
            dateFilteredCategories = dateFilteredCategories.map { category in
                let filtered = category.trackers.filter {
                    $0.title.lowercased().contains(searchText.lowercased())
                }
                return TrackerCategory(title: category.title, trackers: filtered)
            }
        }
        
        filteredCategories = dateFilteredCategories.filter { !$0.trackers.isEmpty }
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        analyticsService.report(.click(screen: .main, item: .addTrack))
        let habitVC = HabitViewController(
            trackerCategoryStore: trackerCategoryStore,
            trackerRecordStore: trackerRecordStore
        )
        habitVC.onSave = { [weak self] tracker, categoryTitle in
            self?.addTracker(tracker, toCategory: categoryTitle)
        }
        
        let navController = UINavigationController(rootViewController: habitVC)
        present(navController, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        updateUI()
    }
    
    func handleTrackerCompletion(_ trackerId: UUID, _ isCompleted: Bool) {
        analyticsService.report(.click(screen: .main, item: .track))
        if isCompleted {
            completeTracker(with: trackerId)
        } else {
            uncompleteTracker(with: trackerId)
        }
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.identifier,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        let isCompleted = isTrackerCompletedToday(tracker.id)
        let completionCount = getCompletionCount(for: tracker.id)
        
        cell.configure(
            with: tracker,
            isCompletedToday: isCompleted,
            completionCount: completionCount
        ) { [weak self] trackerId, isCompleted in
            self?.handleTrackerCompletion(trackerId, isCompleted)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return UICollectionReusableView()
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = max(0, collectionView.frame.width - 16)
        let cellWidth = availableWidth / 2
        return CGSize(width: max(0, cellWidth), height: max(0, 148))
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            return self?.makeContextMenu(for: indexPath)
        }
    }
    
    private func makeContextMenu(for indexPath: IndexPath) -> UIMenu {
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        
        let editAction = UIAction(
            title: Localizable.editAction,
            image: nil
        ) { [weak self] _ in
            self?.analyticsService.report(.click(screen: .main, item: .edit))
            self?.editTracker(tracker)
        }
        
        let deleteAction = UIAction(
            title: Localizable.deleteAction,
            image: nil,
            attributes: .destructive
        ) { [weak self] _ in
            self?.analyticsService.report(.click(screen: .main, item: .delete))
            self?.deleteTracker(tracker)
        }
        
        return UIMenu(title: "", children: [editAction, deleteAction])
    }
    
    private func editTracker(_ tracker: Tracker) {
        print("DEBUG: Editing tracker: \(tracker.title)")
        
        let habitVC = HabitViewController(
            trackerCategoryStore: trackerCategoryStore,
            trackerRecordStore: trackerRecordStore
        )
        
        habitVC.mode = .edit(tracker)
        
        habitVC.onSave = { [weak self] updatedTracker, categoryTitle in
            self?.updateTracker(updatedTracker, in: categoryTitle)
        }
        
        let navController = UINavigationController(rootViewController: habitVC)
        present(navController, animated: true)
    }
    
    private func deleteTracker(_ tracker: Tracker) {
        let alert = UIAlertController(
            title: Localizable.deleteTrackerConfirmation,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(
            title: Localizable.deleteAction,
            style: .destructive
        ) { [weak self] _ in
            self?.performDeleteTracker(tracker)
        }
        
        let cancelAction = UIAlertAction(
            title: Localizable.cancelButton,
            style: .cancel
        )
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func performDeleteTracker(_ tracker: Tracker) {
        do {
            try trackerStore.deleteTracker(tracker.id)
            print("DEBUG: Tracker deleted successfully")
            loadData()
            updateUI()
        } catch {
            print("Error deleting tracker: \(error)")
        }
    }
    
    private func updateTracker(_ tracker: Tracker, in categoryTitle: String) {
        do {
            try trackerStore.updateTracker(tracker, in: categoryTitle)
            print("DEBUG: Tracker updated successfully")
            loadData()
            updateUI()
        } catch {
            print("Error updating tracker: \(error)")
        }
    }
}

// MARK: - Search Bar Delegate
extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        updateUI()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
