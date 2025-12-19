import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidUpdate()
    func trackerStoreDidAddTracker(_ tracker: Tracker)
}

final class TrackerStore: NSObject {
    private let managedObjectContext: NSManagedObjectContext
    var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    
    weak var delegate: TrackerStoreDelegate?
    
    init(managedObjectContext: NSManagedObjectContext = CoreDataMain.shared.viewContext) {
        self.managedObjectContext = managedObjectContext
        super.init()
        
        setupFetchResultsController()
    }
    
    func setupFetchResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
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
    
    func deleteTrackerAndRecords(trackerId: UUID) {
        if let trackerCoreData = fetchTracker(by: trackerId) {
            CoreDataMain.shared.trackerRecordStore.deleteAllRecords(for: trackerId)
            managedObjectContext.delete(trackerCoreData)
            CoreDataMain.shared.saveContextIfNeeded()
        }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.trackerStoreDidUpdate()
    }
}

extension TrackerStore {
    
    func createTracker(name: String, color: String, emoji: String, schedule: [WeekDay]?, categoryTitle: String) {
        let newTracker = TrackerCoreData(context: managedObjectContext)
        newTracker.id = UUID()
        newTracker.name = name
        newTracker.color = color
        newTracker.emoji = emoji
        newTracker.schedule = schedule?.map { String($0.rawValue) }.joined(separator: ",")
        
        let categoryStore = CoreDataMain.shared.trackerCategoryStore
        var category = categoryStore.fetchCategory(by: categoryTitle)
        if category == nil {
            categoryStore.createCategory(name: categoryTitle)
            category = categoryStore.fetchCategory(by: categoryTitle)
        }
        
        if let category = category {
            let trackers = category.mutableSetValue(forKey: "trackers")
            trackers.add(newTracker)
        }
        
        CoreDataMain.shared.saveContextIfNeeded()
        delegate?.trackerStoreDidAddTracker(Tracker(trackerCoreData: newTracker))
    }
    
    func fetchTracker(by id: UUID) -> TrackerCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            return results.first
        } catch {
            print("Failed to fetch tracker: \(error)")
            return nil
        }
    }
    
    func fetchTrackersGroupedByCategory() -> [TrackerCategory] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.relationshipKeyPathsForPrefetching = ["trackers"]
        
        do {
            let categoryEntities = try managedObjectContext.fetch(fetchRequest)
            var categories = categoryEntities.map { categoryEntity in
                let trackers = categoryEntity.trackers?.allObjects as? [TrackerCoreData] ?? []
                let trackerModels = trackers.map { Tracker(trackerCoreData: $0) }
                return TrackerCategory(name: categoryEntity.name ?? "Без категории", trackers: trackerModels)
            }
            
            if let completedCategoryIndex = categories.firstIndex(where: { $0.name == "Закрепленные" }) {
                let completedCategory = categories.remove(at: completedCategoryIndex)
                categories.insert(completedCategory, at: 0)
            }
            
            return categories
        } catch let error as NSError {
            print("Error fetching categories: \(error), \(error.userInfo)")
            return []
        }
    }
}

extension TrackerStore {
    
    private func createCategoryIfNotExists(with name: String) -> TrackerCategoryCoreData {
        if let existingCategory = fetchCategory(by: name) {
            return existingCategory
        } else {
            let newCategory = TrackerCategoryCoreData(context: managedObjectContext)
            newCategory.name = name
            CoreDataMain.shared.saveContextIfNeeded()
            return newCategory
        }
    }
    
    private func fetchCategory(by name: String) -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            return results.first
        } catch {
            print("Failed to fetch category: \(error)")
            return nil
        }
    }
}

extension TrackerStore {
    func convertToCoreData(tracker: Tracker) -> TrackerCoreData? {
        return fetchTracker(by: tracker.id)
    }
}

extension TrackerStore {
    func updateTracker(id: UUID, name: String, color: String, emoji: String, schedule: [WeekDay]?, categoryTitle: String) {
        guard let trackerCoreData = fetchTracker(by: id) else { return }
        
        trackerCoreData.name = name
        trackerCoreData.color = color
        trackerCoreData.emoji = emoji
        trackerCoreData.schedule = schedule?.map { String($0.rawValue) }.joined(separator: ",")
        
        let categoryStore = TrackerCategoryStore()
        var category = categoryStore.fetchCategory(by: categoryTitle)
        if category == nil {
            categoryStore.createCategory(name: categoryTitle)
            category = categoryStore.fetchCategory(by: categoryTitle)
        }
        
        if let category = category {
            trackerCoreData.trackerCategoryCoreData = category
        }
        
        CoreDataMain.shared.saveContextIfNeeded()
        delegate?.trackerStoreDidUpdate()
    }
}


extension Tracker {
    init(trackerCoreData: TrackerCoreData) {
        self.id = trackerCoreData.id ?? UUID()
        self.name = trackerCoreData.name ?? ""
        self.color = trackerCoreData.colorValue
        self.emoji = trackerCoreData.emoji ?? ""
        self.schedule = Tracker.deserializeSchedule(from: trackerCoreData.schedule ?? "")
        self.completedDates = Set()
        self.categoryId = trackerCoreData.trackerCategoryCoreData?.id ?? UUID()
    }
}
