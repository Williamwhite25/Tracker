import UIKit
import AppMetricaCore

final class StatisticsViewController: UIViewController {
    
    // MARK: - Properties
    private var statisticsData: [StatisticItem] = []
    private var trackerRecordStore: TrackerRecordStore?
    
    private let analyticsService = AnalyticsService()
    
    // MARK: - UI Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Localizable.statisticsTitle
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(resource: .ypBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(StatisticCell.self, forCellWithReuseIdentifier: StatisticCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
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
        imageView.image = UIImage(named: "empty_statistic")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = Localizable.noStatisticsPlaceholder
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .ypBlack)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStore()
        setupUI()
        updateUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadStatistics()
        analyticsService.report(.open(screen: .statistics))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        analyticsService.report(.close(screen: .statistics))
    }
    
    // MARK: - Setup
    private func setupStore() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Error: AppDelegate not found")
            return
        }
        self.trackerRecordStore = appDelegate.trackerRecordStore
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupCollectionView()
        setupPlaceholder()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = Localizable.statisticsTitle
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
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 77),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalToConstant: 408)
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
    
    // MARK: - Statistics Calculation
    private func loadStatistics() {
        guard let trackerRecordStore = trackerRecordStore else {
            showErrorAlert(message: "Store not available")
            return
        }
        
        do {
            let records = try trackerRecordStore.fetchAllRecords()
            let trackers = try trackerRecordStore.fetchAllTrackers()
            statisticsData = createStatisticsItems(records: records, trackers: trackers)
            updateUI()
        } catch {
            print("Error loading statistics: \(error)")
            showErrorAlert(message: "Failed to load statistics")
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func createStatisticsItems(records: [TrackerRecord], trackers: [Tracker]) -> [StatisticItem] {
        var items: [StatisticItem] = []
        
        for statisticType in StatisticType.allCases {
            let value = calculateValue(for: statisticType, records: records, trackers: trackers)
            let title = getTitle(for: statisticType)
            items.append(StatisticItem(title: title, value: value))
        }
        
        return items
    }
    
    private func calculateValue(for type: StatisticType, records: [TrackerRecord], trackers: [Tracker]) -> Int {
        switch type {
        case .bestPeriod:
            return calculateBestPeriod(records: records)
        case .perfectDays:
            return calculatePerfectDays(records: records, trackers: trackers)
        case .completedTrackers:
            return calculateCompletedTrackers(records: records)
        case .averageValue:
            return calculateAverageValue(records: records)
        }
    }
    
    private func getTitle(for type: StatisticType) -> String {
        switch type {
        case .bestPeriod:
            return Localizable.bestPeriod
        case .perfectDays:
            return Localizable.perfectDays
        case .completedTrackers:
            return Localizable.completedTrackers
        case .averageValue:
            return Localizable.averageValue
        }
    }
    
    private func calculateBestPeriod(records: [TrackerRecord]) -> Int {
        let dates = Set(records.map { Calendar.current.startOfDay(for: $0.date) }).sorted()
        
        var maxStreak = 0
        var currentStreak = 0
        var previousDate: Date?
        
        for date in dates {
            switch calculateDaysBetween(previousDate, date) {
            case 1:
                currentStreak += 1
            case let days? where days > 1:
                currentStreak = 1
            default:
                currentStreak = 1
            }
            
            maxStreak = max(maxStreak, currentStreak)
            previousDate = date
        }
        
        return maxStreak
    }
    
    private func calculateDaysBetween(_ previousDate: Date?, _ currentDate: Date) -> Int? {
        guard let previousDate = previousDate else { return nil }
        let components = Calendar.current.dateComponents([.day], from: previousDate, to: currentDate)
        return components.day ?? 0
    }
    
    private func calculatePerfectDays(records: [TrackerRecord], trackers: [Tracker]) -> Int {
        let recordsByDate = Dictionary(grouping: records) { record in
            Calendar.current.startOfDay(for: record.date)
        }
        
        let habitTrackers = trackers.filter { $0.isHabit && !$0.schedule.isEmpty }
        
        var perfectDays = 0
        
        for (date, dateRecords) in recordsByDate {
            let weekday = Calendar.current.component(.weekday, from: date)
            let expectedHabits = habitTrackers.filter { tracker in
                tracker.schedule.contains { $0.rawValue == weekday }
            }
            
            let completedHabitIds = Set(dateRecords.map { $0.id })
            let expectedHabitIds = Set(expectedHabits.map { $0.id })
            
            switch (expectedHabitIds.isEmpty, expectedHabitIds.isSubset(of: completedHabitIds)) {
            case (false, true):
                perfectDays += 1
            default:
                break
            }
        }
        
        return perfectDays
    }
    
    private func calculateCompletedTrackers(records: [TrackerRecord]) -> Int {
        return records.count
    }
    
    private func calculateAverageValue(records: [TrackerRecord]) -> Int {
        let recordsByDate = Dictionary(grouping: records) { record in
            Calendar.current.startOfDay(for: record.date)
        }
        
        switch recordsByDate.isEmpty {
        case true:
            return 0
        case false:
            let totalRecords = records.count
            let totalDays = recordsByDate.count
            return Int(round(Double(totalRecords) / Double(totalDays)))
        }
    }
    
    // MARK: - UI Update
    private func updateUI() {
        let hasStatistics = statisticsData.contains { $0.value > 0 }
        
        switch hasStatistics {
        case true:
            placeholderStackView.isHidden = true
            collectionView.isHidden = false
            collectionView.reloadData()
        case false:
            placeholderStackView.isHidden = false
            collectionView.isHidden = true
        }
    }
}

extension StatisticsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return statisticsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: StatisticCell.identifier,
            for: indexPath
        )
        
        guard let statisticCell = cell as? StatisticCell else {
            assertionFailure("Unable to dequeue StatisticCell")
            return cell
        }
        
        let statisticItem = statisticsData[indexPath.item]
        statisticCell.configure(with: statisticItem)
        return statisticCell
    }
}

extension StatisticsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width
        return CGSize(width: availableWidth, height: 90)
    }
}
