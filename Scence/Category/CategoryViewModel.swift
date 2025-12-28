import UIKit

final class CategoryListViewModel {
    private let store: TrackerCategoryStore
    private(set) var categories: [TrackerCategory] = []

    var onCategoriesChanged: (() -> Void)?
    var onCategorySelected: ((TrackerCategory) -> Void)?

    init(store: TrackerCategoryStore = CoreDataMain.shared.trackerCategoryStore) {
        self.store = store
        bindStore()
        loadCategories()
    }

    private func bindStore() {
        store.onDataChanged = { [weak self] in
            self?.loadCategories()
        }
    }

    func loadCategories() {
        categories = store.fetchCategories()
        onCategoriesChanged?()
    }

    func addCategory(name: String) {
        store.addCategory(name: name)
    }

    func selectCategory(at index: Int) {
        guard categories.indices.contains(index) else { return }
        let selected = categories[index]
        onCategorySelected?(selected)
    }

    func deleteCategory(at index: Int) {
        store.deleteCategory(at: index)
    }
}
