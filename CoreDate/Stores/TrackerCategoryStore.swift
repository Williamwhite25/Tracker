import CoreData

final class TrackerCategoryStore: NSObject {
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    
    var onCategoriesDidChange: (([TrackerCategory]) -> Void)?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Fetched Results Controller Setup
    private func setupFetchedResultsController() {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            notifyCategoriesChanged()
        } catch {
            print("Failed to fetch categories: \(error)")
        }
    }
    
    private func notifyCategoriesChanged() {
        let categories = (fetchedResultsController.fetchedObjects ?? []).compactMap { makeCategory(from: $0) }
        onCategoriesDidChange?(categories)
    }
    
    // MARK: - Public Methods
    func fetchAllCategories() throws -> [TrackerCategory] {
        return (fetchedResultsController.fetchedObjects ?? []).compactMap { makeCategory(from: $0) }
    }
    
    func addCategory(_ category: TrackerCategory) throws {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        updateCategory(categoryCoreData, with: category)
        try context.save()
    }
    
    func updateCategory(_ category: TrackerCategory, with newTitle: String) throws {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "title == %@", category.title)
        
        let categories = try context.fetch(request)
        guard let categoryToUpdate = categories.first else {
            throw CategoryError.categoryNotFound
        }
        
        categoryToUpdate.title = newTitle
        try context.save()
    }
    
    func deleteCategory(_ category: TrackerCategory) throws {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "title == %@", category.title)
        
        let categories = try context.fetch(request)
        guard let categoryToDelete = categories.first else {
            throw CategoryError.categoryNotFound
        }
        
        context.delete(categoryToDelete)
        try context.save()
    }
    
    func fetchCategory(with title: String) throws -> TrackerCategory? {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "title == %@", title)
        request.fetchLimit = 1
        
        let categories = try context.fetch(request)
        return categories.first.flatMap { makeCategory(from: $0) }
    }
    
    func getCategory(for tracker: Tracker) -> TrackerCategory? {
            let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
            request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
            
            do {
                let trackers = try context.fetch(request)
                if let trackerCoreData = trackers.first,
                   let categoryCoreData = trackerCoreData.category,
                   let categoryTitle = categoryCoreData.title {
                    return TrackerCategory(title: categoryTitle, trackers: [])
                }
            } catch {
                print("Error fetching category for tracker: \(error)")
            }
            
            return nil
        }

    // MARK: - Private Methods
    private func makeCategory(from coreData: TrackerCategoryCoreData) -> TrackerCategory? {
        guard let title = coreData.title,
              let trackersSet = coreData.trackers as? Set<TrackerCoreData> else {
            return nil
        }
        
        let trackers = trackersSet.compactMap { trackerCoreData -> Tracker? in
            guard let id = trackerCoreData.id,
                  let title = trackerCoreData.title,
                  let color = trackerCoreData.color,
                  let emoji = trackerCoreData.emoji else {
                return nil
            }
            
            var schedule: [Weekday] = []
            if let scheduleData = trackerCoreData.schedule {
                do {
                    let decoder = JSONDecoder()
                    let rawValues = try decoder.decode([Int].self, from: scheduleData)
                    schedule = rawValues.compactMap { Weekday(rawValue: $0) }
                } catch {
                    print("Error decoding schedule: \(error)")
                }
            }
            
            return Tracker(
                id: id,
                title: title,
                color: color,
                emoji: emoji,
                schedule: schedule,
                isHabit: trackerCoreData.isHabit
            )
        }
        
        return TrackerCategory(title: title, trackers: trackers)
    }
    
    private func updateCategory(_ categoryCoreData: TrackerCategoryCoreData, with category: TrackerCategory) {
        categoryCoreData.title = category.title
        
        if let existingTrackers = categoryCoreData.trackers as? Set<TrackerCoreData> {
            existingTrackers.forEach { context.delete($0) }
        }
        
        let trackersCoreData = category.trackers.map { tracker -> TrackerCoreData in
            let trackerCoreData = TrackerCoreData(context: context)
            updateTracker(trackerCoreData, with: tracker)
            return trackerCoreData
        }
        
        categoryCoreData.trackers = NSSet(array: trackersCoreData)
    }
    
    private func updateTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.id = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.isHabit = tracker.isHabit
        
        let rawValues = tracker.schedule.map { $0.rawValue }
        do {
            let encoder = JSONEncoder()
            let scheduleData = try encoder.encode(rawValues)
            trackerCoreData.schedule = scheduleData
        } catch {
            print("Error encoding schedule: \(error)")
            trackerCoreData.schedule = nil
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        notifyCategoriesChanged()
    }
}

// MARK: - Error Handling
extension TrackerCategoryStore {
    enum CategoryError: Error {
        case categoryNotFound
        case invalidData
        case saveFailed
    }
}
