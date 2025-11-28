
//  Created by William White on 12.11.2025.
//

import Foundation



// MARK: - TrackerSection
struct TrackerSection {
    let category: TrackerCategory
    let items: [Tracker]?
}

// MARK: - Tracker
struct Tracker: Identifiable, Equatable {
    let id: UUID
    let name: String
    let categoryId: UUID
    let schedule: [WeekDay]?
    let emoji: String
    let color: Colors
    let completedDates: Set<Date>

    init(
        id: UUID = .init(),
        name: String,
        categoryId: UUID,
        schedule: [WeekDay]? = nil,
        emoji: String,
        color: Colors,
        completedDates: Set<Date> = []
    ) {
        self.id = id
        self.name = name
        self.categoryId = categoryId
        self.schedule = schedule
        self.emoji = emoji
        self.color = color
        self.completedDates = Set(completedDates.map { $0.startOfDay })
    }

    func isCompleted(on date: Date) -> Bool {
        completedDates.contains(date.startOfDay)
    }

    func markingCompleted(on date: Date) -> Tracker {
        let day = date.startOfDay
        guard !completedDates.contains(day) else { return self }
        return Tracker(
            id: id, name: name, categoryId: categoryId,
            schedule: schedule, emoji: emoji, color: color,
            completedDates: completedDates.union([day])
        )
    }

    func unmarkingCompleted(on date: Date) -> Tracker {
        let day = date.startOfDay
        let newDates = completedDates.subtracting([day])
        return Tracker(
            id: id, name: name, categoryId: categoryId,
            schedule: schedule, emoji: emoji, color: color,
            completedDates: newDates
        )
    }
}

// Codable keys
private extension Tracker {
    enum CodingKeys: String, CodingKey {
        case id, name, categoryId, schedule, emoji, color, completedDates
    }
}

extension Tracker: Decodable {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let id = try c.decode(UUID.self, forKey: .id)
        let name = try c.decode(String.self, forKey: .name)
        let categoryId = try c.decode(UUID.self, forKey: .categoryId)
        let schedule = try c.decodeIfPresent([WeekDay].self, forKey: .schedule)
        let emoji = try c.decode(String.self, forKey: .emoji)
        let color = try c.decode(Colors.self, forKey: .color)
        let dates = try c.decodeIfPresent([Date].self, forKey: .completedDates) ?? []
        self.init(
            id: id,
            name: name,
            categoryId: categoryId,
            schedule: schedule,
            emoji: emoji,
            color: color,
            completedDates: Set(dates.map { $0.startOfDay })
        )
    }
}

extension Tracker: Encodable {
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(categoryId, forKey: .categoryId)
        try c.encodeIfPresent(schedule, forKey: .schedule)
        try c.encode(emoji, forKey: .emoji)
        try c.encode(color, forKey: .color)
        try c.encode(Array(completedDates), forKey: .completedDates)
    }
}


