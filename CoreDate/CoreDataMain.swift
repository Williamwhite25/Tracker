import Foundation
import CoreData

final class CoreDataMain {
    // MARK: - Shared Instance
    static let shared = CoreDataMain()
    
    // MARK: - Core Data Stack
    private let stack: CoreDataStack
    
    // Инициализация с возможностью переопределения имени модели (для тестов)
    private init(modelName: String = "TrackerModel") {
        self.stack = CoreDataStack(modelName: modelName)
        
        let descriptions = CoreDataStack.makeSQLiteStoreDescriptions(
            modelName: modelName,
            configToFilename: [:] 
        )
        stack.configureStoreDescriptions(descriptions)
        
        // Загружаем хранилища
        stack.loadStores { result in
            switch result {
            case .success:
                print("Core Data loaded successfully")
            case .failure(let error):
                NSLog("Failed to load Core Data: %@", error.localizedDescription)
            }
        }
    }
    
    // MARK: - Context Access
    var viewContext: NSManagedObjectContext { stack.viewContext }
    func newBackgroundContext() -> NSManagedObjectContext { stack.newBackgroundContext() }
    
    // MARK: - Save Methods (используем stack)
    func saveContext() throws {
        try stack.saveContext()
    }
    
    func saveContextIfNeeded() {
        stack.saveContextIfNeeded()
    }
    
    // MARK: - Store Accessors
    private(set) lazy var trackerStore: TrackerStore = {
        return TrackerStore(managedObjectContext: stack.viewContext)
    }()
    
    private(set) lazy var trackerCategoryStore: TrackerCategoryStore = {
        return TrackerCategoryStore(managedObjectContext: stack.viewContext)
    }()
    
    private(set) lazy var trackerRecordStore: TrackerRecordStore = {
        return TrackerRecordStore(managedObjectContext: stack.viewContext)
    }()
}
