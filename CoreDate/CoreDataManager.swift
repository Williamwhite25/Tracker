import CoreData

// MARK: - Core Data Manager
protocol CoreDataManageable: AnyObject {
    var viewContext: NSManagedObjectContext { get }
    func saveContext()
}

final class CoreDataManager: CoreDataManageable {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerDataModel")
        
        let description = container.persistentStoreDescriptions.first
        description?.shouldAddStoreAsynchronously = true
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            print("Database URL: \(storeDescription.url?.absoluteString ?? "unknown")")
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.shouldDeleteInaccessibleFaults = true
        
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = viewContext
        guard context.hasChanges else { return }
        
        do {
            try context.save()
            print("Context saved successfully")
        } catch {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
            context.rollback()
        }
    }
}
