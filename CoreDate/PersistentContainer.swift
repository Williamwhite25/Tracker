import Foundation
import CoreData

final class CoreDataStack {
    private let modelName: String
    let container: NSPersistentContainer

    init(modelName: String = "Model") {
        self.modelName = modelName
        self.container = NSPersistentContainer(name: modelName)
    }

    // MARK: - Store descriptions (опционально настраивать перед loadStores)
    func configureStoreDescriptions(_ descriptions: [NSPersistentStoreDescription]) {
        container.persistentStoreDescriptions = descriptions
    }

    // MARK: - Load stores
    func loadStores(completion: ((Result<[NSPersistentStoreDescription], Error>) -> Void)? = nil) {
        container.loadPersistentStores { [weak self] description, error in
            if let error = error {
                NSLog("Failed to load persistent store %@ — %@", description.url?.path ?? "<unknown>", String(describing: error))
                completion?(.failure(error))
                return
            }

            guard let self = self else {
                let err = NSError(domain: "CoreDataStack", code: -1, userInfo: [NSLocalizedDescriptionKey: "CoreDataStack deallocated"])
                completion?(.failure(err))
                return
            }

            // Настройки контекста после успешной загрузки
            self.container.viewContext.automaticallyMergesChangesFromParent = true
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

            completion?(.success(self.container.persistentStoreDescriptions))
        }
    }

    // MARK: - Contexts
    var viewContext: NSManagedObjectContext { container.viewContext }
    func newBackgroundContext() -> NSManagedObjectContext { container.newBackgroundContext() }

    // MARK: - Save (throws)
    func saveContext(_ context: NSManagedObjectContext? = nil) throws {
        let ctx = context ?? viewContext
        guard ctx.hasChanges else { return }
        try ctx.save()
    }

    // MARK: - Safe save (не бросает)
    func saveContextIfNeeded(_ context: NSManagedObjectContext? = nil) {
        let ctx = context ?? viewContext
        guard ctx.hasChanges else { return }
        do {
            try ctx.save()
        } catch {
            NSLog("CoreData save error: %@", error.localizedDescription)
        }
    }

    // MARK: - Helpers: create sqlite descriptions in Application Support
    static func makeSQLiteStoreDescriptions(modelName: String,
                                            configToFilename: [String: String]) -> [NSPersistentStoreDescription] {
        let fm = FileManager.default
        let base: URL
        do {
            let appSupport = try fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            base = appSupport.appendingPathComponent(modelName, isDirectory: true)
            try fm.createDirectory(at: base, withIntermediateDirectories: true)
        } catch {
            let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fallback = docs.appendingPathComponent(modelName, isDirectory: true)
            try? fm.createDirectory(at: fallback, withIntermediateDirectories: true)
            NSLog("Application Support unavailable, fallback to Documents: %@", String(describing: error))
            return configToFilename.map { config, filename in
                let url = fallback.appendingPathComponent(filename)
                let desc = NSPersistentStoreDescription(url: url)
                desc.type = NSSQLiteStoreType
                desc.configuration = config
                desc.shouldMigrateStoreAutomatically = true
                desc.shouldInferMappingModelAutomatically = true
                return desc
            }
        }

        return configToFilename.map { config, filename in
            let url = base.appendingPathComponent(filename)
            let desc = NSPersistentStoreDescription(url: url)
            desc.type = NSSQLiteStoreType
            desc.configuration = config
            desc.shouldMigrateStoreAutomatically = true
            desc.shouldInferMappingModelAutomatically = true
            return desc
        }
    }

    // MARK: - Test helper: in-memory stack
    static func inMemoryStack(modelName: String = "Model") -> CoreDataStack {
        let stack = CoreDataStack(modelName: modelName)
        let desc = NSPersistentStoreDescription()
        desc.type = NSInMemoryStoreType
        stack.configureStoreDescriptions([desc])
        stack.loadStores { _ in }
        return stack
    }
}
