import UIKit

// MARK: - CategoryListViewModel
final class CategoryListViewModel {
    private let store: TrackerCategoryStore
    private(set) var categories: [TrackerCategory] = []

    
    // MARK: - Closures
    var onCategoriesChanged: (() -> Void)?
    var onCategorySelected: ((TrackerCategory) -> Void)?
    
    
    // MARK: - Initialization
    init(store: TrackerCategoryStore = CoreDataMain.shared.trackerCategoryStore) {
        self.store = store
        bindStore()
        loadCategories()
    }

    // MARK: - Private Methods
    private func bindStore() {
        store.onDataChanged = { [weak self] in
            self?.loadCategories()
        }
    }

    // MARK: - Public Methods
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
