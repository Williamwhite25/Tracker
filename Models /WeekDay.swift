import Foundation

enum Weekday: Int, CaseIterable, Codable {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1
    
    var localizedName: String {
        switch self {
        case .monday: return Localizable.monday
        case .tuesday: return Localizable.tuesday
        case .wednesday: return Localizable.wednesday
        case .thursday: return Localizable.thursday
        case .friday: return Localizable.friday
        case .saturday: return Localizable.saturday
        case .sunday: return Localizable.sunday
        }
    }
    
    var shortName: String {
        switch self {
        case .monday: return Localizable.mondayShort
        case .tuesday: return Localizable.tuesdayShort
        case .wednesday: return Localizable.wednesdayShort
        case .thursday: return Localizable.thursdayShort
        case .friday: return Localizable.fridayShort
        case .saturday: return Localizable.saturdayShort
        case .sunday: return Localizable.sundayShort
        }
    }
}
