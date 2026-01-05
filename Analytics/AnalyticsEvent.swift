import Foundation

enum AnalyticsEvent {
    case open(screen: Screen)
    case close(screen: Screen)
    case click(screen: Screen, item: Item)
    
    var name: String {
        switch self {
        case .open: return "open"
        case .close: return "close"
        case .click: return "click"
        }
    }
    
    enum Item: String {
        case addTrack = "add_track"
        case track
        case filter
        case edit
        case delete
    }
    
    enum Screen: String {
        case main = "Main"
        case statistics = "Statistics"
    }
    
    var params: [String: String] {
        switch self {
        case let .open(screen),
            let .close(screen):
            return ["screen": screen.rawValue]
        case let .click(screen, item):
            return ["screen": screen.rawValue, "item": item.rawValue]
        }
    }
}

