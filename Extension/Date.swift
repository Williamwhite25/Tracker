

import Foundation
import CoreData

extension Date {
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }
}
