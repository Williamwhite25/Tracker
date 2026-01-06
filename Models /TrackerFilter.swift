import Foundation

enum TrackerFilter: CaseIterable {
    case all
    case today
    case completed
    case uncompleted
    
    var title: String {
        switch self {
        case .all: return Localizable.allTrackersFilter
        case .today: return Localizable.todayTrackersFilter
        case .completed: return Localizable.completedTrackersFilter
        case .uncompleted: return Localizable.uncompletedTrackersFilter
        }
    }
    
    var isDefaultState: Bool {
        return self == .all || self == .today
    }
}

extension TrackerFilter: RawRepresentable {
    public typealias RawValue = String
    
    public init?(rawValue: String) {
        switch rawValue {
        case "all": self = .all
        case "today": self = .today
        case "completed": self = .completed
        case "uncompleted": self = .uncompleted
        default: return nil
        }
    }
    
    public var rawValue: String {
        switch self {
        case .all: return "all"
        case .today: return "today"
        case .completed: return "completed"
        case .uncompleted: return "uncompleted"
        }
    }
}
