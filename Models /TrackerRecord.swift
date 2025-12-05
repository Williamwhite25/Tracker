
//  Created by William White on 12.11.2025.
//


import Foundation

// MARK: - TrackerRecord
struct TrackerRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let trackerId: UUID
    let date: Date
    
    init(id: UUID = .init(), trackerId: UUID, date: Date) {
        self.id = id
        self.trackerId = trackerId
        self.date = date.startOfDay
    }
    
    static func == (lhs: TrackerRecord, rhs: TrackerRecord) -> Bool {
        lhs.trackerId == rhs.trackerId && lhs.date == rhs.date
    }
}


