
//  Created by William White on 12.11.2025.
//


import Foundation


struct TrackerRecord: Equatable {
    let id: UUID
    let trackerID: UUID
    let date: Date

    init(id: UUID = UUID(), trackerID: UUID, date: Date) {
        self.id = id
        self.trackerID = trackerID
        self.date = date.startOfDay
    }

    static func == (lhs: TrackerRecord, rhs: TrackerRecord) -> Bool {
        return lhs.trackerID == rhs.trackerID && lhs.date == rhs.date
    }
}
