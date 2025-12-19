import UIKit

enum Colors: Int, CaseIterable, Codable {
    case pinkEnergy = 0xFD4C49
    case orange = 0xFF881E
    case blue = 0x007BFA
    case purple = 0x6E44FE
    case green = 0x33CF69
    case softPurple = 0xE66DD4
    case pinkCosmos = 0xF9D4D4
    case blueSky = 0x34A7FE
    case seaBreeze = 0x46E69D
    case darkBlue = 0x35347C
    case tomato = 0xFF674D
    case pink = 0xFF99CC
    case peach = 0xF6C48B
    case blueViolet = 0x7994F5
    case violet = 0x832CF1
    case purpleViolet = 0xAD56DA
    case purpleMania = 0x8D72E6
    case limeGreen = 0x2FD058
    
    var uiColor: UIColor {
        UIColor(
            red: CGFloat((rawValue >> 16) & 0xFF) / 255,
            green: CGFloat((rawValue >> 8) & 0xFF) / 255,
            blue: CGFloat(rawValue & 0xFF) / 255,
            alpha: 1
        )
    }
}

extension Colors: CustomStringConvertible {
    var description: String {
        switch self {
        case .pinkEnergy: return "pinkEnergy"
        case .orange: return "orange"
        case .blue: return "blue"
        case .purple: return "purple"
        case .green: return "green"
        case .softPurple: return "softPurple"
        case .pinkCosmos: return "pinkCosmos"
        case .blueSky: return "blueSky"
        case .seaBreeze: return "seaBreeze"
        case .darkBlue: return "darkBlue"
        case .tomato: return "tomato"
        case .pink: return "pink"
        case .peach: return "peach"
        case .blueViolet: return "blueViolet"
        case .violet: return "violet"
        case .purpleViolet: return "purpleViolet"
        case .purpleMania: return "purpleMania"
        case .limeGreen: return "limeGreen"
        }
    }
}

