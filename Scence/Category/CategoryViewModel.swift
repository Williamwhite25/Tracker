import Foundation

final class CategoriesViewModel {
    
    // MARK: - Properties
    private let trackerCategoryStore: TrackerCategoryStore
    private var categories: [TrackerCategory] = []
    private var selectedCategoryIndex: Int?
    
    // MARK: - Bindings
    var onCategoriesUpdate: (() -> Void)?
    var onCategorySelect: ((String) -> Void)?
    var onEmptyStateChange: ((Bool) -> Void)?
    var onError: ((Error) -> Void)?
    
    // MARK: - Initialization
    init(trackerCategoryStore: TrackerCategoryStore) {
        self.trackerCategoryStore = trackerCategoryStore
        setupObservers()
        loadCategories()
    }
    
    // MARK: - Setup
    private func setupObservers() {
        trackerCategoryStore.onCategoriesDidChange = { [weak self] categories in
            self?.categories = categories
            self?.onCategoriesUpdate?()
            self?.onEmptyStateChange?(categories.isEmpty)
        }
    }
    
    // MARK: - Public Methods
    func loadCategories() {
        do {
            categories = try trackerCategoryStore.fetchAllCategories()
            onCategoriesUpdate?()
            onEmptyStateChange?(categories.isEmpty)
        } catch {
            onError?(error)
        }
    }
    
    func selectCategory(at index: Int) {
        selectedCategoryIndex = index
    }
    
    func handleCategorySelection(at index: Int) {
        selectCategory(at: index)
        onCategoriesUpdate?()
        
        if let categoryTitle = getCategoryTitle(at: index) {
            onCategorySelect?(categoryTitle)
        }
    }
    
    func getCategory(at index: Int) -> TrackerCategory {
        guard index >= 0 && index < categories.count else {
            fatalError("Index out of range")
        }
        return categories[index]
    }
    
    func getCategoryTitle(at index: Int) -> String? {
        guard index >= 0 && index < categories.count else { return nil }
        return categories[index].title
    }
    
    func getCategoriesCount() -> Int {
        return categories.count
    }
    
    func isCategorySelected(at index: Int) -> Bool {
        return index == selectedCategoryIndex
    }
    
    func addNewCategory(title: String) {
        let newCategory = TrackerCategory(title: title, trackers: [])
        do {
            try trackerCategoryStore.addCategory(newCategory)
        } catch {
            onError?(error)
        }
    }
    
    func deleteCategory(at index: Int) throws {
        let category = getCategory(at: index)
        do {
            try trackerCategoryStore.deleteCategory(category)
        } catch {
            onError?(error)
            throw error
        }
    }
    
    func getSelectedCategoryTitle() -> String? {
        guard let index = selectedCategoryIndex else { return nil }
        return getCategoryTitle(at: index)
    }
}
