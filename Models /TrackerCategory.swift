
//  Created by William White on 12.11.2025.
//


import Foundation
import UIKit



// MARK: - TrackerCategory
struct TrackerCategory: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let trackers: [Tracker]
    
    init(id: UUID = .init(), name: String, trackers: [Tracker] = []) {
        self.id = id
        self.name = name
        self.trackers = trackers
    }
    
    func adding(_ tracker: Tracker) -> TrackerCategory {
        var new = trackers
        new.append(tracker)
        return TrackerCategory(id: id, name: name, trackers: new)
    }
    
    func removingTracker(withId trackerId: UUID) -> TrackerCategory {
        let new = trackers.filter { $0.id != trackerId }
        return TrackerCategory(id: id, name: name, trackers: new)
    }
    
    func replacingTracker(_ tracker: Tracker) -> TrackerCategory {
        let new = trackers.map { $0.id == tracker.id ? tracker : $0 }
        return TrackerCategory(id: id, name: name, trackers: new)
    }
}





