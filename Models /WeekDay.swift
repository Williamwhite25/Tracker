import Foundation

enum WeekDay: Int, CaseIterable, Codable, Hashable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday

    var displayName: String {
        switch self {
        case .monday:    return "Понедельник"
        case .tuesday:   return "Вторник"
        case .wednesday: return "Среда"
        case .thursday:  return "Четверг"
        case .friday:    return "Пятница"
        case .saturday:  return "Суббота"
        case .sunday:    return "Воскресенье"
        }
    }
    
    var shortName: String {
        switch self {
        case .monday:    return "Пн"
        case .tuesday:   return "Вт"
        case .wednesday: return "Ср"
        case .thursday:  return "Чт"
        case .friday:    return "Пт"
        case .saturday:  return "Сб"
        case .sunday:    return "Вс"
        }
    }
    
    var index: Int { Self.allCases.firstIndex(of: self) ?? 0 }
    
    init?(calendarWeekday: Int) {
        switch calendarWeekday {
        case 2: self = .monday
        case 3: self = .tuesday
        case 4: self = .wednesday
        case 5: self = .thursday
        case 6: self = .friday
        case 7: self = .saturday
        case 1: self = .sunday
        default: return nil
        }
    }
}







