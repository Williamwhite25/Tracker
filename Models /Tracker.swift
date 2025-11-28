
//  Created by William White on 12.11.2025.
//



import Foundation

// MARK: - Tracker
final class Tracker {
    // MARK: Properties
    let id: UUID
    let name: String
    let categoryUuid: UUID
    let schedule: [WeekDay]?
    let emoji: String
    let color: Colors
    private(set) var completeAt: [Date]

    // MARK: Init
    init(
        id: UUID,
        name: String,
        categoryUuid: UUID,
        schedule: [WeekDay]?,
        emoji: String,
        color: Colors,
        completeAt: [Date] = []
    ) {
        self.id = id
        self.name = name
        self.categoryUuid = categoryUuid
        self.schedule = schedule
        self.emoji = emoji
        self.color = color
        self.completeAt = completeAt
    }

    // MARK: Completion checks & updates
    func isCompleted(on date: Date) -> Bool {
        let day = date.startOfDay
        return completeAt.contains { Calendar.current.isDate($0, inSameDayAs: day) }
    }

    @discardableResult
    func markCompleted(on date: Date) -> Bool {
        let day = date.startOfDay
        guard !isCompleted(on: day) else { return false }
        completeAt.append(day)
        return true
    }

    @discardableResult
    func unmarkCompleted(on date: Date) -> Bool {
        let day = date.startOfDay
        if let idx = completeAt.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: day) }) {
            completeAt.remove(at: idx)
            return true
        }
        return false
    }
}
