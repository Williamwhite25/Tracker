
//  Created by William White on 12.11.2025.
//


import Foundation


enum WeekDay: CaseIterable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday

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

    var index: Int { Self.allCases.firstIndex(of: self)! }
}

extension WeekDay {
  
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
