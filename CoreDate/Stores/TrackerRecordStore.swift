import UIKit
import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func trackerRecordStoreDidUpdate()
}

final class TrackerRecordStore: NSObject {
    weak var delegate: TrackerRecordStoreDelegate?
    
    private let managedObjectContext: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>!
    
    init(managedObjectContext: NSManagedObjectContext = CoreDataMain.shared.viewContext) {
        self.managedObjectContext = managedObjectContext
        super.init()
        
        setupFetchResultsController()
    }
    
    func setupFetchResultsController() {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error performing fetch: \(error)")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerRecordStoreDidUpdate()
    }
}

// MARK: - Public API (абстрагирован от Core Data)
extension TrackerRecordStore {
    
    /// Отмечает трекер выполненным в указанный день
    func addRecord(for trackerId: UUID, date: Date) {
        guard let tracker = CoreDataMain.shared.trackerStore.fetchTracker(by: trackerId) else {
            print("Tracker with ID \(trackerId) not found")
            return
        }
        
        // Проверяем, нет ли уже записи на эту дату
        if isCompleted(for: trackerId, date: date) {
            return
        }
        
        let record = TrackerRecordCoreData(context: managedObjectContext)
        record.id = UUID()
        record.tracker = tracker
        record.date = date
        
        CoreDataMain.shared.saveContextIfNeeded()
    }
    
    /// Удаляет отметку о выполнении трекера в указанный день
    func removeRecord(for trackerId: UUID, date: Date) {
        guard let tracker = CoreDataMain.shared.trackerStore.fetchTracker(by: trackerId) else {
            print("Tracker with ID \(trackerId) not found")
            return
        }
        
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tracker == %@ AND date == %@", tracker, date as CVarArg)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest)
            for record in records {
                managedObjectContext.delete(record)
            }
            CoreDataMain.shared.saveContextIfNeeded()
        } catch {
            print("Failed to remove record: \(error)")
        }
    }
    
    /// Проверяет, выполнен ли трекер в указанный день
    func isCompleted(for trackerId: UUID, date: Date) -> Bool {
        guard let tracker = CoreDataMain.shared.trackerStore.fetchTracker(by: trackerId) else {
            return false
        }
        
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tracker == %@ AND date == %@", tracker, date as CVarArg)
        
        do {
            let count = try managedObjectContext.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Failed to check completion: \(error)")
            return false
        }
    }
    
    /// Возвращает количество дней, когда трекер был выполнен
    func completedDaysCount(for trackerId: UUID) -> Int {
        guard let tracker = CoreDataMain.shared.trackerStore.fetchTracker(by: trackerId) else {
            return 0
        }
        
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tracker == %@", tracker)
        
        do {
            return try managedObjectContext.count(for: fetchRequest)
        } catch {
            print("Failed to count completed days: \(error)")
            return 0
        }
    }
    
    /// Возвращает общее количество всех записей (например, для статистики)
    func totalCompletedTrackersCount() -> Int {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        do {
            return try managedObjectContext.count(for: fetchRequest)
        } catch {
            print("Failed to count total records: \(error)")
            return 0
        }
    }
    
    /// Удаляет все записи для трекера (например, при удалении трекера)
    func deleteAllRecords(for trackerId: UUID) {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tracker.id == %@", trackerId as CVarArg)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest)
            for record in records {
                managedObjectContext.delete(record)
            }
            CoreDataMain.shared.saveContextIfNeeded()
            delegate?.trackerRecordStoreDidUpdate()
        } catch {
            print("Failed to delete records: \(error)")
        }
    }
    
    func getRecords(for trackerId: UUID) -> [TrackerRecord] {
        guard let tracker = CoreDataMain.shared.trackerStore.fetchTracker(by: trackerId) else { return [] }
        
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tracker == %@", tracker)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest)
            return records.map { TrackerRecord(recordCoreData: $0) }
        } catch {
            print("Failed to fetch records: \(error)")
            return []
        }
    }
}

extension TrackerRecord {
    init(recordCoreData: TrackerRecordCoreData) {
        self.init(
            id: recordCoreData.id ?? UUID(),
            trackerId: recordCoreData.tracker?.id ?? UUID(),
            date: recordCoreData.date ?? Date()
        )
    }
}
