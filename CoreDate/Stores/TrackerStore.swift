import CoreData

final class TrackerStore: NSObject {
    
    // MARK: - Properties
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    
    var onTrackersDidChange: (([Tracker]) -> Void)?
    
    // MARK: - Initialization
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Fetched Results Controller Setup
    private func setupFetchedResultsController() {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        request.sortDescriptors = [
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "title", ascending: true)
        ]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            notifyTrackersChanged()
        } catch {
            print("Failed to fetch trackers: \(error)")
        }
    }
    
    private func notifyTrackersChanged() {
        let trackers = (fetchedResultsController.fetchedObjects ?? []).compactMap { makeTracker(from: $0) }
        onTrackersDidChange?(trackers)
    }
    
    // MARK: - Public Methods
    
    func fetchAllTrackers() throws -> [Tracker] {
        return (fetchedResultsController.fetchedObjects ?? []).compactMap { makeTracker(from: $0) }
    }
    
    func addTracker(_ tracker: Tracker, to categoryTitle: String) throws {
        let category = try getOrCreateCategory(with: categoryTitle)
        
        let trackerCoreData = TrackerCoreData(context: context)
        updateTracker(trackerCoreData, with: tracker)
        trackerCoreData.category = category
        
        try context.save()
    }
    
    func deleteTracker(_ id: UUID) throws {
        let tracker = try fetchTracker(by: id)
        let recordRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        recordRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let records = try context.fetch(recordRequest)
        records.forEach { context.delete($0) }
        
        context.delete(tracker)
        try context.save()
    }
    
    func updateTracker(_ tracker: Tracker, in categoryTitle: String) throws {
        let existingTracker = try fetchTracker(by: tracker.id)
        let category = try getOrCreateCategory(with: categoryTitle)
        
        updateTracker(existingTracker, with: tracker)
        existingTracker.category = category
        
        try context.save()
    }
    
    func fetchTracker(by id: UUID) throws -> TrackerCoreData {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let trackers = try context.fetch(request)
        
        guard let tracker = trackers.first else {
            throw TrackerStoreError.trackerNotFound
        }
        
        return tracker
    }
    
    // MARK: - Private Methods
    
    private func getOrCreateCategory(with title: String) throws -> TrackerCategoryCoreData {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "title == %@", title)
        
        let existingCategories = try context.fetch(request)
        
        if let existingCategory = existingCategories.first {
            return existingCategory
        } else {
            let category = TrackerCategoryCoreData(context: context)
            category.title = title
            return category
        }
    }
    
    private func makeTracker(from coreData: TrackerCoreData) -> Tracker? {
        guard let id = coreData.id,
              let title = coreData.title,
              let color = coreData.color,
              let emoji = coreData.emoji else {
            return nil
        }
        
        var schedule: [Weekday] = []
        if let scheduleData = coreData.schedule {
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
            isHabit: coreData.isHabit
        )
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
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        notifyTrackersChanged()
    }
}

// MARK: - Error Handling
extension TrackerStore {
    enum TrackerStoreError: Error {
        case trackerNotFound
        case invalidTrackerData
        case categoryNotFound
    }
}
