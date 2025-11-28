
//  Created by William White on 02.11.2025.
//


import Foundation
import UIKit


// MARK: - TrackerViewController extensions: Presenter, Search, Date handling
extension TrackerViewController: TrackerPresenterProtocol, UISearchBarDelegate, UISearchControllerDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let itemsFilter = items.filter { tracker in
            tracker.name.lowercased().contains(searchText.lowercased())
        }

        if searchText.count > 0 {
            resultSections = willCollectSections(categories: categories, trackers: itemsFilter)
        } else {
            resultSections = willCollectSections(categories: categories, trackers: items)
        }

        collectionTracker?.collection.reloadData()
        collectionTracker?.showEmptyDataView(visible: resultSections.isEmpty)
    }

    @objc func changeDate(sender: UIDatePicker) {
        selectedDate = sender.date

        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: sender.date)
        guard let selectedWeekDay = WeekDay(calendarWeekday: weekdayNumber) else { return }

        let filtered = items.filter { tracker in
            guard let schedule = tracker.schedule else { return true }
            return schedule.contains(where: { $0 == selectedWeekDay })
        }

        resultSections = willCollectSections(categories: categories, trackers: filtered)
        collectionTracker?.collection.reloadData()
        collectionTracker?.showEmptyDataView(visible: resultSections.isEmpty)
    }
}

// MARK: - CreateTrackerDelegate
extension TrackerViewController: CreateTrackerDelegate {
    func createTrackerDidCreate(_ tracker: Tracker) {
        items.append(tracker)
        sections = willCollectSections(categories: categories, trackers: items)
        resultSections = sections
        collectionTracker?.collection.reloadData()
        collectionTracker?.showEmptyDataView(visible: resultSections.isEmpty)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let xySize = marginsBetweenCells / 2
        return UIEdgeInsets(top: xySize, left: xySize, bottom: xySize, right: xySize)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.frame.size.width / perRow - marginsBetweenCells
        return CGSize(width: width, height: 150)
    }
}

// MARK: - UICollectionViewDataSource
extension TrackerViewController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        resultSections.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.frame.size.width, height: 50.0)
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let section = resultSections[indexPath.section]

        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerHeaderCollection.identifier,
                for: indexPath
            ) as? TrackerHeaderCollection

            guard let header else { return UICollectionReusableView() }
            header.setTitle(title: section.category.name)
            return header
        default:
            fatalError("collectionView(_:viewForSupplementaryElementOfKind:at:) has not been implemented")
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        resultSections[section].items?.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.identifier,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }

        let section = resultSections[indexPath.section]
        guard let tracker = section.items?[indexPath.row] else {
            return cell
        }

        cell.delegate = self
        cell.setupForTracking(tracker: tracker, selectedDate: selectedDate)

        return cell
    }
}

// MARK: - TrackerCellDelegate (plus button handling)
extension TrackerViewController: TrackerCellDelegate {
    func trackerCellDidTapPlus(_ cell: TrackerCell) {
        guard let indexPath = collectionTracker?.collection.indexPath(for: cell) else { return }
        guard let tracker = resultSections[indexPath.section].items?[indexPath.row] else { return }

        let now = Date()
        if selectedDate.startOfDay > now.startOfDay { return }

        let wasCompleted = tracker.isCompleted(on: selectedDate)

        if wasCompleted {
            let updated = tracker.unmarkingCompleted(on: selectedDate)
            replaceTracker(updated)
            if let visibleCell = collectionTracker?.collection.cellForItem(at: indexPath) as? TrackerCell {
                visibleCell.updateCountLabel()
                visibleCell.setCompletedButton(isCompleted: false)
            } else {
                collectionTracker?.collection.reloadItems(at: [indexPath])
            }
        } else {
            let updated = tracker.markingCompleted(on: selectedDate)
            replaceTracker(updated)
            if let visibleCell = collectionTracker?.collection.cellForItem(at: indexPath) as? TrackerCell {
                visibleCell.updateCountLabel()
                visibleCell.setCompletedButton(isCompleted: true)
            } else {
                collectionTracker?.collection.reloadItems(at: [indexPath])
            }
        }
    }

    // replace tracker in storage arrays
    private func replaceTracker(_ updated: Tracker) {
        // replace in items
        if let idx = items.firstIndex(where: { $0.id == updated.id }) {
            items[idx] = updated
        }

        // replace in sections and resultSections
        func replaceIn(_ sectionsArray: inout [TrackerSection]) {
            for sIndex in sectionsArray.indices {
                guard var list = sectionsArray[sIndex].items else { continue }
                if let tIndex = list.firstIndex(where: { $0.id == updated.id }) {
                    list[tIndex] = updated
                    sectionsArray[sIndex] = TrackerSection(category: sectionsArray[sIndex].category, items: list)
                }
            }
        }

        replaceIn(&sections)
        replaceIn(&resultSections)
    }
}

// MARK: - TrackerViewController main implementation
class TrackerViewController: UIViewController {
    private let perRow: CGFloat = 2
    private let marginsBetweenCells: CGFloat = 10
    private var collectionTracker: CollectionTracker?

    // Category must have `id: UUID`
    private var categories = [
        TrackerCategory(id: UUID(), name: "Домашний уют")
    ]

    private var sections: [TrackerSection] = []
    private var resultSections: [TrackerSection] = []
    private var items: [Tracker] = []
    private var selectedDate: Date = Date()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = tabBarItem.title

        let datePicker = DatePickerController(presenter: self).register()
        datePicker.picker.addTarget(self, action: #selector(changeDate(sender:)), for: .valueChanged)
        selectedDate = datePicker.picker.date

        CreateTrackerButton(presenter: self).registerAsLeftButton()
        SearchController(presenter: self).register()
        collectionTracker = CollectionTracker(presenter: self).register()

        items = fetchData()

        sections = willCollectSections(categories: categories, trackers: items)
        resultSections = sections

        collectionTracker?.collection.reloadData()
        collectionTracker?.showEmptyDataView(visible: resultSections.isEmpty)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let bg = collectionTracker?.collection.backgroundView {
            bg.frame = collectionTracker!.collection.bounds
        }
    }

    private func fetchData() -> [Tracker] {
        (0..<1).compactMap { _ in randomTracker(categories: categories) }
    }

    private func willCollectSections(categories: [TrackerCategory], trackers: [Tracker]) -> [TrackerSection] {
        let groupTrackers = Dictionary(grouping: trackers, by: { $0.categoryId })

        var collection: [TrackerSection] = []
        groupTrackers.forEach { (categoryId: UUID, trackers: [Tracker]) in
            if let category = categories.first(where: { $0.id == categoryId }) {
                collection.append(TrackerSection(category: category, items: trackers))
            }
        }

        collection.sort { section, section2 in
            section.category.name < section2.category.name
        }

        return collection
    }

    private func randomTracker(categories: [TrackerCategory]) -> Tracker? {
        let names = ["Поливать растения"].shuffled()
        guard let id = categories.first?.id else { return nil }

        return Tracker(
            id: UUID(),
            name: names[0],
            categoryId: id,
            schedule: nil,
            emoji: "🌼",
            color: .green,    
            completedDates: Set()
        )
    }

    override var tabBarItem: UITabBarItem! {
        get {
            UITabBarItem(
                title: "Трекеры",
                image: UIImage(systemName: "record.circle.fill"),
                tag: 0
            )
        }
        set { super.tabBarItem = newValue }
    }
}









