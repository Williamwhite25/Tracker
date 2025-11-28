
//  Created by William White on 02.11.2025.
//



import Foundation
import UIKit

// MARK: - TrackerViewController extensions: Presenter, Search, Date handling
extension TrackerViewController: TrackerPresenterProtocol, UISearchBarDelegate, UISearchControllerDelegate {
    // Обработчик изменений текста в поисковой строке фильтрует трекеры по названию
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

    // Обработчик изменения даты в DatePicker фильтрует трекеры по расписанию
    @objc func changeDate(sender: UIDatePicker) {
        selectedDate = sender.date

        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: sender.date)
        guard let selectedWeekDay = WeekDay(calendarWeekday: weekdayNumber) else { return }

        let filtered = items.filter { tracker in
            // если расписание отсутствует считаем трекер подходящим
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
    // Делегат получения созданного трекера — добавляем в список и обновляем UI
    func createTrackerDidCreate(_ tracker: Tracker) {
        items.append(tracker)
        sections = willCollectSections(categories: categories, trackers: items)
        resultSections = sections
        collectionTracker?.collection.reloadData()
        collectionTracker?.showEmptyDataView(visible: resultSections.isEmpty)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout (layout configuration)
extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    // Отступы для секции
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let xySize = marginsBetweenCells / 2
        return UIEdgeInsets(top: xySize, left: xySize, bottom: xySize, right: xySize)
    }

    // Размер ячейки
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
    // Количество секций
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        resultSections.count
    }

    // Размер заголовка секции
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.frame.size.width, height: 50.0)
    }

    // Представление заголовка секции
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

    // Количество элементов в секции
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        resultSections[section].items?.count ?? 0
    }

    // Конфигурация ячейки
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
    // Обработка нажатия + в ячейке: снимаем выполнение трекера
    func trackerCellDidTapPlus(_ cell: TrackerCell) {
        guard let indexPath = collectionTracker?.collection.indexPath(for: cell) else { return }
        guard let tracker = resultSections[indexPath.section].items?[indexPath.row] else { return }

        let now = Date()

        // Нельзя отмечать будущую дату
        if selectedDate.startOfDay > now.startOfDay { return }

        let wasCompleted = tracker.isCompleted(on: selectedDate)

        if wasCompleted {
            // Снятие отметки выполнено
            let removed = tracker.unmarkCompleted(on: selectedDate)
            if removed {
                if let visibleCell = collectionTracker?.collection.cellForItem(at: indexPath) as? TrackerCell {
                    visibleCell.updateCountLabel()
                    visibleCell.setCompletedButton(isCompleted: false)
                } else {
                    collectionTracker?.collection.reloadItems(at: [indexPath])
                }
            }
        } else {
            // Установка отметки выполнено
            let added = tracker.markCompleted(on: selectedDate)
            if added {
                if let visibleCell = collectionTracker?.collection.cellForItem(at: indexPath) as? TrackerCell {
                    visibleCell.updateCountLabel()
                    visibleCell.setCompletedButton(isCompleted: true)
                } else {
                    collectionTracker?.collection.reloadItems(at: [indexPath])
                }
            }
        }
    }
}

// MARK: - TrackerViewController main implementation
class TrackerViewController: UIViewController {
    // Количество колонок и отступы
    private let perRow: CGFloat = 2
    private let marginsBetweenCells: CGFloat = 10
    private var collectionTracker: CollectionTracker?

    // Примеры категорий
    private var categories = [
        Category(uuid: UUID(), name: "Домашний уют")
    ]

    // Секции и результаты (после фильтрации)
    private var sections: [CollectionSection] = []
    private var resultSections: [CollectionSection] = []

    // Список трекеров
    private var items: [Tracker] = []

    // Выбранная дата для фильтрации
    private var selectedDate: Date = Date()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = tabBarItem.title

        // Регистрация и настройка DatePicker
        let datePicker = DatePickerController(presenter: self).register()
        datePicker.picker.addTarget(self, action: #selector(changeDate(sender:)), for: .valueChanged)
        selectedDate = datePicker.picker.date

        // Кнопка создания трекера, поисковик и коллекция
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

    // MARK: Data helpers
    // Генерация тестовых трекеров
    private func fetchData() -> [Tracker] {
        (0..<1).compactMap { _ in randomTracker(categories: categories) }
    }

    // Группировка трекеров по категориям и формирование секций
    private func willCollectSections(categories: [Category], trackers: [Tracker]) -> [CollectionSection] {
        let groupTrackers = Dictionary(grouping: trackers, by: { $0.categoryUuid })

        var collection: [CollectionSection] = []
        groupTrackers.forEach { (categoryUuid: UUID, trackers: [Tracker]) in
            let category = categories.first { $0.uuid == categoryUuid }
            if let category = category {
                collection.append(CollectionSection(category: category, items: trackers))
            }
        }

        collection.sort { section, section2 in
            section.category.name < section2.category.name
        }

        return collection
    }

    // Создание случайного трекера 
    private func randomTracker(categories: [Category]) -> Tracker? {
        let names = [
            "Поливать растения"
        ].shuffled()

        guard let uuid = categories.first?.uuid else { return nil }

        return Tracker(
            id: UUID(),
            name: names[0],
            categoryUuid: uuid,
            schedule: nil,
            emoji: "🌼",
            color: Colors.allCases.randomElement() ?? .blue,
            completeAt: []
        )
    }

    // MARK: Tab bar item
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








