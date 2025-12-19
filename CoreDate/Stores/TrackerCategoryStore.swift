import UIKit
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidChangeContent(_ store: TrackerCategoryStore)
}

final class TrackerCategoryStore: NSObject, NSFetchedResultsControllerDelegate {
    weak var delegate: TrackerCategoryStoreDelegate?
    
    private let managedObjectContext: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    
    init(managedObjectContext: NSManagedObjectContext = CoreDataMain.shared.viewContext) {
        self.managedObjectContext = managedObjectContext
        super.init()
        
        setupFetchResultsController()
    }
    
    func fetchCategory(by header: String) -> TrackerCategoryCoreData? {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", header)
        return try? managedObjectContext.fetch(request).first
    }
    
    func createCategory(name: String) {
        if fetchCategory(by: name) == nil {
            let category = TrackerCategoryCoreData(context: managedObjectContext)
            category.name = name
            CoreDataMain.shared.saveContextIfNeeded()
        }
    }

    func fetchCategories() -> [TrackerCategory] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.relationshipKeyPathsForPrefetching = ["trackers"]
        
        do {
            let categoryEntities = try managedObjectContext.fetch(fetchRequest)
            return categoryEntities.map { TrackerCategory(categoryCoreData: $0) }
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }
    
    func setupFetchResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: managedObjectContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error performing fetch: \(error)")
        }
    }
}


extension TrackerCategory {
    /// Инициализирует `TrackerCategory` из Core Data-сущности
    init(categoryCoreData: TrackerCategoryCoreData) {
        self.id = categoryCoreData.id ?? UUID()
        self.name = categoryCoreData.name ?? "Без названия"
        
        if let trackersCoreData = categoryCoreData.trackers?.allObjects as? [TrackerCoreData] {
            self.trackers = trackersCoreData.map { Tracker(trackerCoreData: $0) }
        } else {
            self.trackers = []
        }
    }
}
