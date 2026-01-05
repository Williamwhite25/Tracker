import Foundation

struct Tracker {
    let id: UUID
    let title: String
    let color: String
    let emoji: String
    let schedule: [Weekday]
    let isHabit: Bool
    
    init(id: UUID = UUID(), title: String, color: String, emoji: String, schedule: [Weekday], isHabit: Bool) {
        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.isHabit = isHabit
    }
}
