import UIKit
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidChangeContent(_ store: TrackerCategoryStore)
}

final class TrackerCategoryStore: NSObject, NSFetchedResultsControllerDelegate {
    weak var delegate: TrackerCategoryStoreDelegate?
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!

    var onDataChanged: (() -> Void)?

    init(context: NSManagedObjectContext = CoreDataMain.shared.viewContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }

    func fetchCategory(by header: String) -> TrackerCategoryCoreData? {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", header)
        return try? context.fetch(request).first
    }

    
    private func setupFetchedResultsController() {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: context,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
    }

    func fetchCategories() -> [TrackerCategory] {
        (fetchedResultsController.fetchedObjects ?? []).map { TrackerCategory(categoryCoreData: $0) }
    }

    func addCategory(name: String) {
        guard !name.isEmpty else { return }
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.id = UUID()
        newCategory.name = name
        CoreDataMain.shared.saveContextIfNeeded()
        onDataChanged?()
    }

    func deleteCategory(at index: Int) {
        guard let objects = fetchedResultsController.fetchedObjects,
              objects.indices.contains(index) else { return }
        context.delete(objects[index])
        CoreDataMain.shared.saveContextIfNeeded()
        onDataChanged?()
    }

    // MARK: - NSFetchedResultsControllerDelegate
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onDataChanged?()
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
